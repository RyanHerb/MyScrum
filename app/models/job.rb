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
  end

  # ===========
  # = Subsets =
  # ===========

  subset :todo , :status => "todo"
  subset :in_progress, :status => "in progress"
  subset :done, :status => "done"
  
end
