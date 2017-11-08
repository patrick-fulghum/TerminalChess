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
        ensure_promotion
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

  #Make all pawns turn into Queens if they are on the last rank.
  def ensure_promotion
    self.board.grid.first.each_with_index do |chess_piece, file|
      if chess_piece.class == Pawn
        self.board.grid.first[file] = Queen.new(self.board, [0, file], :black, true)
      end
    end

    self.board.grid.last.each_with_index do |chess_piece, file|
      if chess_piece.class == Pawn
        self.board.grid.first[file] = Queen.new(self.board, [0, file], :white, true)
      end
    end
  end

  def swapachino
    @current_player = @current_player == :white ? :black : :white
  end
end

if $0 == __FILE__
  Game.new.play
end
