require 'byebug'
require_relative 'board.rb'
require_relative 'human.rb'

class Game
  def play
    @board = Board.new
    @display = Display.new(@board)
    @players = {
      one: Human.new(@display, :white),
      two: Human.new(@display, :black)
    }
    @current_player = :white
  end
end

if $0 = __FILE__
  Game.new.play
end
