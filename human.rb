require_relative 'player.rb'
require_relative 'display.rb'
require 'byebug'

class Human < Player
  def move(board)
    start, final = nil, nil
    until start && final
      display.render
      if start
        final = display.cursor.get_input
      else
        start = display.cursor.get_input
      end
    end
    [start, final]
  end
end
