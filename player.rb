require 'byebug'
class Player
  attr_accessor :display, :color

  def initialize(display, color)
    @display = display
    @color = color
  end
end
