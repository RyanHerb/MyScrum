Sequel.migration do
  up do
    # add table sprints
    create_table(:bug_reports) do
      primary_key :id, :auto_increment => true
      String :title
      String :description
      String :url
      String :status
    end
  end

  down do
  	drop_table(:bug_reports)
  end
end
