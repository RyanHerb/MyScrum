class UserStory < Sequel::Model

  one_to_many :jobs
  one_to_many :tests
  many_to_one :project
  many_to_many :sprints

  # ==============
  # = Validation =
  # ==============

  def validate
    validates_presence :title, :message => 'Title must not be blank'
    validates_unique :title
    validates_presence :description, :message => 'Description must not be blank'
    validates_presence :priority, :message => 'Priority must not be blank'
    validates_presence :difficulty, :message => 'Difficulty must not be blank'
    validates_includes 1 .. 99999999, :difficulty, :message => 'Difficulty must be > 0'
    validates_includes 1 .. 99999999, :priority, :message => 'Priority must be > 0'
  end

  # ===========
  # = Subsets =
  # ===========

  subset :finished, :finished => true
  subset :not_finished, :finished => false
  subset :valid, :valid => true
  subset :not_valid, :valid => false

  # =====================
  # = Insatance Methods =
  # =====================

  def after_create
    self.finished = false
    self.valid = false
  end

  def update_status
    if self.jobs_dataset.todo.all.length + self.jobs_dataset.in_progress.all.length == 0
      self.update({:finished => true})
    else
      self.update({:finished => false})
    end
  end

  def update_testing_state
    if self.tests_dataset.not_tested.all.length + self.tests_dataset.failed.all.length == 0
      self.update({:valid => true})
    else
      self.update({:valid => false})
    end
  end

end
