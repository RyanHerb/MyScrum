module MyScrum
  class OwnerApp < Sinatra::Application

    # =============
    # = /projects =
    # =============

    get '/projects' do
      @projects = @current_owner.projects
      haml :"/projects/index"
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

    # ======================
    # = /projects/:id/show =
    # ======================

    get '/projects/:pid/show' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @team = @project.users
      @sprints = @project.sprints
      @roles = @project.users_dataset
      @user_stories = @project.user_stories
      @tests = []
      @user_stories.each do |u|
        @tests.concat(u.tests)
      end
      haml :"/projects/show"
    end


    # =========================
    # = /projects/:id/users/* =
    # =========================

    get '/projects/:id/users/add' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @project_owner = @project.users_dataset.where(:position => "project owner").first
      @scrum_master = @project.users_dataset.where(:position => "scrum master").first
      @owners = Owner.all.inject([]) do |arr, o|
        if @project.users_dataset.where(:user => o.pk).first.nil?
          arr << o
        end
        arr
      end
      haml :"/projects/users"
    end

    # =========================

    post '/projects/:id/users/project_owner' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
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
        @notif = Notification.new
        @notif.set({:action => "project owner", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{i}/show"})
        @notif.save
      end
      redirect "/owner/projects/#{@project.pk}/show"
    end

    # =========================

    post '/projects/:id/users/scrum_master' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
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
          @notif = Notification.new
          @notif.set({:action => "scrum master", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{i}/show"})
          @notif.save
          redirect "/owner/projects/#{@project.pk}/show"
        else
          redirect "/owner/projects/#{@project.pk}/users/add"
        end
      end
      
    end

    # =========================

    post '/projects/:id/users/add' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
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


    # ======================
    # = /projects/:id/edit =
    # ======================

    get '/projects/:id/edit' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      haml :"/projects/form"
    end

    get '/projects/create' do
      @project = Project.new
      haml :"/projects/form"
    end

    
    # =================
    # = /projects/:id =
    # =================

    put '/projects/:id' do |id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @project.set(params[:project])
      if @project.valid?
        @project.save
        flash[:notice] = "Project updated"
        redirect '/owner/projects'
      else
        haml :"/projects/form"
      end
    end

    # ==========
    # = Remove =
    # ==========

    get '/projects/:pid/remove_user/:oid' do |pid, oid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @owner = Owner.find(:id => oid)
      @project.remove_user(@owner)
      redirect "/owner/projects/#{@project.pk}/show"
    end

  end
end

