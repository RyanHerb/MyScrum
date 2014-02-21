Sequel.migration do
  up do
    rename_column :notifications, :object_id, :id_object
  end

  down do
    rename_column :notifications, :id_object, :object_id
  end
end
