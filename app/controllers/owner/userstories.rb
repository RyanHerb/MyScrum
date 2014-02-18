module MyScrum
	class OwnerApp < Sinatra::Application

		get '/userstories/all' do
      		@userstories = UserStory.all
      		haml :"/userstories/index"
    	end

		get '/userstories/create' do
			@userstory = UserStory.new
			haml :"/userstories/edit"
		end

		get '/userstories/:id/edit' do |i|
      		@userstory = UserStory.find(:id => i)
      		haml :"/userstories/edit"
    	end

    	put '/userstories/:id' do |id|
      		@userstory = Project.find(:id => id)
      		@userstory.set(params[:userstory])
      		if @userstory.valid?
        		@userstory.save
        		flash[:notice] = "Userstory updated"
        		redirect '/userstories/all'
      		else
        		haml :"/userstories/edit"
      		end
    	end

		post '/userstories' do
		  	if 	@userstory = UserStory.create(params[:userstory])
		 		@userstory.save
		 		flash[:notice] = "User Stories created"
		 		redirect '/userstories/all'
		 	else
		 		haml :"/userstories/edit"
		 	end
		end

		get '/userstories/:id/show' do |i|
      		@userstory = UserStory.find(:id => i)
      		haml :"/userstories/show"
    	end
	end
end