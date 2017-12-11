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

LATE_GAME = {
  King => [
    [-50,-40,-30,-20,-20,-30,-40,-50],
    [-30,-20,-10,  0,  0,-10,-20,-30],
    [-30,-10, 20, 30, 30, 20,-10,-30],
    [-30,-10, 30, 40, 40, 30,-10,-30],
    [-30,-10, 30, 40, 40, 30,-10,-30],
    [-30,-10, 20, 30, 30, 20,-10,-30],
    [-30,-30,  0,  0,  0,  0,-30,-30],
    [-50,-30,-30,-30,-30,-30,-30,-50]
  ],
  Pawn => [
    [300,  300,  300,  300,  300,  300,  300,  300],
    [100, 100, 100, 100, 100, 100, 100, 100],
    [80, 80, 80, 80, 80, 80, 80, 80],
    [60, 60, 60, 60, 60, 60, 60, 60],
    [40, 40, 40, 40, 40, 40, 40, 40],
    [20, 20, 20, 20, 20, 20, 20, 20],
    [0,  0,  0,  0,  0,  0,  0,  0],
    [0,  0,  0,  0,  0,  0,  0,  0]
  ]
}

class Hal < Player
  def move(board)
    # RubyProf.start
    @board = board
    start = Time.now
    alpha = -99999
    beta = 99999
    best_move = []
    current_move = []
    move_valuations = {}
    @board.legal_moves_of(color).shuffle.each do |move_sequence|
      current_move = move_sequence
      moves_value = minimax(2, move_sequence, @board, alpha, beta)
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
      if Time.now - start > 15
        break
      end
      move_valuations[move_sequence] = moves_value
    end
    # result = RubyProf.stop
    # printer = RubyProf::FlatPrinter.new(result)
    # printer.print(STDOUT)
    while true
      if color == :white
        fake_board = Marshal.load(Marshal.dump(board))
        best_move = move_valuations.max_by { |a, b| b }[0]
        fake_board.move!(best_move[0], best_move[1])
        if fake_board.in_check?(color)
          fake_board = nil
          move_valuations[best_move] = -99999
        else
          break
        end
      else
        fake_board = Marshal.load(Marshal.dump(board))
        best_move = move_valuations.min_by { |a, b| b }[0]
        fake_board.move!(best_move[0], best_move[1])
        if fake_board.in_check?(color)
          fake_board = nil
          move_valuations[best_move] = 99999
        else
          break
        end
      end
    end
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
      if basic_eval(:black, this_board) < 10100 && (piece.class == King || piece.class == Pawn)
        value_positional = LATE_GAME[piece.class][7 - piece.position[0]][7 - piece.position[1]]
      else
        value_positional = POSITIONAL_VALUES[piece.class][7 - piece.position[0]][7 - piece.position[1]]
      end
      black_sum += value_literal + value_positional
    end
    this_board.pieces_of(:white).each do |piece|
      value_literal = MATERIAL_VALUES[piece.class]
      if basic_eval(:white, this_board) < 10100 && (piece.class == King || piece.class == Pawn)
        value_positional = LATE_GAME[piece.class][piece.position[0]][piece.position[1]]
      else
        value_positional = POSITIONAL_VALUES[piece.class][piece.position[0]][piece.position[1]]
      end
      white_sum += value_literal + value_positional
    end
    white_sum - black_sum
  end

  def basic_eval(color, this_board)
    value_literal = 0
    this_board.pieces_of(color).each do |piece|
      value_literal += MATERIAL_VALUES[piece.class]
    end
    value_literal
  end

  def calculate_move(sequence, this_board)
    fake_board = Marshal.load(Marshal.dump(this_board))
    fake_board.move!(sequence[0], sequence[1])
    evaluate_position(fake_board)
  end
end
