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
      @Users = Owner.all
      sortie = Tempfile.new(['data', '.csv'], ROOT_DIR + '/public/data')
      #jsondata = Tempfile.new(['data', '.json'],ROOT_DIR + '/public/data')
      @data_name = sortie.path.split("/").last

      @csv = Array.new
      @Users.each do |row|
        number_of_job_done = 0
        row.jobs_dataset.done.each do |j|
          number_of_job_done += j.difficulty
        end
        h = {:name => row.username, :num_jobs => number_of_job_done}
        @csv << h
      end
      @csv = @csv.to_json

      # sprint_end = @sprint.start_date.to_date + @sprint.duration

      # timeDomain = []

      # timeDomain << @sprint.start_date.to_date.to_s

      # tab = ["start","end","sprint_difficulty","timeDomain"]
     
      # @sprint.duration.times do |i|
      #   add = @sprint.start_date.to_date + (i+1)
      #   timeDomain << add.to_s
      # end

      # hashmap = {:start => @sprint.start_date.to_date, :end => sprint_end, :sprint_difficulty => @sprint_difficulty, :timeDomain => timeDomain}
      
      # File.open(jsondata.path, 'w') do |f|
        
      #   f.puts JSON.pretty_generate(hashmap)
      # end
      haml :"/burndown_chart/show"
    end
  end
end