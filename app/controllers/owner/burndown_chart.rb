require 'tempfile'
require 'fileutils'
require 'csv'
require 'json'
require 'date'

module MyScrum
  class OwnerApp < Sinatra::Application
    
    # ========
    # = Show =
    # ========
    get '/projects/:pid/sprints/:sid/burndown_chart/show' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = Sprint.find(:id => sid)
      @user_stories = @sprint.user_stories
      @sprint_difficulty = 0
      @user_stories.each do |u|
        u.jobs.each do |j|
          @sprint_difficulty += j.difficulty
        end
      end
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

      @burndown_chart_data = []

      @day_date = Date.today

      @sprint.duration.times do |i|
        tab = []
        tab << i
        tab << @sprint_difficulty
        @burndown_chart_data  << tab
      end

      @burndown_chart_data = [[0, 13], [1, 10], [2, 8], [3, 4], [4, 3], [5, 0]]     

      
      haml :"/burndown_chart/show"
    end
  end
end