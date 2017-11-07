require 'byebug'
require_relative 'board.rb'
require 'singleton'

ROOK_QUEEN_KING = [[-1, 0], [0, -1], [1, 0], [0, 1]]
BISHOP_QUEEN_KING = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
KNIGHT_GOD = [[2, 1], [1, 2], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]
