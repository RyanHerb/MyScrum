module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
    end

    get '/projects/:id/show' do |i|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == i.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      @team = @project.users
      haml :"/projects/show"
    end

    get '/projects/:id/edit' do |i|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == i.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      haml :"/projects/edit"
    end

    get '/projects/create' do
      @project = Project.new
      haml :"/projects/edit"
    end

    post '/projects' do
      @project = Project.new
      @project.set(params[:project])
      if @project.valid?
        @project.save
        @current_owner.add_project(@project)
        flash[:notice] = "Project created"
        redirect "/owner/projects"
      else
        haml :"/projects/edit"
      end 
    end

    put '/projects/:id' do |id|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == id.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      @project.set(params[:project])
      if @project.valid?
        @project.save
        flash[:notice] = "Project updated"
        redirect '/owner/projects'
      else
        haml :"/projects/edit"
      end
    end

    post '/projects/:pid/remove_owner/:oid' do |pid, oid|
      @project = Project.find(:id => pid)
      @owner = Owner.find(:id => oid)
      @project.remove_user(@Owner)
    end

    get '/projects/:id/sprint_create' do 
      @sprint = Sprint.new
      haml :"/projects/sprint_create"
    end

    post '/projects/:id/sprints/:id' do |id|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == id.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      @sprint = Sprint.new
      @sprint.set(params[:sprint])
      if @sprint.valid?
        @sprint.save
        @project.add_sprint(@sprint)
        redirect "/projects/show"
      else
        haml :"/projects/sprint_create"
      end
    end

  end
end
