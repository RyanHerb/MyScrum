module MyScrum
  class ApiApp

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