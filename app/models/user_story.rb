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
  end

  # =====================
  # = Insatance Methods =
  # =====================

  def update_status
    if self.jobs_dataset.todo.all.length + self.jobs_dataset.in_progress.all.length == 0
      self.update({:finished => true})
    else
      self.update({:finished => false})
    end
  end

end
