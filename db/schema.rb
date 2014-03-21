Sequel.migration do
  up do
    create_table(:admins) do
      primary_key :id
      String :email, :size=>255
      String :first_name, :size=>32
      String :last_name, :size=>32
      String :hashed_password, :size=>80
      String :api_key, :size=>255
      String :last_login_ip, :size=>20
      DateTime :last_login_at
      String :current_login_ip, :size=>20
      DateTime :current_login_at
      Integer :number_of_logins, :default=>0
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:bug_reports) do
      primary_key :id
      String :title, :size=>255
      String :description, :size=>255
      String :url, :size=>255
      String :status, :size=>255
    end
    
    create_table(:jobs) do
      primary_key :id
      String :title, :size=>255
      String :description, :size=>255
      String :status, :size=>255
      Integer :difficulty
      Integer :user_story_id
      DateTime :created_at
      DateTime :updated_at
      DateTime :state_changed_at
    end
    
    create_table(:jobs_owners) do
      primary_key :id
      Integer :owner_id
      Integer :job_id
    end
    
    create_table(:notifications) do
      primary_key :id
      Integer :owner_id
      String :action, :size=>255
      String :type, :size=>255
      Integer :id_object
      Integer :viewed
      DateTime :date
      String :link, :size=>255
      String :params, :text=>true
    end
    
    create_table(:owners) do
      primary_key :id
      String :email, :size=>64
      String :username, :size=>64
      String :first_name, :size=>16
      String :last_name, :size=>16
      TrueClass :admin, :default=>false
      String :hashed_password, :size=>80
      String :auth_token, :size=>64
      String :api_key, :size=>255
      String :last_login_ip, :size=>20
      DateTime :last_login_at
      String :current_login_ip, :size=>20
      DateTime :current_login_at
      Integer :number_of_logins, :default=>0
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:projects) do
      primary_key :id
      String :title, :size=>255
      String :repo, :size=>255
      String :description, :text=>true
      TrueClass :public
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:schema_migrations) do
      String :filename, :size=>255, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:sprints) do
      primary_key :id
      DateTime :start_date
      Integer :duration, :default=>1
      Integer :project_id
      DateTime :created_at
      DateTime :updated_at
      String :commit, :size=>255
    end
    
    create_table(:sprints_user_stories) do
      primary_key :id
      Integer :sprint_id
      Integer :user_story_id
    end
    
    create_table(:tests) do
      primary_key :id
      Integer :user_story_id
      String :title, :size=>255
      String :input, :size=>255
      String :test_case, :size=>255
      String :expected, :size=>255
      String :state, :size=>255
      Integer :owner_id
      DateTime :tested_at
      String :comment, :size=>255
    end
    
    create_table(:user_stories) do
      primary_key :id
      String :title, :size=>255
      String :description, :size=>255
      Integer :priority
      Integer :difficulty
      TrueClass :finished
      TrueClass :valid
      Integer :project_id
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:users_projects) do
      primary_key :id
      Integer :user
      Integer :project
      String :position, :size=>64
    end
  end
  
  down do
    drop_table(:admins, :bug_reports, :jobs, :jobs_owners, :notifications, :owners, :projects, :schema_migrations, :sprints, :sprints_user_stories, :tests, :user_stories, :users_projects)
  end
end
