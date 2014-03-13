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
          unless u.pk == @current_owner.pk
            notif = Notification.new
            notif.set({:action => "new", :type => "sprint", :owner_id => u.pk, :id_object => @sprint.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{i}/sprints/#{@sprint.pk}/show", :params => {:project => @project.title}.to_json})
            notif.save
          end
        end
        redirect "owner/projects/#{@project.pk}/show#tab3"
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
      @difficulty = 0
      @user_stories.each do |u|
        u.jobs.each do |j|
          @difficulty += j.difficulty.to_i
        end
      end
      haml :"/sprints/show"
    end

    post '/projects/:pid/sprints/:sid/close' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = Sprint.find(:id => sid)

      unless @sprint.commit.nil?
        redirect "owner/projects/#{@project.pk}/show#tab3"
      end

      if params[:commit].start_with?("http://") or params[:commit].start_with?("https://")
        @sprint.commit = params[:commit]
      elsif params[:commit].eql?("None")
        @sprint.commit = "none"
      else
        @sprint.commit = "http://" + params[:commit]
      end
      
      @sprint.save
      @project = Project.find(:id => pid)
      @project.users.each do |u|
        unless u.pk == @current_owner.pk
          notif = Notification.new
          notif.set({:action => "closed", :type => "sprint", :owner_id => u.pk, :id_object => @sprint.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/sprints/#{@sprint.pk}/show", :params => {:date => @sprint.start_date, :project => @project.title}.to_json})
          notif.save
        end
      end

      redirect "owner/projects/#{@project.pk}/show#tab3"
    end

    # ========
    # = Edit =
    # ========

    get '/projects/:pid/sprints/:sid/edit' do |i,j|
      @sprint = Sprint.find(:id => j)
      @project = Project.find(:id => i)
      @user_stories = @project.user_stories
      @us = @sprint.user_stories.inject([]) do |arr, o|
        arr << o.pk
        arr
      end
      haml :"/sprints/edit"
    end

    put '/projects/:pid/sprints/:sid/edit' do |i,j|
      @project = Project.find(:id => i)
      @user_stories = params[:userstories]
      @sprint = Sprint.find(:id => j)
      @date = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      @sprint.set(params[:sprint])
      @sprint.start_date = @date
      if @sprint.valid?
        @sprint.save
        
        @project.users.each do |u|
          unless u.pk == @current_owner.pk
            notif = Notification.new
            notif.set({:action => "modified", :type => "sprint", :owner_id => u.pk, :id_object => @sprint.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{i}/sprints/#{@sprint.pk}/show", :params => {:date => @sprint.start_date, :project => @project.title}.to_json})
            notif.save
          end
        end
        @us = @sprint.user_stories.inject([]) do |arr, o|
          arr << o.pk
          arr
        end
        @user_stories.each do |i|
          unless @us.include?(i.to_i)
            @sprint.add_user_story(i)
          end
        end
        redirect "owner/projects/#{@project.pk}/show#tab3"
      else
        haml :"/sprints/form"
      end
    end

  end
end

