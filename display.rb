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
    if position == @cursor.cursor_pos
      if piece.class == NullPiece
        print " #{piece.display_value} ".colorize(background: :red)
      else
        if position.reduce(:+) % 2 == 0
          print " #{piece.display_value}  ".colorize(color: :red, background: :cyan)
        else
          print " #{piece.display_value}  ".colorize(color: :red, background: :yellow)
        end
      end
    else
      if piece.class == NullPiece
        if position.reduce(:+) % 2 == 0
          print " #{piece.display_value} ".colorize(background: :cyan)
        else
          print " #{piece.display_value} ".colorize(background: :yellow)
        end
      else
        if position.reduce(:+) % 2 == 0
          print " #{piece.display_value}  ".colorize(color: piece.color, background: :cyan)
        else
          print " #{piece.display_value}  ".colorize(color: piece.color, background: :yellow)
        end
      end
    end
  end

  RANK = ['H','G','F','E','D','C','B','A']

  def render
    system('clear')
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
