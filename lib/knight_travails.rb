require_relative 'board.rb'
require_relative 'display.rb'
require_relative 'node.rb'
require 'byebug'

class KnightTravails
  def initialize
    @board = Board.new
    @board.slaughter
    @display = Display.new(@board)
  end

  def play
    puts "Move the cursor with the left,right, up and down arrows.
      The first selection is where the knight wil be placed;
      The second is where the knight will travail(with laborious difficulty)"
    start, final = nil, nil
    until start && final
      @display.render(start)
      if start
        final = @display.cursor.get_input
      else
        start = @display.cursor.get_input
      end
    end
    puts "Calculating Route..."
    root_node = self.create_move_tree(start)
    sleep(1)
    our_moves = self.find_path(root_node, final)
    @board.slaughter
    self.pretty_print(our_moves)
    puts "The shortest route is #{our_moves}"
  end

  def pretty_print(our_moves)
    our_moves.each do |move|
      @board[move] = Knight.new(@board, move, :black, false)
      @display.render(nil)
      sleep(0.5)
    end
  end

  def create_move_tree(root)
    nodes = []
    root_node = Node.new(root)
    nodes << root_node
    until nodes.empty?
      current_node = nodes.shift
      pos = current_node.position
      @board[pos] = Knight.new(@board, pos, :black, false)
      @board[pos].moves.each do |move|
        next_node = Node.new(move)
        current_node.add_child(next_node)
        nodes << next_node
      end
    end
    root_node
  end

  def find_path(root_node, terminus)
    target_node = root_node.breadth_first_search(terminus)
    array_of_moves = []
    until target_node.parent.nil?
      array_of_moves.unshift(target_node.position)
      target_node = target_node.parent
    end
    array_of_moves.unshift(root_node.position)
  end
end
