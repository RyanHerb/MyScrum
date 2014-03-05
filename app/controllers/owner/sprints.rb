require 'date'
module MyScrum
  class OwnerApp < Sinatra::Application

    # ==========
    # = Create =
    # ==========

    get '/projects/:id/sprint/create' do |i|
      @project = Project.find(:id => i)
      @sprint = Sprint.new
      @user_stories = @project.user_stories
      haml :"/sprints/form"
    end

    post '/projects/:id/sprint/create' do |i|
      @project = Project.find(:id => i)
      @user_stories = params[:userstories]
      @sprint = Sprint.new
      @date = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      @sprint.set(params[:sprint])
      @sprint.start_date = @date
      if @sprint.valid?
        @sprint.save
        @user_stories.each do |i|
          @sprint.add_user_story(i)
        end
        @project.add_sprint(@sprint)

        @project.users.each do |u|
          if u.pk != -1
            notif = Notification.new
            notif.set({:action => "new", :type => "sprint", :owner_id => u.pk, :id_object => @sprint.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{i}/show"})
            notif.save
          end
        end
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/sprints/form"
      end
    end

    # ========
    # = Show =
    # ========
    get '/projects/:pid/sprints/:sid/show' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = Sprint.find(:id => sid)
      @user_stories = @sprint.user_stories
      haml :"/sprints/show"
    end

    # ========
    # = Edit =
    # ========

    get '/projects/:pid/sprints/:sid/edit' do |i,j|
      @sprint = Sprint.find(:id => j)
      @project = Project.find(:id => i)
      @user_stories = @project.user_stories
      haml :"/sprints/edit"
    end

    put '/projects/:pid/sprints/:sid/edit' do |i,j|
      @project = Project.find(:id => i)
      @user_stories = params[:userstories]
      @sprint = Sprint.find(:id => j)
      @date = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      @sprint.set(params[:sprint])
      if @sprint.valid?
        @sprint.save
        @user_stories.each do |i|
          @sprint.add_user_story(i)
        end
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/sprints/form"
      end
    end

  end
end

