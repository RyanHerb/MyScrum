Sequel.migration do
  up do
    rename_table :users, :owners
  end

  down do
    rename_table :owners, :users
  end
end
