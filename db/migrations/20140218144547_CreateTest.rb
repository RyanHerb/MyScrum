Sequel.migration do
  up do
    create_table(:tests) do
      primary_key :id, :auto_increment => true
      Integer :user_story_id
      String :title
      String :input
      String :test_case
      String :expected
      String :state
      Integer :owner_id
      DateTime :tested_at
      String :comment
    end
  end

  down do
    drop_table(:tests)
  end
end
