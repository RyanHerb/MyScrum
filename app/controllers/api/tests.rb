module MyScrum
  class ApiApp

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

  end
end