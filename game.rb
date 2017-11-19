require 'byebug'
require_relative 'board.rb'
require_relative 'human.rb'
require_relative 'hal.rb'

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
    @game_state = {
      last_four_move_sequences: [],
      threefold_repition: 0,
      fifty_move_rule: 0,
    }
  end

  def play
    until @board.checkmate?(@current_player) || self.draw?
      begin
        start, fin = @players[@current_player].move(@board)
        @capture = @board[fin].is_a?(NullPiece) ? false : true
        @board.move(@current_player, start, fin)
        update_state(start, fin)
        ensure_promotion
        handle_en_passant
        swapachino
      rescue StandardError => e
        if @players[@current_player].class == Human
          puts e.message
          sleep(1)
        end
        retry
      end
    end
    display.render(nil)
    swapachino
    if draw?
      puts "Game Over, It's a Draw by threefold repition."
    else
      puts "Game Over, #{@current_player} wins!"
    end
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

  def update_state(start, fin)
    @game_state[:last_four_move_sequences].push([start, fin])
    if @game_state[:last_four_move_sequences].length > 4
      @game_state[:last_four_move_sequences].shift
      if @game_state[:last_four_move_sequences][0] == @game_state[:last_four_move_sequences][2].reverse && @game_state[:last_four_move_sequences][1] == @game_state[:last_four_move_sequences][3].reverse
        @game_state[:threefold_repition] += 1
      else
        @game_state[:threefold_repition] = 0
      end
      debugger
    end
    if @capture
      @game_state[:fifty_move_rule] = 0
    else
      @game_state[:fifty_move_rule] += 1
    end
  end

  def draw?
    if @game_state[:threefold_repition] > 2 || @game_state[:fifty_move_rule] > 50
      return true
    end
    false
  end

  def swapachino
    @current_player = @current_player == :white ? :black : :white
  end
end

if $0 == __FILE__
  Game.new.play
end
