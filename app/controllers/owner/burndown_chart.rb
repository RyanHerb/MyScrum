require 'json'
require 'date'

module MyScrum
  class OwnerApp
    
    
    # ========
    # = Show =
    # ========
    
    get '/projects/:pid/sprints/:sid/burndown_chart/show' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)

      @user_stories = @sprint.user_stories
      @sprint_difficulty = 0

      @user_stories.each do |u|
        u.jobs.each do |j|
          @sprint_difficulty += j.difficulty
        end
      end
      
      @remaining_difficulty = @sprint_difficulty
      @users = @project.users

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
          @tab = @jobs_done.select { |obj| obj.last_changed_at.to_date.to_s == @date.to_s }    
          sum_difficulty = 0
          @tab.each do |row|
            sum_difficulty += row.difficulty
          end
          @remaining_difficulty -= sum_difficulty
          @burndown_chart_data << [i+1, @remaining_difficulty]
          @date += 1
        end
      end
      haml :"/burndown_chart/show"
    end
  end
end