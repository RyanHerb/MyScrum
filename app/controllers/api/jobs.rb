module MyScrum
  class ApiApp

    get '/owner/projects/:pid/sprints/:sid/jobs' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_stories = @project.user_stories

      @jobs = @user_stories.inject({}) do |a, u|
        if a[u.pk].nil?
          a[u.pk] = {}
        end
        if a[u.pk]['all'].nil?
          a[u.pk]['all'] = []
        end
        if a[u.pk]['done'].nil?
          a[u.pk]['done'] = []
        end
        if a[u.pk]['todo'].nil? 
          a[u.pk]['todo'] = []
        end
        if a[u.pk]['in_progress'].nil? 
          a[u.pk]['in_progress'] = []
        end
        a[u.pk]['all'] << u.jobs.inject([]){|arr, j| arr << j.to_json; arr}
        a[u.pk]['done'] << u.jobs_dataset.done.all.inject([]){|arr, j| arr << j.to_json; arr}
        a[u.pk]['todo'] << u.jobs_dataset.todo.all.inject([]){|arr, j| arr << j.to_json; arr}
        a[u.pk]['in_progress'] << u.jobs_dataset.in_progress.all.inject([]){|arr, j| arr << j.to_json; arr}

        a[u.pk]['all'].flatten!
        a[u.pk]['done'].flatten!
        a[u.pk]['todo'].flatten!
        a[u.pk]['in_progress'].flatten!

        a
      end

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