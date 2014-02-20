Sequel.migration do
  up do
    rename_table :users_tasks, :users_jobs
  end

  down do
  	rename_table :users_jobs, :users_tasks
  end
end
