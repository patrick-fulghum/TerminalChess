require 'byebug'
require_relative 'board.rb'
require 'singleton'

ROOK = [[-1, 0], [0, -1], [1, 0], [0, 1]]
BISHOP = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
KNIGHT_GOD = [[2, 1], [1, 2], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]
QUEEN_KING = ROOK + BISHOP

class Piece
  attr_accessor :color, :position, :moved, :display_value

  def initialize(board, position, color = nil, moved = false)
    @board = board
    @position = position
    @color = color
    @moved = moved
  end
end

module SmoothMovement

  def terminus(starting_pos, direction)
    until @board
  end

  def legal_moves(directions)
    return [] if directions == [0, 0]
    legal_moves = []
    directions.each do |direction|
      @board
    end
  end
end

module JumpingMovement

  def legal_moves(directions)
  end
end

class Rook < Piece
  include SmoothMovement
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2656" : "\u265C"
  end

  def moves
    legal_moves(ROOK)
  end
end


class Knight < Piece
  include JumpingMovement
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2658" : "\u265E"
  end

  def moves
    legal_moves(KNIGHT_GOD)
  end
end

class Bishop
  include SmoothMovement
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2657" : "\u265D"
  end

  def moves
    legal_moves(BISHOP)
  end
end

class Queen < Piece
  include SmoothMovement
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2655" : "\u265B"
  end

  def moves
    legal_moves(QUEEN_KING)
  end
end

class King < Piece
  include JumpingMovement
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ?  "\u2654" : "\u265A"
  end

  def moves
    legal_moves(QUEEN_KING)
  end
end

class Pawn < Piece
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2659" : "\u265F"
    rank, file = position
  end

  def forward
    color == :white ? -1 : 1
  end

  def peaceful_moves
    moved ? [rank + forward, file] : [[rank + forward, file], [rank + forward * 2, file]]
  end

  def assaulting_moves

  end

end

class NullPiece < Piece
  include Singleton
  def initialize(board, position, color = nil, moved = false)
    super(position, color)
    @display_value = '  '
  end
end








#
