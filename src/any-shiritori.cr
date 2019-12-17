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
      names += @parent.not_nil!.tree_names if @parent
      names
    end
  end

  def initialize(words : Array(String))
    @words = words
  end

  def solve
    roots = @words.map { |word| Node.new(nil, word) }
    roots.map { |root| recursion_solve(root) }
  end

  private def recursion_solve(tree)
    unused_words = @words - tree.tree_names
    usable_words = unused_words.select { |word| tree.name[-1] == word[0] }
    usable_words.each { |word| tree.append_child(word) }
    tree.children.each { |child| recursion_solve(child) }
    tree
  end
end


shiritori = SearchProblemSolver.new(["ls", "ssh", "scp", "ps", "sort", "touch"])
pp shiritori.solve


