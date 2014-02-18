Sequel.migration do
  up do
    # add table tasks
    create_table(:tasks) do
      primary_key :id, :auto_increment => true
      String :title
      String :description
      String :status
      Integer :difficulty
      Integer :user_story
      
      DateTime :created_at
      DateTime :updated_at
    end
    
    create_table(:users_tasks) do
      primary_key :id, :auto_increment => true
      foreign_key :user
      foreign_key :task
    end
  end


  down do
    drop_table(:tasks)
  end
end
