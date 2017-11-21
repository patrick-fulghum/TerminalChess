require_relative 'player.rb'
require_relative 'display.rb'
require 'byebug'

class Human < Player
  def move(board)
    begin
      start, final = nil, nil
      until start && final
        display.render(start)
        if start
          final = display.cursor.get_input
        else
          start = display.cursor.get_input
          if (!start.nil?) && (board[start].color != @color)
            raise "That's not your piece"
          end
        end
      end
      [start, final]
    rescue StandardError => e
      puts e.message
      sleep(1)
      retry
    end
  end
end
