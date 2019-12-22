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
    puts generate_glpk_model
  end

  private def generate_glpk_model
    model_text = <<-EOM
    param n := #{@V.size};
    param s := n+1;
    param t := n+2;
    set V := 1..n;
    set V_ST := 1..n+2;
    set IJ within {V,V};
    set IJ_ST within {V_ST,V_ST};

    param f{IJ};
    var x{IJ_ST};

    # 目的変数: 最大化
    maximize Z: sum{i in V} (sum{j in V} (x[i,j]) ) + sum{j in V} (x[s,j]) + sum{i in V} (x[i,t]);

    # 制約条件
    s.t. START: sum{j in V} (x[s,j]) = 1;
    s.t. END: sum{i in V} (x[i,t]) = 1;
    s.t. EQUAL_IOFLOW {i in V}: sum{j in V} (x[i,j]) - sum{j in V} (x[j,i]) = 0;

    # 制約条件（値範囲）
    s.t. STARTRANGE {j in V}: 0 <= x[s,j] <= 1;
    s.t. ENDRANGE {i in V}: 0 <= x[i,t] <= 1;

    EOM

    @V.each_with_index { |vi, i|
      @V.each_with_index { |vj, j|
        model_text += "s.t. F_#{vi}#{vj}: 0 <= x[#{i},#{j}] <= #{(@A["#{vi}#{vj}"]? || [] of String).size};\n"
      }
    }

    model_text += "end;\n"
  end
end

words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
BranchAndBoundSolver.new(words).solve
