Sequel.migration do
  up do
    # add table projects
    create_table(:projects) do
      primary_key :id, :auto_increment => true
      String :title
      String :repo
      TrueClass :public
      
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:user_project) do
      primary_key :id, :auto_increment => true
      foreign_key :user
      foreign_key :project
    end

  end

  down do
    drop_table(:projects)
    drop_table(:user_project)
  end
end
