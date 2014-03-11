#bon fichier
module MyScrum
  class ApiApp < Sinatra::Application

    error 401 do
      "401"
    end
    
    not_found do
      "404"
    end

    before do
      show_me params.inspect
      unless params[:api_key].nil?
        if o = Owner.auth_with_key(params)
          @current_owner = o
        end
      else
        halt(401)
      end
    end
    
    get '/' do
      "Hello"
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

    get '/owner/projects' do
      @owner = Owner.find(:api_key => params['key'])
    end
    
  end
end
