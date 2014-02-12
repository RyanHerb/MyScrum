# require /user
# load controllers


module MyScrum
  class UserApp < Sinatra::Application
    
    Dir[ROOT_DIR + '/app/controllers/user/*.rb'].sort.each {|file| require file }
    
    set :views, ROOT_DIR + "/app/views/user"
    register Sinatra::Flash
    
    # ==========
    # = Errors =
    # ==========

    error 401 do
      redirect '/user/login'
    end

    not_found do
      haml :'404'
    end

    before do
      
      protected!(:user) unless ['/login', '/send_password_reset', '/reset_password'].include?(request.path_info)
      
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
      puts "post to /user/login"
      @title = "Login"
      if authenticate!(:user)
        puts "authenticated"
        if session[:return_to] && session[:return_to] !~ /login/
          redirect "/user#{session.delete(:return_to)}"
        else
          redirect '/'
        end
      else
        @error = "Invalid username or password. Please try again."
        haml :login, :layout => false
      end
    end

    get '/logout' do
      logout(:user)
      redirect '/'
    end

    # ========================
    # = User Settings =
    # ========================

    get '/profile' do
      @user = @current_user
      haml :index, :layout => false
    end

    get '/profile/form' do
      @user = @current_user
      haml :form, :layout => false
    end

    put '/profile/form' do
      @current_user.set(params[:user]) 
      @current_user.save
      flash[:notice] = "Account Updated"
      redirect '/'
    end



    # ========================
    # = Owner password reset =
    # ========================

    post '/send_password_reset' do
      #@owner = Owner.find(:email => params[:email])
      #unless @owner.blank?
        # @owner.generate_auth_token
      #    mail(:name => @owner.name,
          
       #  :email => @owner.email,
         #    :subject => "Reset your password",
        #     :body => haml(:"mail/password_reset", :layout => false))
        #{}"OK"
      #end
    end

    get '/reset_password' do 
      #unless(@owner = Owner.auth_with_token(params[:t]))
       # flash[:alert] = 'Invalid token, please request another'
        #redirect '/owner/login'
      #else
       # session[:owner] = @owner.pk
        #flash[:notice] = "You have been logged in, please change your password"
        #redirect '/owner/profile'
      #end
    end


    # ==============
    # = Owner area =
    # ==============

    #get '/' do
    #  puts session.inspect
    #  @proto_appointments = Appointment.active.filter(:owner_id => @current_owner.pk).filter("start_at is NULL and user_id is NULL and user_session_id is NULL and in_patient != true").count
    #  @next_appointment = @current_owner.appointments_dataset.future.order(:start_at).first
    #  haml :index
    #end


    #put '/update' do # update profile
#      puts params.inspect
 #     @current_owner.set(params[:owner]) 
  #    if @current_owner.valid?
   #     @current_owner.save
    #    flash[:notice] = "Details updated successfully"
     # else
      #  flash[:error] = "Error updating profile"
      #end
      #redirect '/owner/profile'
    #end 
  end
end
