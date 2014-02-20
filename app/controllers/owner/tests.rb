require 'date'
module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/test/create' do |i|
      @project = Project.find(:id => i)
      @test = Test.new
      if @project.nil?
        redirect "/404"
      end
      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    get '/projects/:id/tests/:tid/edit' do |pid, tid|
      @project = Project.find(:id => pid)
      @test = Test.find(:id => tid)

      if @project.nil? || @test.nil?
        redirect "/404"
      end

      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    put '/projects/:id/tests/:tid' do |id, tid|
      
      @test = Test.find(:id => tid)
      @project = Project.find(:id => id)

      if @project.nil? || @test.nil?
        redirect "/404"
      end

      @owners = @project.users
      @user_stories = @project.user_stories

      @test.set(params[:test])
      if @test.valid?
        @test.save
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/tests/form"
      end
    end

    post '/projects/:id/tests' do |id|
      @us = UserStory.find(:id => params[:test][:user_story_id])

      @project = Project.find(:id => id)
      if @project.nil?
        redirect "/404"
      end
      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories

      @test.set(params[:test])
      if @test.valid?
        @test.save
        @notif = Notification.new
        @notif.set({:action => "affectation", :type => "Test", :owner_id => @test.owner.pk, :object_id => @test.id, :viewed => 0, :date => Time.new})
        @notif.save
        
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/tests/form"
      end
    end

    get '/projects/:pid/tests/:sid/show' do |i,j|
      @test = Test.find(:id => j)
      @project = Project.find(:id => i)
      if @project.nil? || @test.nil?
        redirect "/404"
      end
      @owner = @test.owner.username
      @us = @test.user_story
      haml :"/tests/show"
    end

    get '/projects/:pid/tests/:tid/remove' do |pid, tid|
      @project = Project.find(:id => pid)
      @test = Test.find(:id => tid)
      if @project.nil? || @test.nil?
        redirect "/404"
      end
      @test.destroy()
      
      redirect "/owner/projects/#{@project.pk}/show"
    end

  end
end

