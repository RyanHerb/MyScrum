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
      @date = DateTime.new(params[:sprint][:year].to_i, params[:sprint][:month].to_i, params[:sprint][:day].to_i)
      params[:sprint].delete("day")
      params[:sprint].delete("month")
      params[:sprint].delete("year")
      @sprint.set(params[:sprint])
      @sprint.start_date = @date
      if @sprint.valid?
        @sprint.save
        @user_stories.each do |i|
          @sprint.add_user_story(i)
        end
        @project.add_sprint(@sprint)
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/sprints/form"
      end
    end

    # ========
    # = Show =
    # ========

    get '/projects/:pid/sprints/:sid/show' do |i,j|
      @tasks = Task.new
      @sprint = Sprint.find(:id => j)
      @project = Project.find(:id => i)
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
      @date = DateTime.new(params[:sprint][:year].to_i, params[:sprint][:month].to_i, params[:sprint][:day].to_i)
      params[:sprint].delete("day")
      params[:sprint].delete("month")
      params[:sprint].delete("year")
      @sprint.set(params[:sprint])
      @sprint.start_date = @date
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

