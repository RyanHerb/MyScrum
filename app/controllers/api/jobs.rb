module MyScrum
  class ApiApp

    get '/owner/projects/:pid/sprints/:sid/jobs' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_stories = @project.user_stories

      @jobs = @user_stories.inject({}) do |a, u|
        if a['all'].nil?
          a['all'] = []
        end
        if a['done'].nil?
          a['done'] = []
        end
        if a['todo'].nil? 
          a['todo'] = []
        end
        if a['in_progress'].nil? 
          a['in_progress'] = []
        end
        a['all'] << u.jobs.inject([]){|a, j| a << j.to_json; a}
        a['done'] << u.jobs_dataset.done.all.inject([]){|a, j| a << j.to_json; a}
        a['todo'] << u.jobs_dataset.todo.all.inject([]){|a, j| a << j.to_json; a}
        a['in_progress'] << u.jobs_dataset.in_progress.all.inject([]){|a, j| a << j.to_json; a}
        a
      end
      @jobs['all'].flatten!
      @jobs['done'].flatten!
      @jobs['todo'].flatten!
      @jobs['in_progress'].flatten!

      response = @jobs.to_json
    end

    get '/owner/projects/:pid/sprints/:sid/jobs/:state' do |pid, state|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_stories = @project.user_stories

      @jobs = @user_stories.inject([]) do |a, u|
        case state
        when 'done'
          a << u.jobs_dataset.done.all
        when 'in_progress'
          a << u.jobs_dataset.done.all
        when 'todo'
          a << u.jobs_dataset.done.all
        else
          halt(404)
        end
        a.flatten
      end
      response = @jobs.inject([]) do |a, j|
        a << j.to_json
        a
      end
      response.to_json
    end

  end
end