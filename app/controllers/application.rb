# ====================
# = Main Application =
# ====================

module MyScrum
  class Main < Sinatra::Application
    
    set :views, ROOT_DIR + "/app/views"
    register Sinatra::Flash

    # ==========
    # = Errors =
    # ==========

    not_found do
      haml :'404'
    end

    # ==========
    # = Styles =
    # ==========

    get '/css/:stylesheet.css' do |stylesheet|
      content_type 'text/css', :charset => 'utf-8'
        sass :"css/#{stylesheet}"
    end

    # =====
    # = / =
    # =====

    get '/' do
      haml :index
    end

    get '/signup' do
      @user = User.new
      haml :register
    end
      
    post '/owners' do
      @user = User.new(params[:user])
      @user.save
      session[:user] = @user.pk
      @current_user = @user
      flash[:notice] = "Account created."
      redirect '/'
    end

    # ===========
    # = The End =
    # ===========

  end
end
