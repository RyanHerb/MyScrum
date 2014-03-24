Sequel.migration do
  up do
    rename_table :users_jobs, :jobs_owners
    rename_column :jobs_owners, :user, :owner
    rename_column :jobs_owners, :task, :job
  end

  down do
  	rename_column :jobs_owners, :owner, :user
  	rename_column :jobs_owners, :job, :task
    rename_table :jobs_owners, :users_jobs
  end
end
