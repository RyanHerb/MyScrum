module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:pid/user_stories/:uid/tasks' do |pid, uid|
      @project = Project.find(:id => pid)
      @user_story = UserStory.find(:id => uid)
      @tasks = @user_story.tasks
      haml :"/tasks/index"
    end

    get '/projects/:pid/user_stories/:uid/tasks/create'  do |pid, uid|
      @task = Task.new
      haml :"/tasks/edit"
    end

    get '/projects/:pid/user_stories/:uid/tasks/:tid/show' do |pid, uid, tid|
      @project = Project.find(:id => pid)
      @user_story = UserStory.find(:id => uid)
      @task = Task.find(:id => tid)

      haml :"/tasks/show"
    end

    get '/projects/:pid/user_stories/:uid/tasks/:tid/edit' do |pid, uid, tid|
      @project = Project.find(:id => pid)
      @user_story = UserStory.find(:id => uid)
      @task = Task.find(:id => tid)

      haml :"/tasks/form"
    end

    post '/projects/:pid/user_stories/:uid/tasks' do |pid, uid| 
      @project = Project.find(:id => pid)
      @user_story = UserStory.find(:id => uid)
      @task = task.new
      @task.set(params[:tasks])
      if @task.valid?
        @task.save
        @user_story.add_task(@task)
        redirect "/projects/#{pid}"
      else
        haml :"tasks/form"
      end
    end

    put '/projects/:pid/user_stories/:uid/tasks/:tid/edit' do |pid, uid, tid|
      @project = Project.find(:id => pid)
      @user_story = UserStory.find(:id => uid)
      @task = Task.find(:id => tid)
      @task.update(params[:task])
      if @task.valid?
        @task.save
        @user_story.add_task(@task)
        redirect "/projects/#{pid}"
      else
        haml :"/tasks/form"
      end
    end

    delete '/projects/:pid/user_stories/:uid/tasks/:tid/delete' do |pid, uid, tid|
      # TODO
    end
  end
end