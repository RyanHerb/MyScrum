

module MyScrum
  class RegisterApp < Sinatra::Application
    set :views, ROOT_DIR + "/app/views/user"
    register Sinatra::Flash

    # =============
    # = /signup =
    # =============
    
    get '/' do
      @user = User.new
      @turing_test = TuringTest.new
      session[:turing_answer] = @turing_test.answer
      haml :register
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
        haml :register
      end
    end
  end
end
