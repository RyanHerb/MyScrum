Sequel.migration do
  up do
     run "alter table projects add column description varchar(255) after repo"
  end

  down do
	run	"alter table projects drop column description"
  end
end
