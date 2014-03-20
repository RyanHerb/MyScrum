require 'google_chart'

module MyScrum
  class ApiApp

    # ===========
    # = Sprints =
    # ===========

    get '/owner/projects/:pid/sprints' do |pid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprints = @project.sprints || halt(404)
      sp = @sprints.inject([]) do |arr, s|
        arr << s.to_json
      end
      sp.to_json
    end

    get '/owner/projects/:pid/sprints/:sid/user_stories' do |pid, sid|
      @project = @current_owner.projects_dataset.where(:project => pid).first || halt(404)
      @sprint = @project.sprints_dataset.where(:id => sid).first || halt(404)
      @user_stories = @sprint.user_stories
      @us = @user_stories.inject([]) do |arr, o|
        arr << o.to_json 
      end
      tmp = @us.join(",")
      response = "[" << tmp << "]"
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
      GoogleChart::PieChart.new('320x200', "Job Completion Distribution", false) do |pc|
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
      GoogleChart::LineChart.new('320x200', 'Burndown Chart', false) do |lc|
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