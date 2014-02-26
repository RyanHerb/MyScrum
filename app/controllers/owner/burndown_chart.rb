require 'tempfile'
require 'fileutils'
require 'csv'

module MyScrum
  class OwnerApp < Sinatra::Application
    
    # ========
    # = Show =
    # ========
    get '/projects/:pid/sprints/:sid/burndown_chart/show' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = Sprint.find(:id => sid)
      @Users = Owner.all
      sortie = Tempfile.new(['data', '.csv'])
      @data_path = sortie.path

      CSV.open(sortie.path, 'ab') do |csv|
        csv << ["name","num_jobs"]
        @Users.each do |row|   
          h = {:name => row.username, :num_jobs => row.jobs.length}
          csv << h.values
        end
      end

      

      haml :"/burndown_chart/show"
    end
  end
end

