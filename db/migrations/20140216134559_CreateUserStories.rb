Sequel.migration do
  up do
    # add table user_stories
    create_table(:user_stories) do
      primary_key :id, :auto_increment => true
      String :title
      String :description
      Integer :priority
      Integer :diffilculty
      TrueClass :finished
      TrueClass :validate
      
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:user_stories)
  end
end
