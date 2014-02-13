module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
    end

    get '/projects/:id/show' do |id|
      @project = @current_owner.projects.inject(nil) do |n, p|
        if p.id == id
          return p
        end
      end
      haml :"/projects/show"
    end

    get '/projects/:id/edit' do |id|
      @project = @current_owner.projects.inject(nil) do |n, p|
        if p.id == id
          return p
        end
      end
      haml :"/projects/edit"
    end

  end
end