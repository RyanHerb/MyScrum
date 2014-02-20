Sequel.migration do
  up do
    rename_table :user_project, :users_projects
  end

  down do
    rename_table :users_projects, :user_project
  end
end
