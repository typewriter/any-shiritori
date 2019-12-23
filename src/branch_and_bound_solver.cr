# Solving the Longest Shiritori Problem
# ref. https://ci.nii.ac.jp/naid/110002768734
class BranchAndBoundSolver
  class Candidate
    def initialize(x : Hash(String, Int32), a : Hash(String, Array(String)))
      @x = x
      @A = a
    end

    def score
      @x.map { |k, v| v }.sum
    end

    def linked_score
      linked[0].as(Int32)
    end

    def linked_node_chars
      linked[1].as(Set(Char))
    end

    def separated?
      score != linked_score
    end

    private def linked
      value = 0

      stack = ['^']
      searched = stack.to_set

      while !stack.empty?
        char = stack.pop

        keys = @x.keys.select { |key| key[0] == char }
        value += keys.map { |key| @x[key] }.sum

        next_chars = keys.map { |key| key[-1] }.select { |char| !searched.includes?(char) }
        stack += next_chars
        searched += next_chars.to_set
      end

      [value, searched]
    end
  end

  def initialize(words : Array(String))
    @A = {} of String => Array(String)
    @V = Set(Char).new
    words.each { |word|
      ij = word[0].to_s + word[-1].to_s
      @A[ij] = [] of String if !@A[ij]?
      @A[ij] << word
      @V << word[0]
      @V << word[-1]
    }
  end

  def answer
  end

  def solve
    # Attempt RPk maximize

    try = 0
    answer = Candidate.new({} of String => Int32, @A)
    additional_contraints = [] of String
    while true
      tempfile = File.tempfile("glpk_model.mod") { |file|
        file.puts generate_glpk_model(additional_contraints)
      }
      result = `glpsol -m #{tempfile.path} -o /dev/stdout`
      tempfile.delete

      candidate = Candidate.new(generate_x(result), @A)

      STDERR.puts "RP#{try}"
      STDERR.puts " score:   #{candidate.score} (linked: #{candidate.linked_score})"
      STDERR.puts " linked?: #{!candidate.separated?}"

      break if candidate.score == 0

      if !candidate.separated?
        answer = candidate if candidate.linked_score > answer.linked_score
        break
      end

      break if answer.linked_score > candidate.score

      if candidate.linked_score > answer.linked_score
        answer = candidate
      end

      # s,tを含む頂点集合からそれ以外の頂点への制約を追加する
      linked_node_chars = candidate.linked_node_chars
      no_linked_node_chars = sortedV - linked_node_chars.to_a

      constraint = "s.t. BRANCH_#{try}: "
      items      = [] of String
      linked_node_chars.each { |e|
        i = (sortedV.select { |v| v == e } + [sortedV.size])[0] + 1
        no_linked_node_chars.each { |f|
          j = sortedV.select { |v| v == f }[0]
          items << "x[#{i},#{j}]"
        }
      }
      constraint = "s.t. BRANCH_#{try}: #{items.join(" + ")} >= 1;"
      additional_contraints << constraint

      try += 1
    end

    STDERR.puts "RPmax"
    STDERR.puts " score:   #{answer.score} (linked: #{answer.linked_score})"
    STDERR.puts " linked?: #{!answer.separated?}"

    answer
  end

  private def sortedV
    @V.to_a.sort
  end

  private def generate_x(result)
    x = {} of String => Int32
    v = sortedV + ["^", "$"]
    result.each_line { |line|
      if line =~ /x\[(\d+),(\d+)\]/
        edge = "#{v[$1.to_i-1]}#{v[$2.to_i-1]}"
        count = line.gsub(/^\s+/,"").split(/\s+/)[3].to_i
        x[edge] = count if count > 0
      end
    }
    x
  end

  private def generate_glpk_model(constraints)
    model_text = <<-EOM
    param n := #{@V.size};
    param s := n+1;
    param t := n+2;
    set V := 1..n;
    set V_ST := 1..n+2;
    # set IJ within {V,V};
    # set IJ_ST within {V_ST,V_ST};

    var x{V_ST,V_ST} >=0;

    # 目的変数: 最大化
    maximize Z: sum{i in V} (sum{j in V} (x[i,j]) ) + sum{j in V} (x[s,j]) + sum{i in V} (x[i,t]);

    # 制約条件
    s.t. START: sum{j in V} (x[s,j]) = 1;
    s.t. END: sum{i in V} (x[i,t]) = 1;
    s.t. EQUAL_IOFLOW {i in V}: sum{j in V} (x[i,j])  + x[i,t] - sum{j in V} (x[j,i]) - x[s,i] = 0;

    # 制約条件（値範囲）
    s.t. STARTRANGE {j in V}: 0 <= x[s,j] <= 1;
    s.t. ENDRANGE {i in V}: 0 <= x[i,t] <= 1;
    EOM

    sortedV.each_with_index { |vi, i|
      sortedV.each_with_index { |vj, j|
        model_text += "s.t. F_#{i}_#{j}: 0 <= x[#{i+1},#{j+1}] <= #{(@A["#{vi}#{vj}"]? || [] of String).size};\n"
      }
    }

    model_text += constraints.join("\n")

    model_text += "end;\n"
  end
end

words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
p BranchAndBoundSolver.new(words).solve

