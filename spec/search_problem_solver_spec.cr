require "./spec_helper"
require "../src/search_problem_solver"

describe SearchProblemSolver do
  describe "#answer" do
    it "works correctly with one word" do
      SearchProblemSolver.new(["ssh"]).answer.should eq ["ssh"]
    end

    it "works correctly with multiple words" do
      SearchProblemSolver.new(%w[top ps ssh man]).answer.should eq %w[top ps ssh]
    end

    it "works correctly with cycle words" do
      SearchProblemSolver.new(%w[vmstat top perl ps ssh htop]).answer.should eq %w[vmstat top ps ssh htop perl]
    end
  end
end
