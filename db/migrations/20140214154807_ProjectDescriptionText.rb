Sequel.migration do
  up do
    run "alter table projects modify description text"
  end

  down do
  	run "alter table projects modify description varchar(255)"
  end
end
