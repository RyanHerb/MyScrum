module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/sprint/create' do
      @sprint = Sprint.new
      haml :"/projects/form"
    end

    post '/projects/:id/sprints/:sid' do |id|
      @project = Project.find(:id => i)
      @sprint = Sprint.new
      @date = DateTime.new(params[:days], params[:month], params[:year])
      params.delete("days")
      params.delete("month")
      params.delete("year")
      @sprint.set(params[:sprint])
      @sprint.start_date = @date
      if @sprint.valid?
        @sprint.save
        @project.add_sprint(@sprint)
        redirect "/projects/#{@project.pk}/show"
      else
        haml :"/projects/form"
      end
    end

    get '/projects/:pid/sprint_show/:sid' do |i|
      @sprint = Sprint.find(:id => i)
      haml :"/projects/sprint_show"
    end

  end
end
