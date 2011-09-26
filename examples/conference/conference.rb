require 'wall'

# This class is a mockup of a conference in the conference rooms application.
# In real, this should be a Model
class Conference

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def is_allowed?(number)
    true
  end

  def start

  end

  def end(number)

  end

  def to_s
    @name
  end

  def wall
    @wall ||= Wall.new
  end

end