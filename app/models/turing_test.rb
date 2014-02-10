class TuringTest

  NUMBERS = { 0 => 'zero',
              1 => 'one',
              2 => 'two',
              3 => 'three',
              4 => 'four',
              5 => 'five',
              6 => 'six',
              7 => 'seven',
              8 => 'eight',
              9 => 'nine' }

  attr_reader :x, :y, :question

  def initialize
    @x = rand(10)
    @y = rand(10)
    @question = "How much is #{NUMBERS[x]} plus #{NUMBERS[y]}?"
  end

  def ask
    @question
  end
  
  def answer
    (@x + @y).to_s
  end
  
  def test(z)
    @x + @y == z.to_i ? true : false
  end
  
end