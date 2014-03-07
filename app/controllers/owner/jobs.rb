module MyScrum
  class OwnerApp < Sinatra::Application

    #get '/projects/:pid/user_stories/:uid/jobs' do |pid, uid|
    #  @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
    #  @user_story = UserStory.find(:id => uid)
    #  @jobs = @user_story.jobs
    #  haml :"jobs/index"
    #end

    get '/projects/:pid/jobs/create' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @job = Job.new
      haml :"jobs/form"
    end

    get '/projects/:pid/user_stories/:uid/jobs/:tid/show' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)

      haml :"jobs/show"
    end

    get '/projects/:pid/user_stories/:uid/jobs/:tid/edit' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)

      haml :"jobs/form"
    end

    post '/projects/:pid/jobs' do |pid| 
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => params[:job][:user_story_id]).first || halt(404)
      @job = Job.new
      @job.set(params[:job])
      if @job.valid?
        @job.save
        @user_story.add_job(@job)
        redirect "/owner/projects/#{pid}/show"
      else
        haml :"jobs/form"
      end
    end

    put '/projects/:pid/user_stories/:uid/jobs/:tid/edit' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)
      @job.update(params[:job])
      if @job.valid?
        @job.save
        redirect "/owner/projects/#{pid}/show"
      else
        haml :"jobs/form"
      end
    end

    delete '/projects/:pid/user_stories/:uid/jobs/:tid/delete' do |pid, uid, tid|
      # TODO
    end


    post '/projects/:pid/user_stories/:uid/jobs/:tid/update_devs' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)
      @job.remove_all_owners
      unless params[:dev].nil?
        params[:dev].each do |dev|
          @dev = @project.users_dataset.where(:user => dev).first || halt(404)
          if @job.valid?
            unless @job.owners.include? @dev
              @job.add_owner(dev)
              @notif = Notification.new
              @notif.set({:action => "affectation", :type => "job", :owner_id => @dev.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show"})
              @notif.save
            end
          else
            return "NOT OK"
          end
        end
      end
      "OK"
    end

    post '/projects/:pid/user_stories/:uid/jobs/:tid/:state' do |pid, uid, tid, state|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @job = @user_story.jobs_dataset.where(:id => tid).first || halt(404)
      if state == "inprogress"
        state = "in progress"
      end
      @job.set({:status => state})
      if @job.valid?
        @job.save
        "OK"
      else
        halt(404)
      end
    end
  end
end
