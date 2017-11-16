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
        handle_en_passant
        swapachino
      rescue StandardError => e
        puts e.message
        sleep(1)
        retry
      end
    end
    display.render
    swapachino
    puts "Game Over, #{@current_player} wins!"
    sleep(10)
    nil
  end

  def handle_en_passant
    pawns = @board.pieces.find_all{ |pawn| pawn.class == Pawn }.reject do |pwn|
      pwn.color == @current_player
    end
    pawns.each { |pawn| pawn.pass = false }
  end

  def ensure_promotion
    (board.grid.first + board.grid.last).each_with_index do |piece, file|
      if piece.class == Pawn
        position = file < 8 ? [0, file] : [7, file % 8]
        board[position] = Queen.new(board, position, piece.color, true)
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
