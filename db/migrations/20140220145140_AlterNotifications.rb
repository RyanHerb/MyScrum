Sequel.migration do
  up do
    run "alter table notifications modify viewed integer"
  end

  down do
    run "alter table notifications modify viewed bool"
  end
end
