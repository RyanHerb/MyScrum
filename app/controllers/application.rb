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

      haml :index
    end

    get '/live' do
      @notif = []
      @today = Time.new
      if session[:owner]
        @owner = Owner.find(:id => session[:owner])
        @notif = @owner.notifications
        @notif.each do |n|
          if n.viewed < 2
            n.viewed = n.viewed+1
            n.save
          end
        end
        @full_notif = Array.new
        @notif_sort = @notif.sort! { |x, y| y.date <=> x.date }
        @notif_sort.each do |n|
          if Date.parse(n.date.strftime("%Y-%m-%d")) < Date.today
            date = n.date.strftime("%d/%m")
          else
            date = n.date.strftime("%H:%M")
          end
          
          str = date + " - "
          if n.params.nil?
            param_notif = {}
          else
            param_notif = JSON.parse(n.params)
          end

          if n.action.eql?("affectation")
            str += "You have been assigned to a new " + n.type + " \"" + param_notif["name"].to_s + "\"."

          elsif n.action.eql?("modification")
            str += "The " +n.type + " \""+ param_notif["name"].to_s + "\" has been modified."

          elsif n.action.eql?("project owner") || n.action.eql?("scrum master") || n.action.eql?("developer")
            str += "You have been assigned to the project \"" + param_notif["project"].to_s + "\" as a " + n.action + "."

          elsif n.action.eql?("remove")
            str += "The " + n.type  + " \""+ param_notif["name"].to_s + "\" has been removed from the project \"" + param_notif["project"].to_s + "\"."

          elsif n.action.eql?("removed")
            if n.type.eql?("project")
              str += "You have been removed from the project \"" + param_notif["project"].to_s + "\"."
            elsif n.type.eql?("test")
              str += "You are not assigned to the test \"" + param_notif["name"].to_s + "\" anymore."
            end

          elsif n.action.eql?("state")
            str += "The state of the job \"" + param_notif["name"].to_s + "\" has been modified."

          elsif n.action.eql?("closed")
            str += "The sprint started the " + Date.parse(param_notif["date"]).strftime("%Y-%m-%d") + " in the project \"" + param_notif["project"] + "\" has been closed."

          elsif n.action.eql?("new")
            if n.type.eql?("scrum master") or n.type.eql?("project owner")
              str += "\"" + param_notif["name"].to_s + "\" is the new " + n.type.capitalize + " of the project \"" + param_notif["project"].to_s + "\"."  
            elsif
              str_prefix = "A new " + n.type.capitalize
              str_suffix = ""
              if n.type.eql?("collaborator")
                str_prefix = param_notif["name"].to_s
              end
              str += str_prefix + " has been added to the project \"" + param_notif["project"].to_s + "\"."
            end
          elsif n.action.eql?("modified")
            if n.type.eql?("project")
              str += "The project \"" + param_notif["project"].to_s + "\" has been modified."
            elsif n.type.eql?("sprint")
              str += "The sprint started the " + Date.parse(param_notif["date"]).strftime("%Y-%m-%d") + " in the project \"" + param_notif["project"].to_s + "\" has been modified."
            else
              str += "The " + n.type + " \"" + param_notif["name"].to_s + "\" has been modified."
            end

          else
            str += n.action
          end

          @full_notif.push({:viewed => n.viewed, :message => str, :link => n.link})
        end

        @notif_sort = @notif.sort! { |x, y| y.date <=> x.date }
        if @notif_sort.count > 30
          @notif_sort.last(@notif_sort.count-30).each do |n|
            n.destroy()
          end
        end
      end
      haml :'live'
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

    # ========
    # = Ping =
    # ========

    get '/ping' do
      "OK"
    end

    # ===========
    # = The End =
    # ===========

  end
end
