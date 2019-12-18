require "option_parser"
require "./*"

OptionParser.parse(ARGV) do |parser|
  parser.banner = "Usage: any_shiritori [FILE]"
  parser.on("-h", "--help", "Show this help") { puts parser; exit 0 }
end

words : Array(String)
if ARGV.size > 0
  words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
else
  words = STDIN.each_line.map(&.to_s).to_a
end

shiritori = SearchProblemSolver.new(words)

puts "Answers:"
shiritori.answers.each { |e| puts "  #{e.tree_names.join(" -> ")}" }

puts "Solves:"
shiritori.solve.sort_by { |solve| solve.tree_names.size }.reverse.each { |e| puts "  #{e.tree_names.join(" -> ")}" }

