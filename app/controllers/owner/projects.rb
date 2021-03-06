module MyScrum
  class OwnerApp

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
        @project.users_dataset.where(:user => @current_owner.pk).update(:position => "product owner")
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
      if @project.has_rights(@current_owner)
        @rights = true
      else
        @rights = false
      end
      @user_stories.each do |u|
        @tests.concat(u.tests)
      end
      haml :"/projects/show"
    end


    # =========================
    # = /projects/:id/users/* =
    # =========================

    get '/projects/:id/users/add' do |id|

      
      @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
      unless @project.has_rights(@current_owner)
        halt(404)
      end

      @product_owner = @project.users_dataset.where(:position => "product owner").first
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

    post '/projects/:id/users/product_owner' do |id|
      
      @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
      unless @project.has_rights(@current_owner)
        halt(404)
      end

      @owner = Owner.all.inject([]) do |arr2, o|
        if o.pk == params[:owner].to_i
          arr2 << o
        end
        arr2
      end
      @owner = @owner.first
      @product_owner = @project.users_dataset.where(:position => "product owner").first
      if @owner.valid?
        unless @product_owner.nil?
          @project.users_dataset.where(:user => @product_owner.pk).update(:position => "developer")
        end
        @project.remove_user(@owner)
        @project.add_user(@owner)
        @project.users_dataset.where(:user => @owner.pk).update(:position => "product owner")
        @notif = Notification.new
        @notif.set({:action => "product owner", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:project => @project.title}.to_json})
        @notif.save

        @project.users.each do |u|
          unless u.pk == @current_owner.pk or u.pk == @owner.pk
            @notif = Notification.new
            @notif.set({:action => "new", :type => "product owner", :owner_id => u.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:name => @owner.name, :project => @project.title}.to_json})
            @notif.save
          end
        end
        redirect "/owner/projects/#{@project.pk}/show#tab2"
      end
    end

      # =========================

      post '/projects/:id/users/scrum_master' do |id|
        @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
        unless @project.has_rights(@current_owner)
          halt(404)
        end

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
            @notif2 = Notification.new
            @notif2.set({:action => "developer", :type => "project", :owner_id => @scrum_master.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:project => @project.title}.to_json})
            @notif2.save
          end
          redirect "/owner/projects/#{@project.pk}/show#tab2"
        else
          if @owner.valid?
            unless @scrum_master.nil?
              @project.users_dataset.where(:user => @scrum_master.pk).update(:position => "developer")
              @notif2 = Notification.new
              @notif2.set({:action => "developer", :type => "project", :owner_id => @scrum_master.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:project => @project.title}.to_json})
              @notif2.save
            end
            @project.remove_user(@owner)
            @project.add_user(@owner)
            @project.users_dataset.where(:user => @owner.pk).update(:position => "scrum master") 
            @notif = Notification.new
            @notif.set({:action => "scrum master", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:project => @project.title}.to_json})
            @notif.save

            @project.users.each do |u|
              unless u.pk == @current_owner.pk or u.pk == @owner.pk
                @notif = Notification.new
                @notif.set({:action => "new", :type => "scrum master", :owner_id => u.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:name => @owner.name, :project => @project.title}.to_json})
                @notif.save
              end
            end
            redirect "/owner/projects/#{@project.pk}/show#tab2"
          else
            redirect "/owner/projects/#{@project.pk}/users/add"
          end
        end
        
      end

      # =========================

      post '/projects/:id/users/add' do |id|
        @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
        unless @project.has_rights(@current_owner)
          halt(404)
        end

        @owner = Owner.find(:id => params[:owner].to_i)

        isNew = false
        if !@owner.nil? and @owner.valid?
          if @project.users.find{|o| o.pk == @owner.pk}.nil?
            isNew = true
            @project.add_user(@owner)
          end

          @project.users_dataset.where(:user => @owner.pk).update(:position => "developer")
          @notif = Notification.new
          @notif.set({:action => "developer", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:project => @project.title}.to_json})
          @notif.save
          
          if isNew
            @project.users.each do |u|
              if u.pk != @owner.pk and u.pk != @current_owner.pk
                notif = Notification.new
                notif.set({:action => "new", :type => "collaborator", :owner_id => u.pk, :id_object => @owner.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/show#tab2", :params => {:name => @owner.name, :project => @project.title}.to_json})
                notif.save
              end
            end
          end
          redirect "/owner/projects/#{@project.pk}/show#tab2"
        else
          redirect "/owner/projects/#{@project.pk}/users/add"
        end
      end

      post '/projects/:id/add_developers' do |id|
        @project = Project.find(:id => id) || halt(404)
        @project.has_rights(@current_owner) || halt(404)
        params[:role].each do |r|
          @owner = Owner.find(:username => r[0]) || halt(404)
          @project.remove_user(@owner)
          @project.add_user(@owner)
          @project.users_dataset.where(:user => @owner.pk).update(:position => r[1])
        end
        unless @project.product_owners.length + @project.scrum_masters.length > 0
          @project.users_dataset.where(:user => @current_owner.pk).update(:position => 'scrum master')
        end
        "OK"
      end

      post '/projects/:id/developer_list' do |id|
        @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
        response = "[" << @project.users_dataset.all.inject([]) do |arr, o|
          arr << "{\"username\": \"#{o.username}\", \"role\": \"#{o.values[:position]}\", \"id\": \"#{o.pk}\"}"
          arr
        end.join(', ') << "]"
        response
      end


      # ======================
      # = /projects/:id/edit =
      # ======================

      get '/projects/:id/edit' do |id|
        @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
        unless @project.has_rights(@current_owner)
          halt(404)
        end
        haml :"/projects/form"
      end

      get '/projects/create' do
        @project = Project.new
        haml :"/projects/form"
      end

      
      # =================
      # = /projects/:id =
      # =================

    put '/projects/:pid' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)

      @project = Project.find(:id => pid)

      if UsersProject.all.find{ |u| u.user == @current_owner.pk and u.project == @project.pk and (u.position.eql?("product owner") or u.position.eql?("scrum master"))}.nil?
        halt(404)
      end
      
      @project.set(params[:project])
      @project.save
      @project.users.each do |o|  
        unless o.pk == @current_owner.pk
          notif = Notification.new
          notif.set({:action => "modified", :type => "project", :owner_id => o.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show", :params => {:project => @project.title}.to_json})
          notif.save
        end
      end
      
      flash[:notice] = "Project updated"
      redirect "/owner/projects/#{pid}/show"
    end
    
      # ==========
      # = Remove =
      # ==========

      get '/projects/:pid/remove_user/:oid' do |pid, oid|
        @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
        @product_owner = @project.users_dataset.where(:position => "product owner").first
        
        @owner = Owner.find(:id => oid) || halt(404)

        if @product_owner.pk == @owner.pk
          flash[:notice] = "The product owner can't be removed."
          redirect "/owner/projects/#{@project.pk}/show#tab2"
        end
        
        if !UsersProject.all.find{ |u| u.user == @current_owner.pk and u.project == @project.pk and (u.position.eql?("product owner") or u.position.eql?("scrum master"))}.nil?
          @rights = true
        else
          @rights = false
        end

        if !@rights and @current_owner.pk != @owner.pk
          flash[:notice] = "You do not own the rights to do this."
          redirect "/owner/projects/#{@project.pk}/show#tab2"
        end

        @project.remove_user(@owner)
        
        @project.users.each do |u| 
          unless @current_owner.pk == u.pk or @owner.pk == u.pk
            @notif = Notification.new
            @notif.set({:action => "remove", :type => "collaborator", :owner_id => u.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show#tab2", :params => {:name => @owner.name, :project => @project.title}.to_json})
            @notif.save
          end
        end

        if @current_owner.pk != @owner.pk
          @notif = Notification.new
          @notif.set({:action => "removed", :type => "project", :owner_id => @owner.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "", :params => {:project => @project.title}.to_json})
          @notif.save
        else
          redirect "/"
        end

        
        redirect "/owner/projects/#{@project.pk}/show#tab2"
      end

    end
  end

