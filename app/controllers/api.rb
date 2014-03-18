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

    # ===========
    # = Profile =
    # ===========

    get'/owner/profile/api' do
      @owner = Owner.find(:api_key => params['api_key'])
      unless (@owner.nil?)
        @key = @owner.api_key
        response = @key.to_json
      end
      response
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
    
    # ============
    # = Projects =
    # ============

    get '/owner/projects' do
      @current_owner = Owner.find(:api_key => params['api_key'])
      @projects = @current_owner.projects

      @p = @projects.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @p.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/description' do |pid|
      @current_project = Project.find(:id => pid)
      @description = @current_project.description
      response = @description.to_json
      response
    end


    # =========
    # = Users =
    # =========

    get '/owner/projects/:pid/users' do |pid|
      @project = Project.find(:id => pid)
      @users = @project.users
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/users/add' do |pid|
      @users = Owner.all
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end

    # ================
    # = User Stories =
    # ================

    get '/owner/projects/:pid/user_stories' do |pid|
      @project = Project.find(:id => pid)
      @user_stories = @project.user_stories
      @us = @user_stories.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @us.join(",")
      response = "[" << tmp << "]"
    end


    # =========
    # = Tests =
    # =========

    get '/owner/projects/:pid/tests' do |pid|
      @tests = Test.all
      @t = @tests.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @t.join(",")
      response = "[" << tmp << "]"
    end

    # ===========
    # = Sprints =
    # ===========

    get '/owner/projects/:pid/sprints' do |pid|
      @current_project = Project.find(:id => pid)
      @sprints = @current_project.sprints
      @s = @sprints.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @s.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/sprints/:sid/user_stories' do |pid, sid|
      @current_project = Project.find(:id => pid)
      @sprint = Sprint.find(:id => sid)
      @user_stories = @sprint.user_stories
      @us = @user_stories.inject([]) do |arr, o|
        arr << o.to_json
      end
      tmp = @us.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/sprints/:sid/jobs' do |pid, sid|
      @current_project = Project.find(:id => pid)
      @sprint = Sprint.find(:id => sid)
      @user_stories = @sprint.user_stories
      @jobs = @user_stories.inject([]) do |arr,o|
        arr << o.jobs.inject([]) do |arr2, j|
          arr2 << j.to_json
        end
      end
      tmp = @jobs.join(",")
      response = "[" << tmp << "]"
    end

  end
end