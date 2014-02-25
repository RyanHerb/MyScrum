module MyScrum
  class OwnerApp < Sinatra::Application
    
    # ========
    # = Show =
    # ========
    get '/projects/:pid/sprints/:sid/burndown_chart/show' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = Sprint.find(:id => sid)
      haml :"/burndown_chart/show"
    end
  end
end

