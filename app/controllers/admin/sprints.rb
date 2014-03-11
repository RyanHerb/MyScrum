require 'date'
module MyScrum
  class AdminApp

    get '/sprints' do
      @sprints = Sprint.all
      haml :"sprints/list"
    end

    get '/sprints/:sid/show' do |sid|
      @sprint = Sprint.find(:id => sid)
      @user_stories = @sprint.user_stories
      @sprint_difficulty = 0
      @user_stories.each do |u|
        u.jobs.each do |j|
          @sprint_difficulty += j.difficulty
        end
      end
      haml :"/sprints/show"
    end

    get '/sprints/:sid/edit' do |j|
      @sprint = Sprint.find(:id => j)
      @project = @sprint.project
      @user_stories = @sprint.user_stories
      haml :"/sprints/form"
    end

    put '/sprints/:sid/edit' do |j|
      @sprint = Sprint.find(:id => j)
      @user_stories = params[:userstories]
      @project = @sprint.project
      @date = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      @sprint.set(params[:sprint])
      if @sprint.valid?
        @sprint.save
        @sprint.remove_all_ user_stories
        @user_stories.each do |i|
          @sprint.add_user_story(i)
        end
        redirect "admin/sprints/#{@sprint.pk}/show"
      else
        haml :"/sprints/form"
      end
    end
  end
end