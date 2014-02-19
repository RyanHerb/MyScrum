require 'date'
module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/test/create' do |i|
      @project = Project.find(:id => i)
      @test = Test.new
      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    get '/projects/:id/tests/:tid/edit' do |pid, tid|
      @project = Project.find(:id => pid)
      @test = Test.find(:id => tid)
      @owners = @project.users
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    put '/tests/:tid' do |tid|
      @us = UserStory.find(:id => params[:test][:user_story_id])
      @project = Project.find(:id => @us.project_id)
      @test = Test.find(:id => tid)
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

    post '/tests' do
      @us = UserStory.find(:id => params[:test][:user_story_id])
      @project = Project.find(:id => @us.project_id)
      @test = Test.new
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

    get '/projects/:pid/tests/:sid/show' do |i,j|
      @test = Test.find(:id => j)
      @project = Project.find(:id => i)
      haml :"/tests/show"
    end

  end
end

