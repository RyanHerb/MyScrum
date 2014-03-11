module MyScrum
  class ApiApp < Sinatra::Application
    
    get '/' do 
    end

    get '/owner/:id/profile' do |id|
      @owner = Owner.find(:id => id)
      unless (@owner.nil?)
        response = @owner.to_json
      else
        response = "404"
      end
      response
    end
    
    get '/owner/:id/projects' do |id|
      @current_owner = Owner.find(:id => id)
      @projects = Project.new
      @title = @projects.title
      response = @title.to_json
      response
    end


    get '/owner/:id/projects/:pid/users/add' do |id, pid|
      @users = UsersProjects.all
      @users.each do |u|
        response = u.to_json
      end
      response
    end


    get '/owner/:id/projects/:pid/tasks' do |id, pid|
      @user_stories = UserStory.all
      @user_stories.each do |u|
        response = u.to_json
      end
      response
    end

    get '/owner/:id/projects/:pid/tests' do |id, pid|
      @tests = Tests.all
      @tests.each do |u|
        response = u.to_json
      end
      response
    end

    get '/owner/:id/projects/:pid/description' do |id, pid|
      @current_project = Project.find(:id => pid)
      @description = @current_project.description
      response = @description.to_json
      response
    end
    
  end
end

