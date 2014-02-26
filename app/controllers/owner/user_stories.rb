module MyScrum
	class OwnerApp < Sinatra::Application

		get '/projects/:pid/user_stories/all' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
  		@user_stories = UserStory.all
  		haml :"/user_stories/index"
  	end

		get '/projects/:pid/user_stories/create' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
			@user_story = UserStory.new
			haml :"/user_stories/edit"
		end

		get '/projects/:pid/user_stories/:id/edit' do |pid, id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
  		@user_story = UserStory.find(:id => id)
  		haml :"/user_stories/edit"
  	end

  	put '/projects/:pid/user_stories/:id' do |pid, id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
  		@user_story = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
  		@user_story.set(params[:userstory])
  		if @userstory.valid?
    		@user_story.save
    		flash[:notice] = "User Story updated"
        redirect "/owner/projects/#{pid}/show#tab4"
  		else
    		haml :"/user_stories/edit"
  		end
  	end

		post '/projects/:pid/user_stories' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
		  @user_story = UserStory.new
      @user_story.set(params[:user_story])
      if @user_story.valid?
  	 		@user_story.save
        @project.add_user_story(@user_story)
  	 		flash[:notice] = "User Story created"
  	 		redirect "/owner/projects/#{pid}/show#tab4"
		 	else
        flash[:notice] = "An error occured"
		 		haml :"/user_stories/edit"
		 	end
		end

		get '/projects/:pid/user_stories/:id/show' do |pid, id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
  		@user_story = UserStory.find(:id => i)
  		haml :"/user_stories/show"
  	end
	end
end