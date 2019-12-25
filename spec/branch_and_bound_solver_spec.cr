require "./spec_helper"
require "../src/branch_and_bound_solver"

describe BranchAndBoundSolver do
  describe "#answer" do
    it "works correctly with one word" do
      BranchAndBoundSolver.new(["ssh"]).answer.should eq ["ssh"]
    end

    it "works correctly with multiple words" do
      BranchAndBoundSolver.new(%w[top ps ssh man]).answer.should eq %w[top ps ssh]
    end

    it "works correctly with cycle words" do
      BranchAndBoundSolver.new(%w[vmstat top perl ps ssh htop]).answer.should eq %w[vmstat top ps ssh htop perl]
    end
  end
end
