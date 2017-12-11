require_relative 'board.rb'
require_relative 'display.rb'
require 'byebug'

class KnightTravails
  def initialize
    @board = Board.new
    @board.slaughter
    @display = Display.new(@board)
  end

  def play
    puts "Move the cursor with the left,right, up and down arrows.
      The first selection is where the knight wil be placed;
      The second is where the knight will travail(with laborious difficulty)"
    start, final = nil, nil
    until start && final
      @display.render(start)
      if start
        final = @display.cursor.get_input
      else
        start = @display.cursor.get_input
      end
    end
    puts "Calculating Route..."
    sleep(1)
    puts "Code not yet implemented to calculate route hehe xd."
  end
end
