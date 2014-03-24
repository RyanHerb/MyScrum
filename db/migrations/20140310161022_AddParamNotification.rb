Sequel.migration do
  up do
    run "alter table notifications add column params text after link"
  end

  down do
    run "alter table notifications drop column params"
  end
end
