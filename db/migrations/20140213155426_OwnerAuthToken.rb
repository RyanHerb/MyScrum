Sequel.migration do
  up do
    run "alter table owners add column auth_token varchar(64) after hashed_password"
  end

  down do
    run "alter table owners drop column auth_token"
  end
end
