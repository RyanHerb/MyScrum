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

    get '/projects/:id/users/add' do |i|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == i.to_i
          arr << p
        end
        arr
      end
      @project = @project.first

      @owners = Owner.all.inject([]) do |arr2, o|
        unless o.projects.include?(@project)
          arr2 << o
        end
        arr2
      end
      haml :"/projects/users"
    end

    post '/projects/:id/users/add' do |i|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == i.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      @owner = Owner.all.inject([]) do |arr2, o|
        if o.pk == params[:owner].to_i
          arr2 << o
        end
        arr2
      end
      @owner = @owner.first

      if @owner.valid?
        @project.add_user(@owner)
      else
        puts "FAIL"
      end
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
      @bite.set(params[:bite])
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

    post '/projects/:pid/remove_user/:oid' do |pid, oid|
      @project = Project.find(:id => pid)
      @owner = Owner.find(:id => oid)
      @project.remove_user(@Owner)
    end

  end
end
