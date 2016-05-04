class App < Sinatra::Base
    enable :sessions
    use Rack::Flash
    register Sinatra::Partial
    set :partial_template_engine, :slim

    before do
        if session.has_key?(:credentials) && session.has_key?(:google_user)
            @google_user = session[:google_user]
            if @google_user["hd"] == "itggot.se"
                @user = User.first(email: @google_user["email"])
                if @user
                    @user.update(name: @google_user["name"], avatar: @google_user["picture"])
                    session[:id] = @user.id

                    if request.path_info == "/oauth2callback" || request.path_info == "/signin"
                        redirect "/"
                    end
                else
                    session.destroy
                    return throw_error(app: self, code: 403, message: "forbidden")
                end
            else
                session.destroy
                return throw_error(app: self, code: 403, message: "forbidden")
            end
        elsif request.path_info != "/oauth2callback" && request.path_info != "/signin"
            redirect "/signin"
        end
    end

    get "/?" do
        slim :index
    end

    # Show interface for signing in
    get "/signin/?" do
        slim :signin, layout: false
    end

    # Authorize with Google
    get "/oauth2callback/?" do
        user_info_or_redirect, access_token = User.authorize(app: self, params: params)

        if user_info_or_redirect.is_a? String
            redirect user_info_or_redirect
        elsif user_info_or_redirect["hd"] == "itggot.se"
            redirect "/"
        else
            User.revoke(app: self, access_token: access_token)
            flash[:invalid_domain] = true
            redirect "/signin"
        end
    end

    # Sign out
    get "/signout/?" do
        session.destroy
        redirect "/"
    end

    # Uploads
    get "/uploads/:uuid/:file" do |uuid, file|
        if uuid == @user.uuid || @user.permission_admin || @user.permission_teacher
            sending_file = File.join("uploads", uuid, file)
            unless File.exist?(sending_file)
                return throw_error(app: self, code: 403, message: "forbidden")
            else
                send_file sending_file
            end
        else
            return throw_error(app: self, code: 403, message: "forbidden")
        end
    end

    # List all issues
    get "/issues/?" do
        if @user.permission_admin
            @assigned_issues = Issue.all(closed: false)
            @unassigned_issues = Issue.all(id: 3, closed: false)
            @unsolved_issues = Issue.all(closed: false)
            @solved_issues = Issue.all(closed: true)
            @issues = Issue.all(order: [:updated_at.asc])
        else
            @unsolved_issues = Issue.all(user_id: @user.id, closed: false)
            @solved_issues = Issue.all(user_id: @user.id, closed: true)
        end
        slim :issues
    end

    # List all issues that has a certain category
    get "/view/category/:title/issues/?" do |title|
        @category = Category.first(title: title)
        unless @category
            return throw_error(app: self, code: 404, message: "not found")
        end

        if @user.permission_admin
            @assigned_issues = @category.issues
            @unassigned_issues = @category.issues
            @unsolved_issues = @category.issues(closed: false)
            @solved_issues = @category.issues(closed: true)
        else
            @unsolved_issues = @category.issues(user_id: @user.id, closed: false)
            @solved_issues = @category.issues(user_id: @user.id, closed: true)
        end

        slim :issues
    end

    # Read an issue along with its attachments and categories
    get "/view/issue/:uuid/?" do |uuid|
        @issue = Issue.first(uuid: uuid)
        if @issue
            @description = Kramdown::Document.new(@issue.description, :input => 'markdown').to_html
            @attachments = Attachment.all(issue_id: @issue.id)
            slim :issue
        else
            return throw_error(app: self, code: 404, message: "not found")
        end
    end

    # Show the interface for creating an issue
    get "/create/issue/?" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission_admin && !@user.permission_teacher
        @categories = Category.all(order: [:title.asc])
        slim :create_issue
    end

    # Report the issue to the database
    post "/create/issue/?" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission_admin && !@user.permission_teacher
        issue = Issue.report(app: self, user: @user, params: params)
        if issue.valid?
            Attachment.upload(app: self, user: @user, issue: issue, params: params)
            flash[:success] = true
			redirect "/view/issue/#{issue.uuid}"
        else
            flash[:error] = issue.errors.to_h
            redirect back
        end
    end

    # Show the interface to edit an issue
    get "/edit/issue/:uuid" do |uuid|
        @categories = Category.all(order: [:title.asc])
        @issue = Issue.first(uuid: uuid)
        unless @issue.user_id == @user.id || @user.permission_admin || @user.permission_teacher
            return throw_error(app: self, code: 403, message: "forbidden")
        end
        slim :edit_issue
    end

    # Update the database with edits made to an issue
    post "/edit/issue/?" do

    end

    # Delete an issue along with its attachments from database and filesystem
    post "/delete/issue/?" do
        Issue.delete(app: self, user: @user, params: params)
        redirect "/issues"
    end

    post "/edit/issue/solved" do
        Issue.close(app: self, user: @user, params: params)
        redirect "/issues"
    end

    # List all FAQ articles
    get "/faq/?" do
        @articles = Faq.all
        slim :faq
    end

    get "/view/faq/:uuid/?" do |uuid|
        @article = Faq.first(uuid: uuid)
        unless @article
            return throw_error(app: self, code: 404, message: "not found")
        end

        @answer = Kramdown::Document.new(@article.answer, :input => 'markdown').to_html
        slim :faq_article
    end

    post "/delete/faq/?" do
        faq = Faq.delete(app: self, user: @user, params: params)
        redirect "/faq"
    end

    # Settings
    get "/settings/?" do
        slim :settings
    end

    # User settings
    get "/users/?" do
        unless @user.permission_admin || @user.permission_teacher
            return throw_error(app: self, code: 403, message: "not found")
        end

        @admins = User.all(permission_admin: true, :order => [ :name.asc ])
        @teachers = User.all(permission_teacher: true, :order => [ :name.asc ])
        @students = User.all(permission_admin: false, permission_teacher: false, :order => [ :name.asc ])

        slim :users
    end

    post "/delete/user/?" do
        unless @user.permission_admin
            return throw_error(app: self, code: 403, message: "forbidden")
        end

        User.delete(app: self, user: @user, params: params)
        redirect "/users"
    end

    # Other
    get "/conditions/?" do
        slim :conditions
    end

    error do
        @error = env["sinatra.error"]
        slim :error
    end

end
