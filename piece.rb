require 'byebug'
require_relative 'board.rb'
require 'singleton'

ROOK = [[-1, 0], [0, -1], [1, 0], [0, 1]]
BISHOP = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
KNIGHT_GOD = [[2, 1], [1, 2], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]
QUEEN_KING = ROOK + BISHOP

class Piece
  attr_reader :board
  attr_accessor :color, :position, :moved, :display_value

  def initialize(board, position, color = nil, moved = false)
    @board = board
    @position = position
    @color = color
    @moved = moved
  end

  def empty?
    rank, file = position
    return self.class if self.class == NullPiece
    @board[[rank, file]].class == NullPiece
  end

  def on_board?(location)
    location.all?{ |pos| pos.between?(0, 7) }
  end

  def move_into_check?(fin)
    fake_board = Marshal.load(Marshal.dump(board))
    fake_board.move!(position, fin)
    fake_board.in_check?(color)
  end

  def reject_moves_into_check
    moves.reject{ |move| move_into_check?(move) }
  end
end

module SmoothMovement

  def legal_moves(directions)
    x, y = position
    legal_moves = []
    directions.each do |direction|
      dx, dy = direction
      iterant = 0
      while true
        iterant += 1
        current_position = [x + iterant * dx, y + iterant * dy]
        break unless on_board?(current_position)
        if board.empty?(current_position)
          legal_moves << current_position
        else
          if board[current_position].color != color
            legal_moves << current_position
          end
          break
        end
      end
    end
    legal_moves
  end
end

module JumpingMovement

  def legal_moves(directions)
    x, y = position
    legal_moves = []
    directions.each do |direction|
      dx, dy = direction
      current_position = [x + dx, y + dy]
      if on_board?(current_position) && (board.empty?(current_position) || board[current_position].color != color)
        legal_moves << current_position
      end
    end
    legal_moves
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

class Bishop < Piece
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

  def castling
    rank = position[0]
    file = position[1]
    castle_maneuvers = []
    if !moved
      kings_rooks = board.pieces.find_all do |rook|
        rook.class == Rook && rook.color == color && rook.moved == false
      end
      kings_rooks.each do |rooky|
        rook_file = rooky.position[1]
        if rook_file == 0
          if (rook_file + 1...file).all?{ |f| board.empty?([rank, f]) }
            unless move_into_check?([rank, 3]) || move_into_check?([rank, 2])
              castle_maneuvers += [rank, 2]
            end
          end
        else
          if (file + 1...rook_file).all?{ |f| board.empty?([rank, f]) }
            unless move_into_check?([rank, 5]) || move_into_check?([rank, 6])
              castle_maneuvers += [rank, 6]
            end
          end
        end
      end
    end
    [castle_maneuvers]
  end

  def moves
    (legal_moves(QUEEN_KING)+ castling).reject{ |m| m == []}
  end
end

class Pawn < Piece
  def initialize(board, position, color = nil, moved = false)
    super(board, position, color)
    @display_value = color == :white ? "\u2659" : "\u265F"
  end

  def advances
    color == :white ? -1 : 1
  end

  def attacks
    [[position[0] + advances, position[1] - 1], [position[0] + advances, position[1] + 1]]
  end

  def en_passant
  #En passant (from French: in passing) is a move in chess.[1]
  #It is a special pawn capture that can only occur
  #immediately after a pawn makes a double-step move from its starting square,
  #and it could have been captured by an enemy pawn had it advanced only one square.
  #The opponent captures the just-moved pawn "as it passes" through the first square.
  #The result is the same as if the pawn had advanced only one square
  #and the enemy pawn had captured it normally.
  #The en passant capture must be made on the very next turn or the right to do so is lost.
  end



  def moves
    legal_moves = []
    if board.empty?([position[0] + advances, position[1]])
      legal_moves << [position[0] + advances, position[1]]
      if moved == false && board.empty?([position[0] + advances * 2, position[1]])
        legal_moves << [position[0] + advances * 2, position[1]]
      end
    end
    attacks.each do |pos|
      if on_board?(pos) && board[pos].color != color && !board.empty?(pos)
        legal_moves << pos
      end
    end
    legal_moves
  end
end

class NullPiece < Piece
  include Singleton
  def initialize
    @display_value = '  '
    @color = nil
  end

  def moves
    []
  end
end








#
