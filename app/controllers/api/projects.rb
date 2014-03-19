module MyScrum
  class ApiApp

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
      @project = @current_owner.projects_dataset.where(:project__id => pid).first || halt(404)
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

    post '/owner/projects/:pid/edit' do |pid|
      project = @current_owner.projects_dataset.where(:project__id => pid).first || halt(404)
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
      @project = @current_owner.projects_dataset.where(:project__id => pid).first || halt(404)
      @users = @project.users
      @u = @users.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @u.join(",")
      response = "[" << tmp << "]"
    end

    post '/owner/projects/:pid/users/add' do |pid|
      @project = @current_owner.projects_dataset.where(:project__id => pid).first || halt(404)
      decoded_params = JSON.parse(params[:users])
      
      decoded_params.each do |k, v|
        user = User.find(:id => k)
        if(user.nil?)
          return "An unknown user was selected"
        end
        @project.remove_user(user)
        @project.add_user(user)
        @project.users_dataset.where(:user => @owner.pk).update(:position => v)
      end
      "OK"
    end


  end
end