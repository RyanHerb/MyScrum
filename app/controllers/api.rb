require 'google_chart'
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

    post '/owner/projects/:pid/tests/:tid/edit' do |pid, tid|
      @test = Test.find(:id => tid)
      decoded_params = JSON.parse(params[:test])
      @test.set(decoded_params)
      if @test.valid?
        @test.save
        "OK"
      else
        "An error occured"
      end
    end

   get '/owner/projects/:pid/tests/:tid/show' do |pid, tid|
      @test = Test.find(:id => tid)
      response = @test.to_json
      response
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
      decoded_params = JSON.parse(params[:Object])
      @sprint.set(decoded_params['sprint'])
      if @sprint.valid?
        @sprint.save
        @sprint.add_user_story(decoded_params['user_stories']['user_story_id'])
        "OK"
      else
        "An error occured"
      end
    end

    get '/owner/projects/:pid/sprints/:sid/show' do |pid, sid|
      @sprint = Sprint.find(:id => sid)
      response = @sprint.to_json
      response
    end

    post '/owner/projects/:pid/sprints/:sid/edit' do |pid, sid|
      @current_project = Project.find(:id => pid)
      @sprint = Sprint.find(:id => sid)
      decoded_params = JSON.parse(params[:Object])
      @sprint.set(decoded_params['sprint'])
      if @sprint.valid?
        @sprint.save
        @sprint.add_user_story(decoded_params['user_stories']['user_story_id'])
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
      show_me(decoded_params)
      @job.set(decoded_params)
      if @job.valid?
        @job.save
        "OK"
      else
        "An error occured"
      end
    end


    get '/owner/projects/:pid/sprints/:sid/burndown_charts' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)

      @date = @sprint.start_date.to_date

      total_difficulty = 0
      jobs_done = @sprint.user_stories.inject({}) do |h, v|
        v.jobs_dataset.done.all.each do |jd|
          total_difficulty += jd.difficulty
          jd.owners.each do |o|
            unless h[o.username].nil?
              h[o.username] += jd.difficulty
            else
              h[o.username] = jd.difficulty
            end
          end
        end
        h
      end

      pie_chart = ''
      # Pie Chart
      GoogleChart::PieChart.new('640x400', "Job Completion Distribution", false) do |pc|
        jobs_done.each do |k, v|
          pc.data k, v
        end
        pie_chart = pc.to_url
      end

      difficulties_completed = Array.new(@sprint.duration, 0)
      @sprint.user_stories.each do |v|
        v.jobs_dataset.done.all.each do |jd|
          difficulties_completed[(jd.state_changed_at.to_date - @date).to_i] = jd.difficulty
        end
      end

      jobs_done_at = Array.new(@sprint.duration, total_difficulty)
      difficulties_completed.each_with_index do |value, index|
        if index == 0
          current_difficulty = total_difficulty
        else
          current_difficulty = jobs_done_at[index - 1]
        end
        jobs_done_at[index] = current_difficulty - difficulties_completed[index]
      end

      
      # Line Chart
      line_chart = ''
      GoogleChart::LineChart.new('640x400', 'Burndown Chart', false) do |lc|
        lc.data "Jobs", jobs_done_at, '0000ff'
        lc.show_legend = true
        lc.axis :y, :range => [0,total_difficulty], :color => '000000', :font_size => 16, :alignment => :center
        lc.axis :x, :range => [0,jobs_done_at.length+1], :color => '000000', :font_size => 16, :alignment => :center
        lc.grid :x_step => 100.0/jobs_done_at.length.to_f, :y_step => 100.0/jobs_done_at.length.to_f, :length_segment => 1, :length_blank => 1
        line_chart = lc.to_url
      end

      jobs_done['total_difficulty'] = total_difficulty
      jobs_done['pie_chart'] = pie_chart
      jobs_done['line_chart'] = line_chart
      jobs_done['start_date'] = @sprint.start_date
      jobs_done.to_json
    end

  end
end
