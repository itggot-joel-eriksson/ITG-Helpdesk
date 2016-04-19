class App < Sinatra::Base
    enable :sessions

    get '/' do
        slim :index
    end

    get "/issues" do
        @issues = Issue.all
        slim :issues
    end

    get "/view/issue/:issue" do |issue|
        @issue = Issue.first(id: issue)
        unless @issue
            status 404
            body "Uh-oh 404!"
        else
            slim :issue
        end
    end

    get "/create/issue" do
        slim :create_issue
    end

    post "/create/issue" do
        Issue.create title: params[:title], description: params[:description], user_id: 1
        redirect "/issues"
    end

    get "/faq" do
        @articles = FAQ.all
        slim :faq
    end

    get "/view/faq/:article" do |article|
        @article = FAQ.first(id: article)
        unless @article
            status 404
            slim :error
        else
            slim :faq_article
        end
    end

end
