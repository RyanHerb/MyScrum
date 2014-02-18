module MyScrum
	class OwnerApp < Sinatra::Application

		get '/user_stories/all' do
      		@user_stories = UserStory.all
      		haml :"/user_stories/index"
    	end

		get '/user_stories/create' do
			@user_story = UserStory.new
			haml :"/user_stories/edit"
		end

		get '/user_stories/:id/edit' do |i|
      		@user_story = UserStory.find(:id => i)
      		haml :"/user_stories/edit"
    	end

  	put '/user_stories/:id' do |id|
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

		post '/user_stories' do
		  @user_story = UserStory.new
      @user_story.set(params[:user_story])
      if @user_story.valid?
  	 		@user_story.save
  	 		flash[:notice] = "User Stories created"
  	 		redirect '/owner/user_stories/all'
		 	else
        flash[:notice] = "An error occured"
		 		haml :"/user_stories/edit"
		 	end
		end

		get '/user_stories/:id/show' do |i|
      		@user_story = UserStory.find(:id => i)
      		haml :"/user_stories/show"
    	end
	end
end