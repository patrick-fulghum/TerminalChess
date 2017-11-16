require_relative 'player.rb'
require_relative 'board.rb'
require 'byebug'


class Hal < Player
  def move(board)
    @board = board
    @current_min = 99
    best_move = []
    @board.legal_moves_of(:black).shuffle.each do |move_sequence|
      moves_value = calculate_move(move_sequence)
      if moves_value < @current_min
        @current_min = moves_value
        best_move = move_sequence
      end
    end
    best_move
  end

  def values
    {
      "Queen" => 10,
      "Rook" => 5,
      "Knight" => 3,
      "Bishop" => 3.25,
      "Pawn" => 1,
      "King" => 90
    }
  end

  def evaluate_position(this_board)
    black_sum = 0
    white_sum = 0
    this_board.pieces_of(:black).each do |piece|
      black_sum += values[piece.class.to_s]
    end
    this_board.pieces_of(:white).each do |piece|
      white_sum += values[piece.class.to_s]
    end
    white_sum - black_sum
  end

  def calculate_move(sequence)
    fake_board = Marshal.load(Marshal.dump(@board))
    fake_board.move!(sequence[0], sequence[1])
    evaluate_position(fake_board)
  end
end
