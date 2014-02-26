module MyScrum
  class AdminApp

    get '/projects' do
      @projects = Project.all
      haml :"projects/list"
    end

    post '/projects' do
      @project = Project.new
      @project.set(params[:project])
      if @project.valid?
        @project.save
        redirect '/admin/projects'
      else
        haml :"projects/form"
      end
    end

    get '/projects/new' do
      @project = Project.new
      haml :"projects/form"
    end

    put '/projects/:id' do |id|
      @project = Project.find(:id => id) || halt(404)
      @project.set(params[:project])
      if @project.valid?
        @project.save
        redirect '/admin/projects'
      else
        haml :"projects/form"
      end
    end

    get '/projects/:id/show' do |id|
      @project = Project.find(:id => id) || halt(404)
      @user_stories = @project.user_stories
      @sprints = @project.sprints
      @team = @project.users
      haml :"projects/show"
    end

    get '/projects/:id/edit' do |id|
      @project = Project.find(:id => id) || halt(404)
      haml :"projects/form"
    end

    post '/projects/:id/add_developers' do |id|
      @project = Project.find(:id => id) || halt(404)
      params[:role].each do |r|
        @owner = Owner.find(:username => r[0])
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => r[1])
      end
      "OK"
    end

  end
end