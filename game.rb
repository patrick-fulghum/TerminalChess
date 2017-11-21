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
      white: Hal.new(@display, :white),
      black: Hal.new(@display, :black)
    }
    @current_player = :white
    initial_board = Marshal.load(Marshal.dump(board))
    @game_state = {
      boards: [],
      threefold: 1,
      fifty_move: 1,
      insufficient_material: false,
    }
    @game_state[:boards].push(initial_board)
  end

  def play
    until @board.checkmate?(@current_player) || self.draw? || @board.stalemate?(@current_player)
      begin
        start, finalachino = @players[@current_player].move(@board)
        @capture = @board[finalachino].is_a?(NullPiece) ? false : true
        @board.move(@current_player, start, finalachino)
        update_state(@board)
        ensure_promotion
        handle_en_passant
        @board.print_board(finalachino)
        swapachino
      rescue StandardError => e
        if @players[@current_player].class == Human
          puts e.message
          sleep(0.5)
        end
        retry
      end
    end
    display.render(nil)
    swapachino
    if @board.stalemate?(@current_player)
      puts "Game Over, it's a draw by Stalemate!"
    else
      if self.draw?
        if @game_state[:threefold] > 2
          puts "Game Over, it's a draw by threefold repetition!"
        elsif @game_state[:fifty_move] > 50
          puts "Game Over, it's a draw by the fifty move rule!"
        else
          puts "Game Over, it's a draw due to insufficient material!"
        end
      else
        puts "Game Over, #{@current_player} wins!"
      end
    end
    sleep(10)
    nil
  end

  def draw?
    if @game_state[:threefold] > 2 || @game_state[:fifty_move] > 50 || @game_state[:insufficient_material]
      return true
    end
    false
  end

  def update_state(board)
    @game_state[:threefold] = 1
    current_board = Marshal.load(Marshal.dump(board))
    @game_state[:boards].each do |game_board|
      if game_board == board
        @game_state[:threefold] += 1
      end
    end
    if @capture
      @game_state[:fifty_move] = 0
    else
      @game_state[:fifty_move] += 1
    end
    @game_state[:boards].push(current_board)
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
