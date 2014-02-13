# require /owner
# load controllers


module MyScrum
  class OwnerApp < Sinatra::Application
    
    Dir[ROOT_DIR + '/app/controllers/owner/*.rb'].sort.each {|file| require file }
    
    set :views, ROOT_DIR + "/app/views/owner"
    register Sinatra::Flash
    
    # ==========
    # = Errors =
    # ==========

    error 401 do
      redirect '/owner/login'
    end

    not_found do
      haml :'404'
    end

    before do
      
      protected!(:owner) unless ['/login', '/send_password_reset', '/reset_password'].include?(request.path_info)
      
      show_me( params.inspect )
      show_me( session.inspect )
      
    end

    # ==========
    # = Styles =
    # ==========

    get '/css/:stylesheet.css' do |stylesheet|
      content_type 'text/css', :charset => 'utf-8'
      sass :"css/#{stylesheet}"
    end

    # =========
    # = Login =
    # =========
    
    get '/login' do
      haml :login, :layout => false
    end

    post '/login' do
      @title = "Login"
      if authenticate!(:owner)
        #if session[:return_to] && session[:return_to] !~ /login/
         # redirect "/owner#{session.delete(:return_to)}"
        #else
          redirect '/owner'
        #end
      else
        @error = "Invalid ownername or password. Please try again."
        haml :login, :layout => false
      end
    end

    get '/logout' do
      logout(:owner)
      redirect '/'
    end

    # ========================f
    # = Owner password reset =
    # ========================

    post '/send_password_reset' do
      @owner = Owner.find(:email => params[:email])
      unless @owner.blank?
        @owner.generate_auth_token
          mail(:name => @owner.name,
          
          :email => @owner.email,
             :subject => "Reset your password",
             :body => haml(:"mail/password_reset", :layout => false))
        "OK"
      end
    end

    get '/reset_password' do 
      unless(@owner = Owner.auth_with_token(params[:t]))
        flash[:alert] = 'Invalid token, please request another'
        redirect '/owner/login'
      else
        session[:owner] = @owner.pk
        flash[:notice] = "You have been logged in, please change your password"
        redirect '/owner/profile'
      end
    end


    # ==============
    # = Owner area =
    # ==============

    get '/' do
      puts session.inspect
      haml :index
    end

    get '/profile' do
      haml :form
    end

    put '/update' do
      puts session.inspect
      @current_owner.set(params[:owner])
      if @current_owner.valid?
        @current_owner.save
        flash[:notice] = "Account Updated"
      else
        flash[:notice] = "Error updating profile"
      end
      redirect '/owner/profile'
    end
  end
end
