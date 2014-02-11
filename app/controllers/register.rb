

module MyScrum
  class RegisterApp < Sinatra::Application
    set :views, ROOT_DIR + "/app/views/user"
    register Sinatra::Flash

    # =============
    # = /signup =
    # =============
    
    get '/' do
      @user = User.new
      haml :register
    end
      
    post '/' do
      @user = User.new(params[:user])
      @user.save
      session[:user] = @user.pk
      @current_user = @user
      flash[:notice] = "Account created."
      redirect '/'
    end

  end
end
