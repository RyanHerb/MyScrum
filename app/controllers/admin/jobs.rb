module MyScrum
  class AdminApp

    get '/jobs' do
      @jobs = Job.all
      haml :"jobs/list"
    end

    post '/jobs' do
      @job = Job.new
      @job.set(params[:job])
      if @job.valid?
        @job.save
        redirect '/admin/jobs'
      else
        haml :"jobs/form"
      end
    end

    get '/jobs/new' do
      @job = Job.new
      @user_stories = UserStory.all
      haml :"jobs/form"
    end

    put '/jobs/:id' do |id|
      @job = Job.find(:id => id) || halt(404)
      @user_stories = UserStory.all
      @job.set(params[:job])
      if @job.valid?
        @job.save
        redirect '/admin/jobs'
      else
        haml :"jobs/form"
      end
    end

    get '/jobs/:id/show' do |id|
      @job = Job.find(:id => id) || halt(404)
      haml :"jobs/show"
    end

    get '/jobs/:id/edit' do |id|
      @job = Job.find(:id => id) || halt(404)
      @user_stories = UserStory.all
      haml :"jobs/form"
    end

    post '/jobs/:tid/update_devs' do |tid|
      @job = Job.find(:id => tid) || halt(404)
      @job.remove_all_owners
      response = Array.new
      unless params[:dev].nil?
        params[:dev].each do |dev|
          @dev = Owner.find(:id => dev) || halt(404)
          if @job.valid?
            unless @job.owners.include? @dev
              response << @dev.username
              @job.add_owner(dev)
            end
          else
            return "NOT OK"
          end
        end
      end
      response.to_json
    end

    post '/jobs/:tid/:state' do |tid, state|
      @job = Job.find(:id => tid) || halt(404)
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