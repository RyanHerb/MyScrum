Sequel.migration do
  up do
    run "alter table sprints add column commit varchar(255) after updated_at"
  end

  down do
    run "alter table sprints drop column commit"
  end
end
