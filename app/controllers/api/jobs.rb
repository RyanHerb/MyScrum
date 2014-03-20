module MyScrum
  class ApiApp

    get '/owner/projects/:pid/sprints/:sid/jobs' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_stories = @project.user_stories

      @jobs = @user_stories.inject([]) do |a, u|
        a << u.jobs
        a.flatten
      end
      response = @jobs.inject([]) do |a, j|
        a << j.to_json
        a
      end
      response.to_json
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