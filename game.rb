require 'byebug'
require_relative 'board.rb'
require_relative 'human.rb'

class Game
  attr_accessor :board, :display, :players, :current_player
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
    until @board.checkmate?(@current_player)
      begin
        start, fin = @players[@current_player].move(@board)
        @board.move(@current_player, start, fin)
        swapachino
      rescue StandardError => e
        puts e.message
        sleep(1)
        retry
      end
    end

    display.render
    puts "Game Over."
    nil
  end

  def swapachino
    @current_player = @current_player == :white ? :black : :white
  end
end

if $0 == __FILE__
  Game.new.play
end
