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
      @projects = Project.all
      @public = @projects.inject([])  do |a,p|
        if p.public
          a << p
        end
        a
      end
      @notif = []
      if session[:owner]
        @owner = Owner.find(:id => session[:owner])
        @notif = @owner.notifications
      end
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

    # ========
    # = Bugs =
    # ========

    get '/bug_reports/form' do
      @bug_report = BugReport.new
      haml :"bug_reports/form"
    end

    post '/bug_reports/form' do
      @bug_report = BugReport.new
      @bug_report.set(params[:bug_report])
      if @bug_report.valid?
        @bug_report.save
        redirect "/"
      else
        haml :"bug_reports/form"
      end
    end

    # ===========
    # = The End =
    # ===========

  end
end
