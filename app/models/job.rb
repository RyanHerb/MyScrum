class Job < Sequel::Model


  # ================
  # = Associations =
  # ================

  many_to_one :user_story
  many_to_many :owners

  # ==============
  # = Validation =
  # ==============

  def validate
    super
    errors.add(:status, 'Invalid status') unless ["todo", "in progress", "done"].include?(status)
    validates_presence :title, :message => 'Title is required.'
    validates_presence :user_story_id, :message => 'An user story is required.'
    validates_presence :difficulty, :message => 'Difficulty is required.'
    validates_includes 1 .. 99999999, :difficulty, :message => 'Difficulty must be > 0'
  end

  # ===========
  # = Subsets =
  # ===========

  subset :todo , :status => "todo"
  subset :in_progress, :status => "in progress"
  subset :done, :status => "done"


  # ====================
  # = Instance Methods =
  # ====================

  def last_changed_at
    state_changed_at || updated_at || created_at
  end
  
end
