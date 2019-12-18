require "./*"

shiritori = SearchProblemSolver.new(["ls", "ssh", "scp", "ps", "sort", "touch"])

puts "Answers:"
shiritori.answers.each { |e| puts "  #{e.tree_names.join(" -> ")}" }

puts "Solves:"
shiritori.solve.sort_by { |solve| solve.tree_names.size }.reverse.each { |e| puts "  #{e.tree_names.join(" -> ")}" }

