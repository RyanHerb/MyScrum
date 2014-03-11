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
      @user_story = UserStory.find(:id => id) || halt(404)
      @user_story.set(params[:user_story])
      if @user_story.valid?
        @user_story.save
        @project.users.each do |u|
          unless u.pk == @current_owner.pk
            @notif = Notification.new
            @notif.set({:action => "modified", :type => "user story", :owner_id => u.pk, :id_object => @user_story.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{id}/show", :params => {:name => @user_story.title, :project => @project.title}.to_json})
            @notif.save
          end
        end
        flash[:notice] = "User Story updated"
        redirect "/owner/projects/#{pid}/show#tab4"
      else
        haml :"/user_stories/edit"
      end
    end

    post '/projects/:pid/user_stories/' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = UserStory.new
      @user_story.set(params[:user_story])
      if @user_story.valid?
        @user_story.save
        @project.add_user_story(@user_story)
        @project.users.each do |u|
          unless u.pk == @current_owner.pk
            @notif = Notification.new
            @notif.set({:action => "new", :type => "user story", :owner_id => u.pk, :id_object => @user_story.pk, :viewed => 0, :date => Time.new, :link => "/owner/projects/#{pid}/user_stories/#{@user_story.pk}/show", :params => {:name => @user_story.title, :project => @project.title}.to_json})
            @notif.save
          end
        end
        flash[:notice] = "User Story created"
        redirect "/owner/projects/#{pid}/show#tab4"
      else
        flash[:notice] = "An error occured"
        haml :"/user_stories/edit"
      end
    end

    get '/projects/:pid/user_stories/:id/show' do |pid, id|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_story = UserStory.find(:id => id)
      haml :"/user_stories/show"
    end
  end
end
