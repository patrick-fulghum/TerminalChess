require 'byebug'
require_relative 'board.rb'
require 'singleton'

ROOK_QUEEN_KING = [[-1, 0], [0, -1], [1, 0], [0, 1]]
BISHOP_QUEEN_KING = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
KNIGHT_GOD = [[2, 1], [1, 2], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]

class Piece
  attr_accessor :color, :position, :moved, :display_value

  def initialize(board, position, color = nil, moved = false)
    @board = board
    @position = position
    @color = color
    @moved = moved
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
