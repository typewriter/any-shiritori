# Solving the Longest Shiritori Problem
# ref. https://ci.nii.ac.jp/naid/110002768734
class BranchAndBoundSolver
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

  def answers

  end

  def solve
    # Attempt RPk maximize


    tempfile = File.tempfile("glpk_model.mod") { |file|
      file.puts generate_glpk_model
    }
    result = `glpsol -m #{tempfile.path} -o /dev/stdout`
    tempfile.delete

    generate_x(result)
  end

  private def sortedV
    @V.to_a.sort
  end

  private def generate_x(result)
    x = {} of String => Int32
    v = sortedV + ["^", "$"]
    result.each_line { |line|
      if line =~ /x\[(\d+),(\d+)\]/
        node = "#{v[$1.to_i-1]}#{v[$2.to_i-1]}"
        count = line.gsub(/^\s+/,"").split(/\s+/)[3].to_i
        x[node] = count if count > 0
      end
    }
    x
  end

  private def generate_glpk_model
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

    model_text += "end;\n"
  end
end

words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
p BranchAndBoundSolver.new(words).solve

