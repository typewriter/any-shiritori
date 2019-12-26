require "option_parser"
require "./*"

clazz = BranchAndBoundSolver

OptionParser.parse(ARGV) do |parser|
  parser.banner = "Usage: any_shiritori [FILE]"
  parser.on("-h", "--help", "Show this help") { puts parser; exit 0 }
  parser.on("-sp", "--searchproblem", "Use search problem solver") { clazz = SearchProblemSolver }
end

words : Array(String)
if ARGV.size > 0
  words = File.read(ARGV[0]).chomp.split(/\r\n|\n|\r/)
else
  words = STDIN.each_line.map(&.to_s).to_a
end

# Support Japanese shiritori rule
normalizer = JpNormalizer.new(words)
shiritori = clazz.new(normalizer.normalized_words)
answer    = normalizer.recover(shiritori.answer)

puts "Length: #{answer.size}"
puts "Shiritori: #{answer.join(" => ")}"

