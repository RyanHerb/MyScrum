Sequel.migration do
  up do
    create_table(:notifications) do
      primary_key :id, :auto_increment => true
      Integer :owner_id
      String :action
      String :type
      Integer :object_id
      TrueClass :viewed
      DateTime :date
    end
  end

  down do
      drop_table(:notifications)
  end
end
