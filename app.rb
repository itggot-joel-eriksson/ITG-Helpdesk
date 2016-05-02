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
                    halt 403
                end
            else
                session.destroy
                halt 403
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
            session[:invalid_domain] = true
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
                status 404
                slim :error
            else
                send_file sending_file
            end
        else
            halt 403
        end
    end

    # List all issues
    get "/issues/?" do
        @issues = Issue.all
        slim :issues
    end

    # List all issues that has a certain category
    get "/view/category/:title/issues/?" do |title|
        @category = Category.first(title: title) #include :issues
        unless @category
            status 404
            slim :error
        end
        @issues = @category.issues
        unless @issues
            status 404
            slim :error
        else
            slim :issues
        end
    end

    # Read an issue along with its attachments and categories
    get "/view/issue/:uuid/?" do |uuid|
        begin
            @issue = Issue.first uuid: uuid
        rescue ArgumentError
            status 404
            slim :error
        end

        unless @issue
            status 404
            slim :error
        else
            @description = Kramdown::Document.new(@issue.description, :input => 'markdown').to_html
            @attachments = Attachment.all(issue_id: @issue.id)
            slim :issue
        end
    end

    # Show the interface for creating an issue
    get "/create/issue/?" do
        @categories = Category.all order: [:title.asc]
        slim :create_issue
    end

    # Report the issue to the database
    post "/create/issue/?" do
        issue = Issue.report(app: self, user: @user, params: params)
        if issue.valid?
            Attachment.upload(app: self, user: @user, issue: issue, params: params)
			redirect "/issues"
        else
            flash[:error] = issue.errors.to_h
            redirect back
        end
    end

    # Show the interface to edit an issue
    get "/edit/issue/?" do

    end

    # Update the database with edits made to an issue
    post "/edit/issue/?" do

    end

    # Delete an issue along with its attachments from database and filesystem
    post "/delete/issue/?" do
        Issue.delete(app: self, user: @user, params: params)
        redirect "/issues"
    end

    # List all FAQ articles
    get "/faq/?" do
        @articles = Faq.all
        slim :faq
    end

    get "/view/faq/:uuid/?" do |uuid|
        unless @article
            status 404
            slim :error
        end

        @answer = Kramdown::Document.new(@article.answer, :input => 'markdown').to_html
        slim :faq_article
    end

    post "/delete/faq/?" do
        faq = Faq.delete(app: self, user: @user, params: params)
        redirect "/faq"
    end

    # Other
    get "/conditions/?" do
        slim :conditions
    end

end
