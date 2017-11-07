require 'byebug'
require 'colorize'
require_relative 'piece.rb'

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    %i(black, white).each do |color|
      Board.muster_pawns(color)
      Board.muster_pieces(color)
    end
  end

  def self.muster_pawns(color)
    rank = color == :white ? 6 : 1
    8.times { |file| Pawn.new(self, [rank, file], color, false)
  end

  def self.muster_pieces(color)
    rank = color == :white ? 7 : 0
    back_rank = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    back_rank.each_with_index do |piece, file|
      piece.new(self, [rank, file], color, false)
    end
  end

  def self.muster_void
    4.times do |rank|
      8.times do |file|
        NullPiece.instance(self, [rank + 2, file], color = nil, moved = false)
      end
    end
  end

  def on_board?(position)
    position.all? { |e| e.between?(0, 7) }
  end

  def empty?(position)
    @grid[position] == NullPiece
  end

  def [](position)
    raise 'off Board' unless on_board?(position)
    rank, file = position
    @grid[rank][file]
  end

  def []=(position, piece)
    raise 'off Board' unless on_board?(position)
    rank, file = position
    @grid[rank][file] = piece
  end
