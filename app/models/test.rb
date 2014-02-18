class Test < Sequel::Model

  many_to_one :user_stories
  many_to_one :owners
  
end
