module MyScrum
  class ApiApp

    get '/owner/projects/:pid/sprints/:sid/jobs' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)
      @user_stories = @sprint.user_stories

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

    post '/owner/projects/:pid/sprints/:sid/jobs/create' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)
      @job = Job.new

      decoded_params = JSON.parse(params[:job])
      @job.set(decoded_params)
      if @job.valid?
        @job.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/sprints/:sid/jobs/:jid/edit' do |pid, sid, jid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)
      @job = @sprint.jobs_dataset.where(:id => jid).first || hatl(404)

      decoded_params = JSON.parse(params[:job])
      @job.set(decoded_params)
      if @job.valid?
        @job.save
        "OK"
      else
        "An error occured"
      end
    end

  end
end