class App < Sinatra::Base
    enable :sessions
    use Rack::Flash
    register Sinatra::Partial
    set :partial_template_engine, :slim

    before do
        if session.has_key?(:google_user)
            @google_user = session[:google_user]
            if @google_user["hd"] == "itggot.se"
                @user = User.first(email: @google_user["email"], active: true)
                unless @user
                    session.destroy
                    flash[:invalid_user] = true
                    redirect "/signin"
                end
                @user.update(name: @google_user["name"], avatar: @google_user["picture"])
                session[:id] = @user.id

                if request.path_info == "/oauth2callback" || request.path_info == "/signin"
                    redirect "/"
                end
            else
                session.destroy
                flash[:invalid_domain] = true
                return throw_error(app: self, code: 403, message: "forbidden", layout: false)
            end
        elsif request.path_info != "/oauth2callback" && request.path_info != "/signin"
            redirect "/signin"
        else
            session.destroy
            return throw_error(app: self, code: 403, message: "forbidden", layout: false)
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
            user = User.first(email: user_info_or_redirect["email"], active: true)
            unless user
                session.destroy
                redirect "/signin"
            end
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
        if uuid == @user.uuid || @user.permission == :admin || @user.permission == :teacher
            sending_file = File.join("uploads", uuid, file)
            return throw_error(app: self, code: 404, message: "not found") unless File.exist?(sending_file)

            send_file sending_file
        else
            return throw_error(app: self, code: 403, message: "forbidden")
        end
    end

    # List all issues
    get "/issues/?" do
        if @user.permission == :admin
            @assigned_issues, @unassigned_issues = [], []
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
        return throw_error(app: self, code: 404, message: "not found") unless @category

        if @user.permission == :admin
            @assigned_issues = @category.issues
            @unassigned_issues = @category.issues
            @unsolved_issues = @category.issues(closed: false)
            @solved_issues = @category.issues(closed: true)
            @issues = Issue.all
        else
            @unsolved_issues = @category.issues(user_id: @user.id, closed: false)
            @solved_issues = @category.issues(user_id: @user.id, closed: true)
        end

        slim :category_issues
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
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

        @categories = Category.all(order: [:title.asc])
        slim :create_issue
    end

    # Report the issue to the database
    post "/create/issue/?" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

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
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

        @issue = Issue.first(uuid: uuid)
        return throw_error(app: self, code: 400, message: "bad request") if @issue.closed

        @categories = Category.all(order: [:title.asc])
        return throw_error(app: self, code: 403, message: "forbidden") unless @issue.user_id == @user.id || @user.permission == :admin || @user.permission == :teacher
        slim :edit_issue
    end

    # Update the database with edits made to an issue
    post "/edit/issue/?" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

        issue = Issue.first(uuid: params[:issue])
        return throw_error(app: self, code: 400, message: "bad request") if issue.closed
    end

    # Delete an issue along with its attachments from database and filesystem
    post "/delete/issue/?" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

        Issue.delete(app: self, user: @user, params: params)
        redirect "/issues"
    end

    post "/edit/issue/solved" do
        return throw_error(app: self, code: 403, message: "forbidden") if @user.blocked && !@user.permission == :admin && !@user.permission == :teacher

        Issue.close(app: self, user: @user, params: params)
        redirect "/issues"
    end

    # List all FAQ articles
    get "/faq/?" do
        @articles = Faq.all
        slim :faq
    end

    # Read a faq article along with its attachments and categories
    get "/view/faq/:uuid/?" do |uuid|
        @article = Faq.first(uuid: uuid)
        return throw_error(app: self, code: 404, message: "not found") unless @article

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

    # Show a list of all users
    get "/users/?" do
        return throw_error(app: self, code: 403, message: "forbidden") unless @user.permission == :admin || @user.permission == :teacher

        @admins = User.all(permission: :admin, :order => [ :name.asc ])
        @teachers = User.all(permission: :teacher, :order => [ :name.asc ])
        @students = User.all(permission: :student, :order => [ :name.asc ])

        slim :users
    end

    # Show an individual user
    get "/user/:uuid" do |uuid|
        return throw_error(app: self, code: 403, message: "forbidden") unless @user.permission == :admin || @user.permission == :teacher

        @this_user = User.first(uuid: uuid)
        unless @this_user
            return throw_error(app: self, code: 404, message: "not found") unless @user.permission == :admin || @user.permission == :teacher
        end

        slim :user
    end

    # Show the interface to add users
    get "/users/add/?" do
        return throw_error(app: self, code: 403, message: "forbidden") unless @user.permission == :admin
        @users = User.all(active: false)
        slim :add_users
    end

    # Sync all users to database from Google Admin SDK
    get "/users/sync/?" do
        return throw_error(app: self, code: 403, message: "forbidden") unless @user.permission == :admin

        get_users_one = Unirest.get "https://www.googleapis.com/admin/directory/v1/users?domain=itggot.se&maxResults=500&viewType=domain_public&orderBy=givenName&access_token=#{session[:access_token]}"
        return throw_error(app: self, code: 500, message: "internal server error") unless get_users_one.code == 200
        users_one = get_users_one.body

        users_one["users"].each do |user|
            if user.has_key?("thumbnailPhotoUrl")
                User.create(uuid: SecureRandom.uuid, name: user["name"]["fullName"], given_name: user["name"]["givenName"], family_name: user["name"]["familyName"], avatar: user["thumbnailPhotoUrl"], email: user["primaryEmail"], active: false)
            else
                User.create(uuid: SecureRandom.uuid, name: user["name"]["fullName"], given_name: user["name"]["givenName"], family_name: user["name"]["familyName"], avatar: "/img/avatar/#{Random.rand(7)}.png", email: user["primaryEmail"], active: false)
            end
        end

        get_users_two = Unirest.get "https://www.googleapis.com/admin/directory/v1/users?domain=itggot.se&maxResults=500&viewType=domain_public&orderBy=givenName&access_token=#{session[:access_token]}&pageToken=#{users_one["nextPageToken"]}"
        return throw_error(app: self, code: 500, message: "internal server error") unless get_users_two.code == 200
        users_two = get_users_two.body

        users_two["users"].each do |user|
            if user.has_key?("thumbnailPhotoUrl")
                User.create(uuid: SecureRandom.uuid, name: user["name"]["fullName"], given_name: user["name"]["givenName"], family_name: user["name"]["familyName"], avatar: user["thumbnailPhotoUrl"], email: user["primaryEmail"], active: false)
            else
                User.create(uuid: SecureRandom.uuid, name: user["name"]["fullName"], given_name: user["name"]["givenName"], family_name: user["name"]["familyName"], avatar: "/img/avatar/#{Random.rand(7)}.png", email: user["primaryEmail"], active: false)
            end
        end

        redirect "/users/add"
    end

    # Delete a user along with everything made by that user
    post "/delete/user/?" do
        return throw_error(app: self, code: 403, message: "forbidden") unless @user.permission == :admin

        User.delete(app: self, user: @user, params: params)
        redirect "/users"
    end

    # Other
    get "/conditions/?" do
        slim :conditions
    end

    error do
        @error = env["sinatra.error"]
        @layout = false
        slim :error, layout: false
    end

end
