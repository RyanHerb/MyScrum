Sequel.migration do
  up do
    run "alter table user_stories add column project tinyint after valid"
  end

  down do
  	run "alter table user_stories drop column project"
  end
end
