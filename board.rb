require 'byebug'
require 'colorize'
require_relative 'piece.rb'

class Board
  attr_accessor :grid
  def initialize
    @grid = Array.new(8) { Array.new(8) }
    [:black, :white].each do |color|
      muster_pawns(color)
      muster_pieces(color)
    end
    muster_void
  end
  def muster_pawns(color)
    rank = color == :white ? 6 : 1
    8.times do |file|
      self[[rank, file]] = Pawn.new(self, [rank, file], color, false)
    end
  end
  def muster_pieces(color)
    rank = color == :white ? 7 : 0
    back_rank = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    back_rank.each_with_index do |piece, file|
      self[[rank, file]] = piece.new(self, [rank, file], color, false)
    end
  end
  def muster_void
    4.times do |rank|
      8.times do |file|
        self[[rank + 2, file]] = NullPiece.instance
      end
    end
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

  def on_board?(position)
    position.all? { |e| e.between?(0, 7) }
  end

  def empty?(position)
    rank, file = position
    self[[rank, file]].class == NullPiece
  end


  def pieces
    @grid.flatten.reject(&:empty?)
  end

  def fetch_king(color)
    pieces.find { |piece| piece.color == color && piece.class == King }
  end

  def in_check?(color)
    pieces.any? do |piece|
      next if fetch_king(color).nil?
      piece.color != color && piece.moves.include?(fetch_king(color).position)
    end
  end

  def move(color, start, final)
    piece = self[start]
    if color != piece.color
      raise "Move your own piece"
    end
    if !piece.moves.include?(final)
      raise "#{piece.class} doesn't move like that."
    end
    if !piece.reject_moves_into_check.include?(final)
      raise "That move puts you in check."
    end
    move!(start, final)
  end

  def move!(start, final)
    # if final == []
    #   debugger
    #   "kappa"
    # end
    piece = self[start]
    if piece.class == King && (final[1] - start[1] > 1)
      self[final] = piece
      self[start] = NullPiece.instance
      piece.moved, piece.position = true, final
      if final == 1
        rook_start_position = [start[0], 0]
        rook_final_position = [start[0], 3]
      else
        rook_start_position = [start[0], 7]
        rook_final_position = [start[0], 5]
      end
      rook = self[rook_start_position]
      self[rook_final_position] = rook
      self[rook_start_position] = NullPiece.instance
      rook.moved, rook.position = true, rook_final_position
    else
      self[final] = piece
      self[start] = NullPiece.instance
      piece.moved, piece.position = true, final
    end
    nil
  end

  def checkmate?(color)
    return false unless in_check?(color)
    my_pieces = pieces.select{ |piece| piece.color == color }
    my_pieces.all?{ |piece| piece.reject_moves_into_check.length == 0 }
  end
end
