class Test < Sequel::Model

  many_to_one :user_story
  many_to_one :owner

  # ==============
  # = Validation =
  # ==============

  def validate
    validates_presence :title, :message => 'Title must not be blank'
    validates_presence :owner_id, :message => 'You must choose a Tester'
    validates_presence :user_story_id, :message => 'You must choose an User Story'
    validates_presence :state, :message => 'You must pick a state'
  end

  # ===========
  # = Subsets =
  # ===========

  subset :successful, :state => 'success'
  subset :failed, :state => 'failed'
  subset :not_tested, :state => 'not_tested'
  
end
