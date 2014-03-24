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


    get '/sprints/:sid/burndown_charts/show' do |sid|
      @sprint = Sprint.find(:id => sid) || halt(404)
      @user_stories = @sprint.user_stories
      @sprint_difficulty = 0
      @user_stories.each do |u|
        u.jobs.each do |j|
          @sprint_difficulty += j.difficulty
        end
      end
      @remaining_difficulty = @sprint_difficulty
      @users = Owner.all

      @json_data = Array.new
      @users.each do |row|
        number_of_job_done = 0
        row.jobs_dataset.done.each do |j|
          number_of_job_done += j.difficulty
        end
        h = {:name => row.username, :num_jobs => number_of_job_done}
        @json_data << h
      end
      @json_data = @json_data.to_json


      #get BurnDownChart Data
      @burndown_chart_data = Array.new
      @burndown_chart_data << [0,@sprint_difficulty]
      @today_date = Date.today
      @date = @sprint.start_date.to_date
      
      @sprint.duration.times do |i|
        unless @date > @today_date
          @jobs_done = Array.new
          @user_stories.each do |u|
            u.jobs_dataset.done.each do |j|
              @jobs_done << j
            end
          end

          @tab = Array.new
          @tab = @jobs_done.select { |obj| obj.updated_at.to_date.to_s == @date.to_s }    
          sum_difficulty = 0
          @tab.each do |row|
            sum_difficulty += row.difficulty
          end
          @remaining_difficulty -= sum_difficulty
          @burndown_chart_data << [i+1, @remaining_difficulty]
          @date += 1
        end
      end
      haml :"/sprints/burndown_chart"
    end

  end
end