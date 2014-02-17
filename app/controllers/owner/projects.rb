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
        if @project.users.find_index(o).nil?
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
      
      if @owner.nil?
        unless @scrum_master.nil?
            @project.users_dataset.where(:user => @scrum_master.pk).update(:position => "developer")
        end
        redirect "/owner/projects/#{@project.pk}/show"
      else
        if @owner.valid?
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
      haml :"/projects/form"
    end

    get '/projects/create' do
      @project = Project.new
      haml :"/projects/form"
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
        haml :"/projects/form"
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
        haml :"/projects/form"
      end
    end

    delete '/projects/:pid/remove_user/:oid' do |pid, oid|
      @project = Project.find(:id => pid)
      @owner = Owner.find(:id => oid)
      @project.remove_user(@owner)
      redirect "/owner/projects/#{@project.pk}/show"
    end

  end
end
