module MyScrum
  class OwnerApp < Sinatra::Application

    #get '/projects/:pid/user_stories/:uid/jobs' do |pid, uid|
    #  @project = Project.find(:id => pid)
    #  @user_story = UserStory.find(:id => uid)
    #  @jobs = @user_story.jobs
    #  haml :"/jobs/index"
    #end

    get '/projects/:pid/jobs/create' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @job = Job.new
      haml :"/jobs/form"
    end

    get '/projects/:pid/user_stories/:uid/jobs/:tid/show' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:id => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)

      haml :"/jobs/show"
    end

    get '/projects/:pid/user_stories/:uid/jobs/:tid/edit' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:id => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)

      haml :"/jobs/form"
    end

    post '/projects/:pid/jobs' do |pid| 
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => params[:job][:user_story_id]).first || halt(404)
      @job = Job.new
      @job.set(params[:job])
      if @job.valid?
        @job.save
        @user_story.add_job(@job)
        redirect "/owner/projects/#{pid}"
      else
        haml :"jobs/form"
      end
    end

    put '/projects/:pid/user_stories/:uid/jobs/:tid/edit' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:id => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)
      @job.update(params[:job])
      if @job.valid?
        @job.save
        redirect "/projects/#{pid}"
      else
        haml :"/jobs/form"
      end
    end

    delete '/projects/:pid/user_stories/:uid/jobs/:tid/delete' do |pid, uid, tid|
      # TODO
    end

    post '/projects/:pid/user_stories/:uid/jobs/:tid/:state' do |pid, uid, tid, state|
      @project = @current_owner.projects_dataset.where(:projects__id => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)
      @job.update({:status => state})
      if @job.valid?
        @job.save
        "OK"
      else
        halt(404)
      end
    end

  end
end