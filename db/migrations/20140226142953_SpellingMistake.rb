Sequel.migration do
  up do
    rename_column :user_stories, :diffilculty, :difficulty
  end

  down do
    rename_column :user_stories, :difficulty, :diffilculty
  end
end
