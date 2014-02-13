module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
    end

    get '/projects/:id/show' do |i|
      @project = @current_owner.projects.find(:id => i).first
      haml :"/projects/show"
    end

    get '/projects/:id/edit' do |i|
      @project = @current_owner.projects.find(:id => i).first
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
        flash[:notice] = "Project created"
      else
        flash[:notice] = "Error creating project"
      end
      @project.save
      redirect "/owner/projects"
    end

    put '/projects/:id' do |id|
      @project = @current_owner.projects.inject do |n, p|
        if p.id == id
          return p
        end
      end
      @project.set(params[:project])
      if @project.valid?
        @project.save
        flash[:notice] = "Project updated"
      else
        flash[:notice] = "Error updating project"
      end
      redirect '/owner/projects'
    end

  end
end
