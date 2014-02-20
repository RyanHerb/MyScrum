Sequel.migration do
  up do
    rename_table :tasks, :jobs
  end

  down do
    rename_table :jobs, :tasks
  end
end
