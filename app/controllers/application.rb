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
      @turing_test = TuringTest.new
      session[:turing_answer] = @turing_test.answer
      haml :signup
    end
      
    post '/users' do
      @user = User.new(params[:user])
      begin
        throw Exception if params[:turing_answer] != session[:turing_answer]
        @user.save
        session[:user] = @user.pk
        @current_user = @user
        flash[:notice] = "Account created."
        redirect '/'
      rescue
        @user.valid? if params[:turing_answer] != session[:turing_answer]
        @errors = @user.errors
        @errors[:turing_answer] = "Your answer is incorrect. Please try again" if params[:turing_answer] != session[:turing_answer]
        @turing_test = TuringTest.new
        session[:turing_answer] = @turing_test.answer
        haml :signup
      end
    end

    # ===========
    # = The End =
    # ===========

  end
end
