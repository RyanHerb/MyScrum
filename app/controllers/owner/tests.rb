require 'date'
module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/test/create' do |i|
      @project = Project.find(:id => i)
      @test = Test.new
      @user_stories = @project.user_stories
      haml :"/tests/form"
    end

    post '/:id/test/create' do |i|
      @project = Project.find(:id => i)
      @trst = Test.new
      if @test.valid?
        @test.save
        puts @project.inspect
        redirect "owner/projects/#{@project.pk}/show"
      else
        haml :"/tests/form"
      end
    end

    get '/projects/:pid/tests/:sid/show' do |i,j|
      @test = Sprint.find(:id => j)
      @project = Project.find(:id => i)
      haml :"/tests/show"
    end

  end
end

