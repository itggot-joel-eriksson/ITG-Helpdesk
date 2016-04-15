class App < Sinatra::Base
  enable :sessions

  get '/' do
  	"Hello, Sinatra!"
  end


end