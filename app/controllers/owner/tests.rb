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

    post '/projects/:id/test/create' do |i|
      @project = Project.find(:id => i)
      @test = Test.new
      #@test.title = params[:test][:title]
      #@test.input = params[:test][:input]
      #params[:test][:owners]=Owner.find(:id => params[:test][:owners])
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

