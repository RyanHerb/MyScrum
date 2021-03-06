require 'date'
module MyScrum
  class OwnerApp


    # ==========
    # = Create =
    # ==========


    get '/projects/:id/test/create' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end


    post '/projects/:id/tests' do |id|
      @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
      

      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories

      @test.set(params[:test])
      if @test.state.eql?("success") or @test.state.eql?("failed")
        @test.tested_at = Time.new
      end

      if @test.valid?
        @user_story = UserStory.find(:id => params[:test][:user_story_id]) || halt(404)
        @test.save
        
        @user_story.update_testing_state

        @project.users.each do |u|
          unless u.pk == @current_owner.pk
            @notif2 = Notification.new
            @notif2.set({:action => "new", :type => "test", :owner_id => u.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/user_stories/#{@test.user_story.pk}/tests/#{@test.id}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
            @notif2.save
          end
        end

        unless @test.owner.pk == @current_owner.pk
          @notif = Notification.new
          @notif.set({:action => "affectation", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/user_stories/#{@test.user_story.pk}/tests/#{@test.id}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
          @notif.save
        end
        
        redirect "owner/projects/#{@project.pk}/show#tab5"
      else
        haml :"/tests/form"
      end
    end



    # ========
    # = Edit =
    # ========

    get '/projects/:pid/user_stories/:uid/tests/:tid/edit' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @user_story.tests_dataset.where(:id => tid).first || halt(404)

      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end


    put '/projects/:pid/user_stories/:uid/tests/:tid' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @user_story.tests_dataset.where(:id => tid).first || halt(404)

      @owners = @project.users
      @user_stories = @project.user_stories

      @project.users.each do |u|
        unless u.pk == @current_owner.pk
          @notif = Notification.new
          @notif.set({:action => "modified", :type => "test", :owner_id => u.pk, :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
          @notif.save
        end
      end
      
      previous_state = @test.state.clone
      previous_owner = @test.owner.pk
      @test.set(params[:test])
      
      if @test.state.eql?("failed") or @test.state.eql?("success")
        if !@test.state.eql?(previous_state)
          @test.tested_at = Time.new
        end
      end

      if @test.valid?
        @test.save
        @user_story.update_testing_state

        
        if @test.owner.pk != previous_owner
          unless @test.owner.pk == @current_owner.pk
            @notif = Notification.new
            @notif.set({:action => "affectation", :type => "test", :owner_id => params[:test][:owner_id], :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
            @notif.save
          end

          if previous_owner != @current_owner.pk
            @notif2 = Notification.new
            @notif2.set({:action => "removed", :type => "test", :owner_id => previous_owner, :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
            @notif2.save
          end
        end

        redirect "owner/projects/#{@project.pk}/show#tab5"
      else
        haml :"/tests/form"
      end
    end



    # ========
    # = Show =
    # ========

    get '/projects/:pid/user_stories/:uid/tests/:tid/show' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @user_story.tests_dataset.where(:id => tid).first || halt(404)
      @owner = @test.owner.username
      haml :"/tests/show"
    end



    # ==========
    # = Remove =
    # ==========


    get '/projects/:pid/user_stories/:uid/tests/:tid/remove' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @user_story.tests_dataset.where(:id => tid).first || halt(404)

      @project.users.each do |u|
        unless u.pk == @current_owner.pk
          @notif = Notification.new
          @notif.set({:action => "remove", :type => "test", :owner_id => u.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show#tab5", :params => {:name => @test.title, :project => @project.title}.to_json})
          @notif.save
        end
      end

      @test.destroy()

      @user_story.update_testing_state

      redirect "/owner/projects/#{@project.pk}/show#tab5"
    end

  end
end

