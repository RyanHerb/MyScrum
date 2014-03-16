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
        else
          halt(401)
        end
      else
        halt(401)
      end
    end
    
    get '/' do
      "You successfully queried our api, this means authentication was successful"
    end

    # ===========
    # = Profile =
    # ===========

    get '/owner/profile' do
      response = @owner.to_json
    end

    post '/owner/profile' do
      params[:owner] = JSON.parse(params[:owner])
      @current_owner.set(params[:owner])
      if @current_owner.valid?
        @current_owner.save
      else
        "An error occured while updating account"
      end
    end

    # ============
    # = Projects =
    # ============

    get '/owner/projects' do
      @projects = @current_owner.projects

      @p = @projects.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @p.join(",")
      response = "[" << tmp << "]"
    end

    get '/owner/projects/:pid/description' do |pid|
      @project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @project.description.to_json
    end

    post '/owner/projects/create' do
      project = Project.new
      decoded_params = JSON.parse(params[:project])
      project.set(decoded_params)
      if project.valid?
        project.save
        "OK"
      else
        "An error occured"
      end
    end

    # =========
    # = Users =
    # =========

    get '/owner/projects/:pid/users' do |pid|
      @project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @users = @project.users
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end

    post '/owner/projects/:pid/users/add' do |pid|
    end

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

    # =========
    # = Tests =
    # =========

    get '/owner/projects/:pid/tests' do |pid|
      @project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @tests = @project.tests
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
      @project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @sprints = @project.sprints
      sp = @sprints.inject([]) do |arr, s|
        arr << s.to_json
      end
      "[" << sp << "]"
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
    
  end
end
