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

  end
end