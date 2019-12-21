class SearchProblemSolver
  class Node
    property children
    getter children : Array(Node)

    property name
    getter name : String

    def initialize(parent : Node?, name : String)
      @parent   = parent
      @name     = name
      @children = [] of Node
    end

    def append_child(name)
      @children << Node.new(self, name)
    end

    def tree_names
      names = [@name]
      names = @parent.not_nil!.tree_names + names if @parent
      names
    end

    def leaf?
      children.empty?
    end
  end

  def initialize(words : Array(String))
    @words = words
    @longest_tree = [] of String
  end

  def generate_trees
    @longest_tree = [] of String

    roots = @words.map { |word| Node.new(nil, word) }
    roots.map { |root| generate_tree(root) }
  end

  private def generate_tree(tree)
    if STDOUT.tty? && tree.tree_names.size > @longest_tree.size
      @longest_tree = tree.tree_names
      puts "\e[2J\e[0;0HSearching...\n\nSize: #{@longest_tree.size}\nWords: [#{@longest_tree.join(" -> ")}]"
    end

    unused_words = @words - tree.tree_names
    usable_words = unused_words.select { |word| tree.name[-1] == word[0] }
    usable_words.each { |word| tree.append_child(word) }
    tree.children.each { |child| generate_tree(child) }
    tree
  end

  def answers
    leaves = solve
    max_depth = leaves.map { |leaf| leaf.tree_names.size }.max
    leaves.select { |leaf| leaf.tree_names.size == max_depth }
  end

  def solve
    trees  = generate_trees
    leaves = trees.map { |result| scan_leaf(result) }.flatten
  end

  private def scan_leaf(node : Node)
    return [node] if node.leaf?

    scan_resursion_leaf([] of Node, node)
  end

  private def scan_resursion_leaf(leaves : Array(Node), node : Node)
    leaves << node if node.leaf?

    node.children.each { |child|
      scan_resursion_leaf(leaves, child)
    }

    leaves
  end
end

