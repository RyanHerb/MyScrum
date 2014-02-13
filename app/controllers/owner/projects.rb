module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
    end

    get '/projects/:id/show' do |id|
      @project = @current_owner.projects.inject do |n, p|
        if p.id == id
          return p
        end
      end
      haml :"/projects/show"
    end

    get '/projects/:id/edit' do |id|
      @project = @current_owner.projects.inject do |n, p|
        if p.id == id
          return p
        end
      end
      haml :"/projects/edit"
    end

    get '/projects/create' do
      @project = Project.new
      #@project.set(params[:project])
      #@project.save
      haml :"/projects/edit"
    end

    post '/projects' do
      @project = Project.new
      @project.set(params[:project])
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
      @project.save
      redirect '/owner/projects'
    end

  end
end
