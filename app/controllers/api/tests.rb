module MyScrum
  class ApiApp

    # =========
    # = Tests =
    # =========

    get '/owner/projects/:pid/tests' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @user_stories = @project.user_stories
      @tests = @user_stories.inject([]) {|a, us| a << us.tests; a.flatten!}
      @t = @tests.inject([]) do |arr, o|
        arr << o.to_json 
      end.join(', ')
      "[" << @t << "]"
    end

    get '/owner/projects/:pid/user_stories/:uid/tests' do |pid, uid|
      project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      user_story = project.user_stories_dataset.where(:id => uid).first || halt(404)
      tests = user_story.tests

      response = tests.inject([]) do |arr, t|
        arr << t.to_json
        arr
      end.join(', ')
      "[" << response << "]"
    end

    post '/owner/projects/:pid/tests/create' do |pid|
      project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      test = Test.new
      decoded_params = JSON.parse(params[:test])
      test.set(decoded_params)
      if test.valid?
        test.save
        "OK"
      else
        "An error occured"
      end
    end

    post '/owner/projects/:pid/user_stories/:uid/tests/:tid/edit' do |pid, uid, tid|
      project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      user_story = project.user_stories_dataset.where(:id => uid).first || halt(404)
      test = user_story.tests_dataset.where(:id => tid).first || halt(404)
      decoded_params = JSON.parse(params[:test])
      test.set(decoded_params)
      if test.valid?
        test.save
        "OK"
      else
        "An error occured"
      end
    end

  end
end