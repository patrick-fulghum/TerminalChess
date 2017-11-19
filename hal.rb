require_relative 'player.rb'
require_relative 'board.rb'
require 'byebug'
require 'ruby-prof'

MATERIAL_VALUES = {
  Queen => 900,
  Rook => 500,
  Knight => 300,
  Bishop => 325,
  Pawn => 100,
  King => 9000,
  NullPiece => 0
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
      [20, 30, 30,  0,  0, 10, 30, 20]
    ]
}

class Hal < Player
  def move(board)
    # RubyProf.start
    @board = board
    #Alpha is the maximum lower bound
    @alpha = -9999
    #Beta is the minimum upper bound
    @beta = 9999
    best_move = []
    move_valuations = {}
    @board.legal_moves_of(:black).shuffle.each do |move_sequence|
      moves_value = minimax(1, move_sequence, @board, @alpha, @beta)
      move_valuations[move_sequence] = moves_value
      if moves_value < @beta
        @beta = moves_value
        best_move = move_sequence
      end
    end
    # result = RubyProf.stop
    # printer = RubyProf::FlatPrinter.new(result)
    # printer.print(STDOUT)
    print move_valuations
    best_move
  end

  def minimax(depth, sequence, board, alpha, beta)
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
          black_min = evaluation < black_min ? evaluation : black_min
        end
      end
      return black_min
    else
      white_max = -9999
      fake_board.pieces_of(current_player).each do |piece|
        piece.moves.each do |move|
          current_sequence = [sequence[1], move]
          evaluation = minimax(depth - 1, current_sequence, fake_board)
          white_max = evaluation > white_max ? evaluation : white_max
        end
      end
      return white_max
    end
  end

  def evaluate_position(this_board)
    black_sum = 0
    white_sum = 0
    this_board.pieces_of(:black).each do |piece|
      value_literal = MATERIAL_VALUES[piece.class]
      value_positional = (POSITIONAL_VALUES[piece.class][7 - piece.position[0]][7 - piece.position[1]])
      black_sum += value_literal + value_positional
    end
    this_board.pieces_of(:white).each do |piece|
      value_literal = MATERIAL_VALUES[piece.class]
      value_positional = POSITIONAL_VALUES[piece.class][piece.position[0]][piece.position[1]]
      white_sum += value_literal + value_positional
    end
    white_sum - black_sum
  end

  # def calculate_move_without_marshal(sequence, this_board)
  #   piece_type = this_board[sequence[0]].class
  #   conquered_piece_type = this_board[sequence[1]].class
  #   positional_diffing =
  #   POSITIONAL_VALUES[piece_type][sequence[0][0]][sequence[0][1]] -
  #   POSITIONAL_VALUES[piece_type][sequence[1][0]][sequence[0][1]]
  #   value_material = MATERIAL_VALUES[conquered_piece_type]
  #   starting_value = evaluate_position(this_board)
  #   debugger
  # end

  def calculate_move(sequence, this_board)
    fake_board = Marshal.load(Marshal.dump(this_board))
    fake_board.move!(sequence[0], sequence[1])
    evaluate_position(fake_board)
  end
end
