class App < Sinatra::Base
    enable :sessions
    use Rack::Flash
    register Sinatra::Partial
    set :partial_template_engine, :slim

    get "/?" do
        slim :index
    end

    # CRUD about issues
    get "/issues/?" do
        @issues = Issue.all
        slim :issues
    end

    get "/view/issue/:issue/?" do |issue|
        @issue = Issue.first(uuid: issue)
        unless @issue
            status 404
            slim :error
        else
            slim :issue
        end
    end

    get "/create/issue/?" do
        slim :create_issue
    end

    post "/create/issue/?" do
        issue = Issue.create title: params[:title], description: params[:description], user_id: 1
        if !issue.valid?
            flash[:error] = issue.errors.to_h
        end
        redirect back
        # redirect "/issues"
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
            status 500
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
