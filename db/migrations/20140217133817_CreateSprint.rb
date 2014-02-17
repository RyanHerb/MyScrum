Sequel.migration do
  up do
    # add table sprints
    create_table(:sprints) do
      primary_key :id, :auto_increment => true
      DateTime :start_date
      Integer :duration, :default => 1
      Integer :project

      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:sprints)
  end
end
