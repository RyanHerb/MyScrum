Sequel.migration do
  up do
    create_table(:sprints_user_stories) do
    	primary_key :id, :auto_increment => true
    	foreign_key :sprint_id
    	foreign_key :user_story_id
    end
  end

  down do
  	drop_table(:sprints_user_stories)
  end
end
