Sequel.migration do
  up do
    run "alter table owners add column api_key varchar(255) after auth_token"
    run "alter table admins add column api_key varchar(255) after hashed_password"
  end

  down do
    drop_column :owners, :api_key
    drop_column :admins, :api_key
  end
end
