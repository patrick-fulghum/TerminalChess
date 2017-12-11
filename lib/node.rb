class Node
  attr_accessor :position, :children
  attr_reader :parent
  def initialize(position = nil, children = [], parent = nil)
    @position = position
    @children = children
    @parent = parent
  end

  def depth_first_search(target = nil)
    if target == self.position
      return self
    else
      self.children.each do |child_node|
        child_node.depth_first_search(target)
      end
    end
    nil
  end

  def breadth_first_search(target = nil)
    nodes = [self]
    until nodes.empty?
      current_node = nodes.shift
      return current_node if target == current_node.position
      current_node.children.each do |child_node|
        nodes << child_node
      end
    end
    nil
  end

  def parent=(parent)
    return if self.parent == parent
    if self.parent
      self.parent.children.delete(self)
    end
    @parent = parent
    self.parent.children << self unless self.parent.nil?
  end

  def add_child(child)
    child.parent = self
  end

end
