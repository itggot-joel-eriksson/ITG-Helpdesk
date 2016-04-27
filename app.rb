class App < Sinatra::Base
    enable :sessions
    use Rack::Flash
    register Sinatra::Partial
    set :partial_template_engine, :slim

    before do
        if session.has_key?(:credentials) && session.has_key?(:google_user)
            @google_user = session[:google_user]
            unless @google_user["hd"] == "itggot.se"
                session.destroy
                halt 403
            else
                @user = User.first(email: @google_user["email"])
                unless @user
                    session.destroy
                    halt 403
                else
                    @user.update(name: @google_user["name"], avatar: @google_user["picture"])
                    session[:id] = @user.id
                end
            end
        elsif request.path_info != "/oauth2callback"
            redirect "/oauth2callback"
        end
    end

    get "/?" do
        # redirect "/issues"
        slim :index
    end

    # Sign in
    get "/oauth2callback/?" do
        #User.sign_in(app: self)
        client_secrets = Google::APIClient::ClientSecrets.load
        auth_client = client_secrets.to_authorization
        auth_client.update!(
            scope: ["https://www.googleapis.com/auth/plus.me", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"],
            redirect_uri: url("/oauth2callback")
        )
        if request[:code] == nil
            auth_uri = auth_client.authorization_uri.to_s
            redirect auth_uri
        else
            auth_client.code = request[:code]
            auth_client.fetch_access_token!
            auth_client.client_secret = nil
            session[:credentials] = auth_client.to_json

            access_token = auth_client.access_token.to_s
            usr_info = Unirest.get "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}"
            session[:google_user] = usr_info.body
            unless usr_info.body["hd"] == "itggot.se"
                Unirest.get "https://accounts.google.com/o/oauth2/revoke", params: { :token => access_token }
                session[:google_user] = nil
                redirect "/"
            else
                redirect "/"
            end
        end
    end

    # Sign out
    get "/signout" do
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

    # CRUD about issues
    get "/issues/?" do
        @issues = Issue.all
        slim :issues
    end

    get "/view/category/:id/issues/?" do |id|
        @category = Category.get(id) #include :issues
        @issues = @category.issues
        unless @issues
            status 404
            slim :error
        else
            slim :issues
        end
    end

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
            @uploads = Upload.all issue_id: @issue.id
            slim :issue
        end
    end

    get "/create/issue/?" do
        @categories = Category.all order: [:title.asc]
        slim :create_issue
    end

    post "/create/issue/?" do
        if params[:category]
            for category in params[:category] do
                puts category
            end
        end

        issue = Issue.create uuid: SecureRandom.uuid, title: params[:title], description: params[:description], user_id: 1
        unless issue.valid?
            flash[:error] = issue.errors.to_h
            redirect back
        else
            #Attachment.upload(app: self, params: params)

            #class Attachment

            # def self.upload(app:, params:)

            if params[:files]
                for file in params[:files] do
                    tmpfile = file[:tempfile]
                    name = file[:filename]

                    filename = SecureRandom.urlsafe_base64
                    extname = File.extname(name)

                    unless Dir.exist?("uploads")
                        Dir.mkdir("uploads")
                    end

                    unless Dir.exist?("uploads/#{@user.uuid}")
                        Dir.mkdir("uploads/#{@user.uuid}")
                    end

                    while payload = tmpfile.read(65536)
                        File.open("uploads/#{@user.uuid}/#{filename}#{extname}", "a+") do |file|
                            file.write(payload)
                        end
                    end

                    Upload.create uuid: SecureRandom.uuid, file: "/uploads/#{@user.uuid}/#{filename}#{extname}", issue_id: issue.id, user_id: @user.id
                end
            end
        end
        redirect "/issues"
    end

    get "/edit/issue/?" do

    end

    post "/edit/issue/?" do

    end

    post "/delete/issue/?" do
        Issue.first(id: params[:issue]).destroy
        redirect "/issues"
    end

    # CRUD about FAQ articles and categories
    get "/faq/?" do
        @articles = Faq.all
        slim :faq
    end

    get "/view/faq/:uuid/?" do |uuid|
        begin
            @article = Faq.first uuid: uuid
        rescue ArgumentError
            status 404
            slim :error
        end

        unless @article
            status 404
            slim :error
        else
            @answer = Kramdown::Document.new(@article.answer, :input => 'markdown').to_html
            slim :faq_article
        end
    end

    post "/delete/faq/?" do
        Faq.first(id: params[:faq]).destroy
        redirect "/faq"
    end

    # Other
    get "/conditions/?" do
        slim :conditions
    end

end
