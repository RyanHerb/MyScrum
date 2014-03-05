require 'date'
module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/test/create' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

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

      @test.set(params[:test])
      if @test.valid?
        @test.save
        @notif = Notification.new
        @notif.set({:action => "modified", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{uid}/tests/#{tid}/show"})
        @notif.save
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/tests/form"
      end
    end

    post '/projects/:id/tests' do |id|
      @project = @current_owner.projects_dataset.where(:project => id).first || halt(404)
      @us = UserStory.find(:id => params[:test][:user_story_id])

      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories

      @test.set(params[:test])
      if @test.valid?
        @test.save
        @notif = Notification.new
        @notif.set({:action => "affectation", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{id}/user_stories/#{@test.user_story.pk}/tests/#{@test.id}/show"})
        @notif.save
        
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/tests/form"
      end
    end

    get '/projects/:pid/user_stories/:uid/tests/:tid/show' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @us = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @us.tests_dataset.where(:id => tid).first || halt(404)
      @owner = @test.owner.username
      haml :"/tests/show"
    end

    get '/projects/:pid/user_stories/:uid/tests/:tid/remove' do |pid, uid, tid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = @project.user_stories_dataset.where(:id => uid).first || halt(404)
      @test = @user_story.tests_dataset.where(:id => tid).first || halt(404)
      @notif = Notification.new
      @notif.set({:action => "remove", :type => "test", :owner_id => @test.owner.pk, :id_object => @test.id, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/show"})
      @notif.save
      @test.destroy()
      redirect "/owner/projects/#{@project.pk}/show"
    end

  end
end

