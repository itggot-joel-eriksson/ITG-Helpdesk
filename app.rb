class App < Sinatra::Base
    enable :sessions
    use Rack::Flash
    register Sinatra::Partial
    set :partial_template_engine, :slim

    before do
        if session.has_key?(:credentials)
        elsif request.path_info != "/oauth2callback"
            redirect "/oauth2callback"
        end
    end

    get "/?" do
        # redirect "/issues"
        slim :index
    end

    get "/oauth2callback/?" do
        client_secrets = Google::APIClient::ClientSecrets.load
        auth_client = client_secrets.to_authorization
        auth_client.update!(
            scope: "https://www.googleapis.com/auth/plus.me",
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
            redirect "/"
        end
    end

    get "/user/set/:id" do |id|
        session[:id] = id
        redirect "/issues"
    end

    # CRUD about issues
    get "/issues/?" do
        @user = User.first id: session[:id]
        @issues = Issue.all
        slim :issues
    end

    get "/view/issue/:uuid/?" do |uuid|
        @user = User.first id: session[:id]
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
            slim :issue
        end
    end

    get "/create/issue/?" do
        @user = User.first id: session[:id]
        slim :create_issue
    end

    post "/create/issue/?" do
        issue = Issue.create title: params[:title], description: params[:description], user_id: 1
        if !issue.valid?
            flash[:error] = issue.errors.to_h
            redirect back
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
        @user = User.first id: session[:id]
        @articles = Faq.all
        slim :faq
    end

    get "/view/faq/:uuid/?" do |uuid|
        @user = User.first id: session[:id]
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
            slim :faq_article
        end
    end

    post "/delete/faq/?" do
        Faq.first(id: params[:faq]).destroy
        redirect "/faq"
    end

end
