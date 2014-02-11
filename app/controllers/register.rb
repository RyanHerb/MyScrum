

module MyScrum
  class RegisterApp < Sinatra::Application
    set :views, ROOT_DIR + "/app/views/user"
    register Sinatra::Flash

    # =============
    # = /signup =
    # =============
    
    get '/' do
      haml :register
    end
      

  end
end
