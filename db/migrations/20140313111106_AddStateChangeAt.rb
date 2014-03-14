Sequel.migration do
  up do
    run "alter table jobs add column state_changed_at datetime after updated_at"
  end

  down do
  	"alter table jobs drop column state_changed_at"
  end
end