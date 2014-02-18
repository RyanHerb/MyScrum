Sequel.migration do
  up do
    rename_column :user_stories, :validate, :valid
  end

  down do
  	rename_column :user_stories, :valid, :validate
  end
end
