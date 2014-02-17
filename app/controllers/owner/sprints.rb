module MyScrum
  class OwnerApp < Sinatra::Application

    get '/projects/:id/sprint/create' do 
      @sprint = Sprint.new
      haml :"/projects/form"
    end

    post '/projects/:id/sprints/:sid' do |id|
      @project = @current_owner.projects.inject([]) do |arr, p|
        if p.pk == id.to_i
          arr << p
        end
        arr
      end
      @project = @project.first
      @sprint = Sprint.new
      @sprint.set(params[:sprint])
      if @sprint.valid?
        @sprint.save
        @project.add_sprint(@sprint)
        redirect "/projects/show"
      else
        haml :"/projects/form"
      end
    end

  end
end