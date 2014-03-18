module MyScrum
  class ApiApp

    # ================
    # = User Stories =
    # ================

    get '/owner/projects/:pid/user_stories' do |pid|
      @project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @user_stories = @project.user_stories
      @us = @user_stories.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @us.join(",")
      response = "[" << tmp << "]"
    end

    post '/owner/projects/:pid/user_stories/create' do
      project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      user_story = UserStory.new
      decoded_params = JSON.parse(params[:user_story])
      user_story.set(decoded_params)
      if user_story.valid?
        user_story.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/user_stories/uid/edit' do |pid, uid|
      project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      user_story = project.user_stories_dataset.where(:user_story__id => uid) || halt(404)
      decoded_params = JSON.parse(params[:user_story])
      user_story.set(decoded_params)
      if user_story.valid?
        user_story.save
        "OK"
      else
        "An error occured"
      end
    end
    
  end
end