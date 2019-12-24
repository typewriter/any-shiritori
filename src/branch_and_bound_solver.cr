# Solving the Longest Shiritori Problem
# ref. https://ci.nii.ac.jp/naid/110002768734
class BranchAndBoundSolver
  class Candidate
    property x
    getter x : Hash(String, Int32)

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

  class RouteMaker
    def self.make(x : Hash(String, Int32), a : Hash(String, Array(String)), sorted_V : Array(Char))
      data = extract_all_cycle(x, sorted_V)

      x_remained = data[0].as(Hash(String, Int32)).select { |k, v| v > 0 }.to_h
      links = data[1].as(Array(String))

      answer = [x_remained.find { |k, v| k[0] == '^' }.not_nil![0][-1].to_s]

      x_remained.delete_if { |k, v| k[0] == '^' }
      while true
        next_char = answer[-1][-1]
        answer += link_closed_path(next_char, links, a)

        x = x_remained.find { |k, v| k[0] == next_char }.not_nil![0]
        break if x[-1] == '$'
        answer << a[x].pop
        x_remained.delete(x)
      end

      answer.shift

      # validate
      (answer.size-1).times { |i|
        raise "Invalid answer: #{answer}" if answer[i][-1] != answer[i+1][0]
      }

      answer
    end

    private def self.link_closed_path(next_char : Char, links : Array(String), words : Hash(String, Array(String)))
      available_links = links.select { |link| link.includes?(next_char) }
      available_links.each { |link| links.delete(link) }

      answer = [] of String

      available_links.each { |link|
        link_dup = "#{link}#{link[1..]}"
        offset   = link.index(next_char).not_nil!
        (link.size-1).times { |i|
          answer << words["#{link_dup[i+offset]}#{link_dup[i+1+offset]}"].pop
          answer += link_closed_path(answer[-1][-1], links, words)
        }
      }

      answer
    end

    private def self.extract_all_cycle(x : Hash(String, Int32), sorted_V : Array(Char))
      link = [] of String
      d = sorted_V.map { |vi| sorted_V.map { |vj| x.has_key?("#{vj}#{vi}") ? x["#{vj}#{vi}"] : 0 }.sum }
      k = 1
      while d.max > 1
        sorted_V.each_with_index { |v, i|
          while (l = find_closed_path(v, x, k))
            link << l
            (l.size - 1).times { |i|
              x["#{l[i]}#{l[i+1]}"] -= 1
              d[sorted_V.index { |v| v == l[i] }.as(Int32)] -= 1
            }
          end
        }
        k = k + 1
      end
      [x, link]
    end

    private def self.find_closed_path(v : Char, x : Hash(String, Int32), k : Int32)
      edges = x.select { |k, v| v > 0 }.map { |e| e[0] }
      find_closed_path_recursively(v.to_s, edges, k)
    end

    private def self.find_closed_path_recursively(path : String, edges : Array(String), max_depth : Int32)
      if path.size == max_depth + 1
        return path if path[0] == path[-1]
        return nil
      end

      edges.each { |edge|
        if edge[0] == path[-1] && (path.size < 2 || !path[1..].includes?(edge[-1]))
          value = find_closed_path_recursively("#{path}#{edge[-1]}", edges, max_depth)
          return value if value
        end
      }
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
    answer = solve
    route = RouteMaker.make(answer.x.dup, @A, sorted_V)

    raise "Invalid answer: #{route}" if route.size + 2 != answer.linked_score

    route
  end

  def solve
    # Attempt RPk maximize

    try = 0
    answer = Candidate.new({} of String => Int32, @A)
    additional_constraints = [] of String
    while true
      tempfile = File.tempfile("glpk_model.mod") { |file|
        file.puts generate_glpk_model(additional_constraints)
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
      no_linked_node_chars = sorted_V - linked_node_chars.to_a

      constraint = "s.t. BRANCH_#{try}: "
      items      = [] of String
      linked_node_chars.each { |e|
        i = (sorted_V.select { |v| v == e } + [sorted_V.size])[0] + 1
        no_linked_node_chars.each { |f|
          j = sorted_V.select { |v| v == f }[0]
          items << "x[#{i},#{j}]"
        }
      }
      constraint = "s.t. BRANCH_#{try}: #{items.join(" + ")} >= 1;"
      additional_constraints << constraint

      try += 1
    end

    STDERR.puts "RPmax"
    STDERR.puts " score:   #{answer.score} (linked: #{answer.linked_score})"
    STDERR.puts " linked?: #{!answer.separated?}"
    STDERR.puts

    answer
  end

  private def sorted_V
    @V.to_a.sort
  end

  private def generate_x(result)
    x = {} of String => Int32
    v = sorted_V + ["^", "$"]
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

    sorted_V.each_with_index { |vi, i|
      sorted_V.each_with_index { |vj, j|
        model_text += "s.t. F_#{i}_#{j}: 0 <= x[#{i+1},#{j+1}] <= #{(@A["#{vi}#{vj}"]? || [] of String).size};\n"
      }
    }

    model_text += constraints.join("\n")

    model_text += "end;\n"
  end
end

words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
answer = BranchAndBoundSolver.new(words).answer

puts "Size: #{answer.size}"
puts "Answer: #{answer.join(" => ")}"

