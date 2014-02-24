Sequel.migration do
  up do
    rename_column :jobs_owners, :owner, :owner_id
  	rename_column :jobs_owners, :job, :job_id
  end

  down do
    rename_column :jobs_owners, :owner_id, :owner
  	rename_column :jobs_owners, :job_id, :job
  end
end
