require_relative 'player.rb'
require_relative 'board.rb'
require 'byebug'
DEFAULT_VALUES = {
  Queen => 900,
  Rook => 500,
  Knight => 300,
  Bishop => 325,
  Pawn => 100,
  King => 9000
}

POSITIONAL_VALUES = {
  Pawn =>
    [
      [0,  0,  0,  0,  0,  0,  0,  0],
      [50, 50, 50, 50, 50, 50, 50, 50],
      [10, 10, 20, 30, 30, 20, 10, 10],
      [5,  5, 10, 25, 25, 10,  5,  5],
      [0,  0,  0, 20, 20,  0,  0,  0],
      [5, -5,-10,  0,  0,-10, -5,  5],
      [5, 10, 10,-20,-20, 10, 10,  5],
      [0,  0,  0,  0,  0,  0,  0,  0]
    ],
  Knight =>
    [
      [-50,-40,-30,-30,-30,-30,-40,-50],
      [-40,-20,  0,  0,  0,  0,-20,-40],
      [-30,  0, 10, 15, 15, 10,  0,-30],
      [-30,  5, 15, 20, 20, 15,  5,-30],
      [-30,  0, 15, 20, 20, 15,  0,-30],
      [-30,  5, 10, 15, 15, 10,  5,-30],
      [-40,-20,  0,  5,  5,  0,-20,-40],
      [-50,-40,-30,-30,-30,-30,-40,-50]
    ],
  Bishop =>
    [
      [-20,-10,-10,-10,-10,-10,-10,-20],
      [-10,  0,  0,  0,  0,  0,  0,-10],
      [-10,  0,  5, 10, 10,  5,  0,-10],
      [-10,  5,  5, 10, 10,  5,  5,-10],
      [-10,  0, 10, 10, 10, 10,  0,-10],
      [-10, 10, 10, 10, 10, 10, 10,-10],
      [-10,  5,  0,  0,  0,  0,  5,-10],
      [-20,-10,-10,-10,-10,-10,-10,-20]
    ],
  Rook =>
    [
      [0,  0,  0,  0,  0,  0,  0,  0],
      [5, 10, 10, 10, 10, 10, 10,  5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [0,  0,  0,  5,  5,  0,  0,  0]
    ],
  Queen =>
    [
      [-20,-10,-10, -5, -5,-10,-10,-20],
      [-10,  0,  0,  0,  0,  0,  0,-10],
      [-10,  0,  5,  5,  5,  5,  0,-10],
      [-5,  0,  5,  5,  5,  5,  0, -5],
      [0,  0,  5,  5,  5,  5,  0, -5],
      [-10,  5,  5,  5,  5,  5,  0,-10],
      [-10,  0,  5,  0,  0,  0,  0,-10],
      [-20,-10,-10, -5, -5,-10,-10,-20]
    ],
  King =>
    [
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-20,-30,-30,-40,-40,-30,-30,-20],
      [-10,-20,-20,-20,-20,-20,-20,-10],
      [20, 20,  0,  0,  0,  0, 20, 20],
      [20, 30, 10,  0,  0, 10, 30, 20]
    ]
}

class Hal < Player
  def move(board)
    @board = board
    @current_min = 99
    best_move = []
    @board.legal_moves_of(:black).shuffle.each do |move_sequence|
      moves_value = minimax(1, move_sequence, @board)
      if moves_value < @current_min
        @current_min = moves_value
        best_move = move_sequence
      end
    end
    best_move
  end

  def minimax(depth, sequence, board)
    if depth == 0
      return calculate_move(sequence, board)
    end
    current_player = board[sequence[0]].color
    fake_board = Marshal.load(Marshal.dump(board))
    fake_board.move!(sequence[0], sequence[1])
    current_player = current_player == :black ? :white : :black
    if current_player == :black
      black_min = 9999
      fake_board.pieces_of(current_player).each do |piece|
        piece.moves.each do |move|
          current_sequence = [sequence[1], move]
          evaluation = minimax(depth - 1, current_sequence, fake_board)
          black_min = evaluation < black_min ? black_min : evaluation
        end
      end
      return black_min
    else
      white_max = -9999
      fake_board.pieces_of(current_player).each do |piece|
        piece.moves.each do |move|
          current_sequence = [sequence[1], move]
          evaluation = minimax(depth - 1, current_sequence, fake_board)
          white_max = evaluation > white_max ? white_max : evaluation
        end
      end
      return white_max
    end
  end

  def evaluate_position(this_board)
    black_sum = 0
    white_sum = 0
    this_board.pieces_of(:black).each do |piece|
      debugger
      black_sum += DEFAULT_VALUES[piece.class]
    end
    this_board.pieces_of(:white).each do |piece|
      white_sum += DEFAULT_VALUES[piece.class]
    end
    white_sum - black_sum
  end

  def calculate_move(sequence, this_board)
    fake_board = Marshal.load(Marshal.dump(this_board))
    fake_board.move!(sequence[0], sequence[1])
    evaluate_position(fake_board)
  end
end
