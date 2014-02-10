# Everything under the path /admin (see config.ru)

# require 'admin/'
# load "controllers"

# Dir[ROOT_DIR + '/app/controllers/admin/*.rb'].sort.each {|file| require file }



module MyScrum
  class AdminApp < Sinatra::Application
    set :views, ROOT_DIR + "/app/views/admin"
    register Sinatra::Flash
    
    
    # include AdminProceduresController

    
    error 401 do
      #"401 here, which must mean you're not authorized"
      redirect '/admin/login'
    end
    
    not_found do
      haml :'404'
    end

    before do
      show_me params.inspect
      protected!(:user) unless ['/login'].include?(request.path_info)
      # set the empty breadcrumb array
      @breadcrumbs = []
    end
    



    get '/login' do
      @title = "Login"
      haml :login, :layout => false
    end

    post '/login' do
      @title = "Login"
      if authenticate!(:user)
        if session[:return_to] && session[:return_to] !~ /login/
          redirect "/admin#{session.delete(:return_to)}"
        else
          redirect '/admin'
        end
      else
        @error = "Incorrect username or password. Please try again."
        haml :login, :layout => false
      end
    end

    get '/logout' do
      logout(:user)
      redirect '/'
    end

    get '/return' do
      @current_owner = nil
      session[:owner] = nil
      redirect '/admin'
    end
    
    # =====================
    # = other controllers =
    # =====================

    Dir[ROOT_DIR + '/app/controllers/admin/*.rb'].sort.each {|file| require file }
    
  end
  
end
