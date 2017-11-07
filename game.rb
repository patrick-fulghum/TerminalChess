require 'byebug'
require_relative 'board.rb'
require_relative 'human.rb'

class Game
  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @players = {
      white: Human.new(@display, :white),
      black: Human.new(@display, :black)
    }
    @current_player = :white
  end

  def play
    while true
      begin
        start, fin = @players[@current_player].move(@board)
        @board.move(@current_player, start, fin)
        swap
      # rescue StandardError => e
      #   debugger
      #   puts "Invalid Move, try again."
      #   retry
      end
    end

    display.render
    puts "Game Over."
    nil
  end

  def swap
    @current_player = @current_player == :white ? :black : :white
  end
end

if $0 == __FILE__
  Game.new.play
end
