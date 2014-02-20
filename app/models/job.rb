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
    errors.add(:status, 'Invalid status') unless ["todo", "inprogress", "done"].include?(status)
  end

  # ===========
  # = Subsets =
  # ===========

  subset :todo , :status => "todo"
  subset :in_progress, :status => "inprogress"
  subset :done, :status => "done"
  
end
