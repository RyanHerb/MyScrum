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
      @tests = @project.user_stories.inject([]) do |arr, us|
        arr << us.tests
      end.flatten
      haml :"projects/show"
    end

    get '/projects/:id/edit' do |id|
      @project = Project.find(:id => id) || halt(404)
      haml :"projects/form"
    end

    post '/projects/:id/add_developers' do |id|
      @project = Project.find(:id => id) || halt(404)
      params[:role].each do |r|
        @owner = Owner.find(:username => r[0]) || halt(404)
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => r[1])
      end
      "OK"
    end

    post '/project_owners' do
      project = Project.find(:id => params[:project_id]) || halt(404)
      owners = project.users
      response = owners.inject([]){ |arr, o| arr << o.to_json; arr}.join(', ')
      '[' << response << ']'
    end

    post '/project_user_stories' do
      project = Project.find(:id => params[:project_id]) || halt(404)
      user_stories = project.user_stories
      response = user_stories.inject([]){ |arr, us| arr << us.to_json; arr}.join(', ')
      '[' << response << ']'
    end

  end
end