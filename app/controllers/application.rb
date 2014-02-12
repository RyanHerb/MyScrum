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
      @owner = Owner.new
      @turing_test = TuringTest.new
      session[:turing_answer] = @turing_test.answer
      haml :signup
    end
      
    post '/owners' do
      @owner = Owner.new(params[:owner])
      begin
        throw Exception if params[:turing_answer] != session[:turing_answer]
        @owner.save
        session[:owner] = @owner.pk
        @current_owner = @owner
        flash[:notice] = "Account created."
        redirect '/'
      rescue
        @owner.valid? if params[:turing_answer] != session[:turing_answer]
        @errors = @owner.errors
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
