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
      [300,  300,  300,  300,  300,  300,  300,  300],
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
    RubyProf.start
    @board = board
    start = Time.now
    #Alpha is the maximum lower bound
    alpha = -99999
    #Beta is the minimum upper bound
    beta = 99999
    best_move = []
    current_move = []
    move_valuations = {}
    @board.legal_moves_of(color).shuffle.each do |move_sequence|
      current_move = move_sequence
      moves_value = minimax(1, move_sequence, @board, alpha, beta)
      if color == :white
        if moves_value > alpha
          best_move = move_sequence
          alpha = moves_value
        end
      else
        if moves_value < beta
          best_move = move_sequence
          beta = moves_value
        end
      end
    end
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
    print Time.now - start
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
    fake_board.legal_moves_of(current_player).each do |move|
      value = minimax(depth - 1, move, fake_board, alpha, beta)
      if current_player == :white
        alpha = value > alpha ? value : alpha
      else
        beta = value < beta ? value : beta
      end
      return alpha if current_player == :white && alpha > beta
      return beta if current_player == :black && alpha > beta
    end
    current_player == :white ? alpha : beta
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

  def calculate_move(sequence, this_board)
    fake_board = Marshal.load(Marshal.dump(this_board))
    fake_board.move!(sequence[0], sequence[1])
    evaluate_position(fake_board)
  end
end
