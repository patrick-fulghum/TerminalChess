require_relative 'player.rb'
require 'display.rb'
require 'byebug'

class Human < Player
  def move(board)
    start, fin = nil, nil
    until start && fin
      display.render
      if start
        fin = display.cursor.get_input
      else
        start = display.cursor.get_input
      end
    end
    [start, fin]
  end
end
