#bon fichier
module MyScrum
  class ApiApp < Sinatra::Application
    
    get '/' do 
    end


    get '/owner/profile' do
      @owner = Owner.find(:api_key => params['api_key'])
      unless (@owner.nil?)
        response = @owner.to_json
      else
        halt 401
      end
      response
    end
    

    get '/owner/projects' do
      @current_owner = Owner.find(:api_key => params['api_key'])
      @projects = @current_owner.projects

      @p = @projects.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @p.join(",")
      response = "[" << tmp << "]"
    end


    get '/owner/:id/projects/:pid/users' do |id, pid|
      @project = Project.find(:id => pid)
      @users = Project.users
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/:id/projects/:pid/users/add' do |id, pid|
      @users = UsersProjects.all
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end


    get '/owner/:id/projects/:pid/tasks' do |id, pid|
      @user_stories = UserStory.all
      @us = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @us.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/:id/projects/:pid/tests' do |id, pid|
      @tests = Tests.all
      @t = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @t.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/description' do |pid|
      @current_project = Project.find(:id => pid)
      @description = @current_project.description
      response = @description.to_json
      response
    end
    
  end
end
