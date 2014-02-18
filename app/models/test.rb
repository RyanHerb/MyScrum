class Test < Sequel::Model

  many_to_one :user_stories
  many_to_one :owners

   def validate
     validates_presence :title, :message => 'Title must not be blank'
     validates_presence :owner_id, :message => 'You must choose a Tester'
     validates_presence :user_story_id, :message => 'You must choose an User Story'
     validates_presence :state, :message => 'You must pick a state'
  end
  
end
