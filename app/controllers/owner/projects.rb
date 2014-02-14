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

  end
end
