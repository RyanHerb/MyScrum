module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
    end

    get '/projects/:id/show' do |i|
      @project = Project.find(:id => i)
      @team = @project.users
      @roles = @project.users_dataset
      haml :"/projects/show"
    end

    get '/projects/:id/users/add' do |i|
      @project = Project.find(:id => i)
      @project_owner = @project.users_dataset.where(:position => "project owner").first
      @scrum_master = @project.users_dataset.where(:position => "scrum master").first
      @owners = Owner.all.inject([]) do |arr2, o|
        unless @project.users.include?(o)
          arr2 << o
        end
        arr2
      end
      haml :"/projects/users"
    end

    post '/projects/:id/users/project_owner' do |i|
      @project = Project.find(:id => i)
      @owner = Owner.all.inject([]) do |arr2, o|
        if o.pk == params[:owner].to_i
          arr2 << o
        end
        arr2
      end
      @owner = @owner.first
      @project_owner = @project.users_dataset.where(:position => "project owner").first
      if @owner.valid?
        unless @project_owner.nil?
          @project.users_dataset.where(:user => @project_owner.pk).update(:position => "developer")
        end
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => "project owner")
      end
      redirect "/owner/projects/#{@project.pk}/show"
    end

    post '/projects/:id/users/scrum_master' do |i|
      @project = Project.find(:id => i)
      @owner = Owner.all.inject([]) do |arr2, o|
        if o.pk == params[:owner].to_i
          arr2 << o
        end
        arr2
      end
      @owner = @owner.first
      @scrum_master = @project.users_dataset.where(:position => "scrum master").first
      if !@owner.nil? and @owner.valid?
        unless @scrum_master.nil?
          @project.users_dataset.where(:user => @scrum_master.pk).update(:position => "developer")
        end
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => "scrum master") 
        redirect "/owner/projects/#{@project.pk}/show"
      else
        redirect "/owner/projects/#{@project.pk}/users/add"
      end
      
    end



    post '/projects/:id/users/add' do |i|
      @project = Project.find(:id => i)
      @owner = Owner.all.inject([]) do |arr2, o|
        if o.pk == params[:owner].to_i
          arr2 << o
        end
        arr2
      end
      @owner = @owner.first

      if !@owner.nil? and @owner.valid?
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => "developer")
        redirect "/owner/projects/#{@project.pk}/show"
      else
        redirect "/owner/projects/#{@project.pk}/users/add"
      end
    end




    get '/projects/:id/edit' do |i|
      @project = Project.find(:id => i)
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
        @project.add_user(@current_owner)
        @project.users_dataset.where(:user => @current_owner.pk).update(:position => "project owner")
        flash[:notice] = "Project created"
        redirect "/owner/projects"
      else
        haml :"/projects/edit"
      end 
    end

    put '/projects/:id' do |id|
      @project = Project.find(:id => id)
      @project.set(params[:project])
      if @project.valid?
        @project.save
        flash[:notice] = "Project updated"
        redirect '/owner/projects'
      else
        haml :"/projects/edit"
      end
    end

    get '/projects/:pid/remove_user/:oid' do |pid, oid|
      @project = Project.find(:id => pid)
      @owner = Owner.find(:id => oid)
      @project.remove_user(@owner)
      redirect "/owner/projects/#{@project.pk}/show"
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
