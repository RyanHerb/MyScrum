Sequel.migration do
  up do
    run "alter table notifications add column link varchar(255) after date"
  end

  down do
    run "alter table notifications drop column link"
  end
end
