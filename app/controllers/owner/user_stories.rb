module MyScrum
	class OwnerApp < Sinatra::Application

		get '/projects/:pid/user_stories/all' do |pid|
      @project = Project.find(:id => pid)
  		@user_stories = UserStory.all
  		haml :"/user_stories/index"
  	end

		get '/projects/:pid/user_stories/create' do |pid|
      @project = Project.find(:id => pid)
			@user_story = UserStory.new
			haml :"/user_stories/edit"
		end

		get '/projects/:pid/user_stories/:id/edit' do |pid, id|
      @project = Project.find(:id => pid)
  		@user_story = UserStory.find(:id => id)
  		haml :"/user_stories/edit"
  	end

  	put '/projects/:pid/user_stories/:id' do |pid, id|
      @project = Project.find(:id => pid)
  		@user_story = Project.find(:id => id)
  		@user_story.set(params[:userstory])
  		if @userstory.valid?
    		@user_story.save
    		flash[:notice] = "Userstory updated"
    		redirect '/owner/userstories/all'
  		else
    		haml :"/user_stories/edit"
  		end
  	end

		post '/projects/:pid/user_stories' do |pid|
      @project = Project.find(:id => pid)
		  @user_story = UserStory.new
      @user_story.set(params[:user_story])
      if @user_story.valid?
  	 		@user_story.save
  	 		flash[:notice] = "User Stories created"
  	 		redirect "/owner/projects/#{pid}/user_stories/all"
		 	else
        flash[:notice] = "An error occured"
		 		haml :"/user_stories/edit"
		 	end
		end

		get '/projects/:pid/user_stories/:id/show' do |pid, id|
      @project = Project.find(:id => pid)
  		@user_story = UserStory.find(:id => i)
  		haml :"/user_stories/show"
  	end
	end
end