require 'date'
module MyScrum
  class AdminApp

    get '/tests' do 
      @tests = Test.all
      haml :"/tests/list"
    end

    get '/tests/new' do
      @test = Test.new
      @owners = Owner.all
      #@user_stories = @project.user_stories
      haml :"/tests/form"
    end

    get '/tests/:tid/edit' do |tid|
      @test = Test.find(:id => tid) || halt(404)
      @user_story = @test.user_story
      @project = @user_story.project

      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    put '/projects/:pid/user_stories/:uid/tests/:tid' do |pid, uid, tid|
      @project = Project.find(:id => pid) || halt(404)
      @user_story = UserStory.find(:id => uid) || halt(404)
      @test = Test.find(:id => tid) || halt(404)

      @owners = @project.users
      @user_stories = @project.user_stories

      @project.users.each do |u|
        @notif = Notification.new
        @notif.set({:action => "modified", :type => "test", :owner_id => u.pk, :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
        @notif.save
      end
      
      @test.set(params[:test])
      if @test.valid?
        @test.save

        @user_story.update_testing_state

        @notif = Notification.new
        if @test.owner.pk != params[:test][:owner_id].to_i
          @notif.set({:action => "affectation", :type => "test", :owner_id => params[:test][:owner_id], :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title}.to_json})
          @notif2 = Notification.new
          @notif2.set({:action => "removed", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
        end
        
        if !@notif2.nil?
          @notif2.save
        end
        @notif.save

        redirect "admin/projects/#{@project.pk}/show#tab5"
      else
        haml :"/tests/form"
      end
    end

    post '/projects/:id/tests' do |id|
      @project = Project.find(:id => pid) || halt(404)
      @user_story = UserStory.find(:id => uid) || halt(404)
      
      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories

      @test.set(params[:test])
      if @test.valid?
        @test.save

        @user_story.update_testing_state

        @project.users.each do |u|
          @notif2 = Notification.new
          @notif2.set({:action => "new", :type => "test", :owner_id => u.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/user_stories/#{@test.user_story.pk}/tests/#{@test.id}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
          @notif2.save
        end

        @notif = Notification.new
        @notif.set({:action => "affectation", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/user_stories/#{@test.user_story.pk}/tests/#{@test.id}/show", :params => {:name => @test.title, :project => @project.title}.to_json})
        @notif.save
        
        redirect "admin/projects/#{@project.pk}/show#tab5"
      else
        haml :"/tests/form"
      end
    end

    get '/tests/:tid/show' do |tid|
      @test = Test.find(:id => tid) || halt(404)
      @user_story = @test.user_story
      @project = @user_story.project
      @owner = @test.owner.username
      haml :"/tests/show"
    end

    get '/projects/:pid/user_stories/:uid/tests/:tid/remove' do |pid, uid, tid|
      @project = Project.find(:id => pid) || halt(404)
      @user_story = UserStory.find(:id => uid) || halt(404)
      @test = Test.find(:id => tid) || halt(404)

      @project.users.each do |u|
        @notif = Notification.new
        @notif.set({:action => "remove", :type => "test", :owner_id => u.pk, :id_object => @project.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show#tab5", :params => {:name => @test.title, :project => @project.title}.to_json})
        @notif.save
      end

      @test.destroy()

      @user_story.update_testing_state

      redirect "/admin/projects/#{@project.pk}/show#tab5"
    end

  end
end