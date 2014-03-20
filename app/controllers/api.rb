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
      "You successfully queried our api, this means authentication was successful"
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
    

    post '/owner/profile' do
      params[:owner] = JSON.parse(params[:owner])
      @current_owner.set(params[:owner])
      if @current_owner.valid?
        @current_owner.save 
        "OK"
      else
        "An error occured while updating account"
      end
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

    get '/owner/projects/:pid/project' do |pid|
      @project = Project.find(:id => pid)
      response = @project.to_json
      response
    end


    post '/owner/projects/create' do
      project = Project.new
      decoded_params = JSON.parse(params[:project])
      project.set(decoded_params)
      if project.valid?
        project.save
        current_owner.add_project(project)
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/edit' do |pid|
      project = Project.find(:id => pid)
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


    post '/owner/projects/:pid/users/add' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      decoded_params = JSON.parse(params[:users])
      
      decoded_params.each do |k, v|
        user = Owner.find(:id => k)
        if(user.nil?)
          return "An unknown user was selected"
        end
        @project.remove_user(user)
        @project.add_user(user)
        @project.users_dataset.where(:user => user.pk).update(:position => v)
      end
      "OK"
    end

    post '/signup' do
      @user = Owner.new
      decoded_params = JSON.parse(params[:user])
      @user.set(decoded_params)
      @user.save
      "OK"
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

    get '/owner/projects/:pid/user_stories/:sid/show' do |pid, sid|
       @project = Project.find(:id => pid)
       @user_story = UserStory.find(:id => sid)
       response = @user_story.to_json
       response
     end


    post '/owner/projects/:pid/user_stories/create' do |pid|
      project = @current_owner.projects_dataset.where(:project => pid) || halt(404)
      user_story = UserStory.new
      decoded_params = JSON.parse(params[:user_story])
      user_story.set(decoded_params)
      if user_story.valid?
        user_story.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/user_stories/:uid/edit' do |pid, uid|
      project = Project.find(:id => pid)
      user_story = UserStory.find(:id => uid)
      decoded_params = JSON.parse(params[:user_story])
      user_story.set(decoded_params)
      if user_story.valid?
        user_story.save
        "OK"
      else
        "An error occured"
      end
    end

    # =========
    # = Tests =
    # =========

    get '/owner/projects/:pid/tests' do |pid|
      @project = Project.find(:id => pid)
      @tests = @project.getTests
      @t = @tests.inject([]) do |arr, o|
        arr << o.to_json
        arr
      end
      tmp = @t.join(",")
      response = "[" << tmp << "]"
    end

    post '/owner/projects/:pid/tests' do |pid|
      project = @current_owner.projects_dataset.where(:project__id => pid) || halt(404)
      @test = Test.new
      decoded_params = JSON.parse(params[:test])
      @test.set(decoded_params)
      if @test.valid?
        @test.save
        "OK"
      else
        "An error occured"
      end
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

    get '/owner/projects/:pid/sprints/:sid/jobs/:jid/show' do |pid, sid, jid|
      @job = Job.find(:id => jid)
      response = @job.to_json
      response
    end

    post '/owner/projects/:pid/create_sprint' do |pid|
      @current_project = Project.find(:id => pid)
      @sprint = Sprint.new

      decoded_params = JSON.parse(params[:sprint])
      decoded_params2 = JSON.parse(params[:user_stories])
      @sprint.set(decoded_params)
      if @sprint.valid?
        @sprint.add_user_story(decoded_params2)
        @sprint.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/sprints/:sid/create_job' do |pid, sid|
      @current_project = Project.find(:id => pid)
      @job = Job.new
      decoded_params = JSON.parse(params[:job])
      @job.set(decoded_params)
      if @job.valid?
        @job.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/sprints/:sid/jobs/:jid/edit_job' do |pid, sid, jid|
      @job = Job.find(:id => jid)
      decoded_params = JSON.parse(params[:job])
      @job.set(decoded_params)
      if @job.valid?
        @job.save
        "OK"
      else
        "An error occured"
      end
    end



  end
end
