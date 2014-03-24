Sequel.migration do
  up do
    rename_column :user_stories, :project, :project_id
    rename_column :sprints, :project, :project_id
    rename_column :tasks, :user_story, :user_story_id
  end

  down do
    rename_column :user_stories, :project_id, :project
    rename_column :sprints, :project_id, :project
    rename_column :tasks, :user_story_id, :user_story
  end
end
