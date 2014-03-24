module MyScrum
  class AdminApp

    get '/user_stories' do
      @user_stories = UserStory.all
      haml :"user_stories/list"
    end

    post '/user_stories' do
      @user_story = UserStory.new
      @user_story.set(params[:user_story])
      @project = Project.find(:id => params[:project])
      if @user_story.valid?
        @user_story.save
        @project.add_user_story(@user_story)

        if session[:return_to] && session[:return_to] !~ /login/
          redirect "/admin#{session.delete(:return_to)}"
        else
          redirect '/admin/user_stories'
        end
      else
        @projects = Project.all
        haml :"user_stories/form"
      end
    end

    get '/user_stories/new' do
      @user_story = UserStory.new
      @projects = Project.all
      haml :"user_stories/form"
    end

    put '/user_stories/:id' do |id|
      @user_story = UserStory.find(:id => id) || halt(404)
      @user_story.set(params[:user_story])
      if @user_story.valid?
        @user_story.save
        if session[:return_to] && session[:return_to] !~ /login/
          redirect "/admin#{session.delete(:return_to)}"
        else
          redirect '/admin/user_stories'
        end
      else
        @projects = Project.all
        haml :"user_stories/form"
      end
    end

    get '/user_stories/:id/show' do |id|
      @user_story = UserStory.find(:id => id) || halt(404)
      haml :"user_stories/show"
    end

    get '/user_stories/:id/edit' do |id|
      @user_story = UserStory.find(:id => id) || halt(404)
      @projects = Project.all
      haml :"user_stories/form"
    end

    get '/projects/:pid/user_stories/new' do |pid|
      session[:return_to] = "/projects/#{pid}/show#tab4"
      @project = Project.find(:id => pid) || halt(404)
      @user_story = UserStory.new
      haml :"user_stories/form"
    end

  end
end