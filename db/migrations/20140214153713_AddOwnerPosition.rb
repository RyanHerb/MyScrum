Sequel.migration do
  up do
    run "alter table user_project add column position varchar(64) after project"
  end

  down do
  	run "alter table user_project drop column position"
  end
end
