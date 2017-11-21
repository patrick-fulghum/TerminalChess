require 'colorize'
require 'byebug'
require_relative 'board.rb'
require_relative 'cursor.rb'

class Display
  attr_accessor :cursor, :board

  def initialize(board)
    @cursor = Cursor.new([6, 4], board)
    @board = board
  end

  def determine_coloring(position, piece)
    if position == @selectedPosition
      print " #{piece.display_value}  ".colorize(color: piece.color, background: :blue)
    else
      if position == @cursor.cursor_pos
        if piece.class == NullPiece
          print " #{piece.display_value}  ".colorize(background: :red)
        else
          if position.reduce(:+) % 2 == 0
            print " #{piece.display_value}  ".colorize(color: :red, background: :white)
          else
            print " #{piece.display_value}  ".colorize(color: :red, background: :light_black)
          end
        end
      else
        if piece.class == NullPiece || piece.color == :white
          if @pieces_moves.include?(position)
            print " #{piece.display_value}  ".colorize(background: :cyan)
          elsif position.reduce(:+) % 2 == 0
            print " #{piece.display_value}  ".colorize(background: :white)
          else
            print " #{piece.display_value}  ".colorize(background: :light_black)
          end
        else
          if @pieces_moves.include?(position)
            print " #{piece.display_value}  ".colorize(color: piece.color, background: :cyan)
          elsif position.reduce(:+) % 2 == 0
            print " #{piece.display_value}  ".colorize(color: piece.color, background: :white)
          else
            print " #{piece.display_value}  ".colorize(color: piece.color, background: :light_black)
          end
        end
      end
    end
  end

  RANK = ['H','G','F','E','D','C','B','A']

  def render(selectedPosition)
    system('clear')
    @selectedPosition = selectedPosition
    @pieces_moves = []
    if !selectedPosition.nil?
      @board[selectedPosition].reject_moves_into_check.each do |move|
        @pieces_moves += [move]
      end
    end
    puts "   1   2   3   4   5   6   7   8"
    board.grid.length.times do |rank|
      print "#{RANK[rank]} "
      board.grid[rank].each_with_index do |piece, file|
        determine_coloring([rank, file], piece)
      end
      print " #{RANK[rank]} "
      puts ""
    end
    puts "   1   2   3   4   5   6   7   8"
  end
end
