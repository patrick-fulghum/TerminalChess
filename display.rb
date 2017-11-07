require 'colorize'
require 'byebug'
require_relative 'board.rb'
require_relative 'cursor.rb'

class Display
  attr_accessor :cursor, :board

  def initialize(board)
    @cursor = Cursor.new([0, 0], board)
    @board = board
  end

  def determine_coloring(position, piece)
    if position == @cursor.cursor_pos
      if piece.class == NullPiece
        print " #{piece.display_value} "
        .colorize(background: :red)
      else
        position.reduce(:+) % 2 == 0 ?
        print " #{piece.display_value}  "
        .colorize(color: :red, background: :cyan) :
        print " #{piece.display_value}  "
        .colorize(color: :red, background: :yellow)
      end
    else
      if piece.class == NullPiece
        position.reduce(:+) % 2 == 0 ?
        print " #{piece.display_value} "
        .colorize(background: :cyan) :
        print " #{piece.display_value} "
        .colorize(background: :yellow)
      else
        position.reduce(:+) % 2 == 0 ?
        print " #{piece.display_value} "
        .colorize(color: piece.color, background: :cyan) :
        print " #{piece.display_value} "
        .colorize(color: piece.color, background: :yellow)
      end

  end

  def render
    system('clear')
    puts "   0   1   2   3   4   5   6   7"
    board.grid.length.times do |rank|
      print "#{rank} "
      board.grid[rank].each_with_index do |piece, file|
        determine_coloring([rank, file], piece)
      end
      puts ""
    end
    puts "   0   1   2   3   4   5   6   7"
  end
