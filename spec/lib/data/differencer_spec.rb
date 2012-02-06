require "spec_helper"

describe Rector::Data::NumericDifferencer do
  subject { described_class.new(5) }

  it "returns an :add command correctly when the other object is larger" do
    commands = subject.commands_to_reconcile(10)

    commands.should == [Rector::Data::DifferencerCommand.new(:add, 5)]
  end

  it "returns an :add command correctly when the other object is smaller" do
    commands = subject.commands_to_reconcile(3)

    commands.should == [Rector::Data::DifferencerCommand.new(:add, -2)]
  end
end

describe Rector::Data::EnumerableDifferencer do
  subject { described_class.new(["a", "b", "c"]) }

  it "returns :add commands for elements that were added" do
    commands = subject.commands_to_reconcile(["a", "b", "c", "d", "e"])

    commands.should =~ [
      Rector::Data::DifferencerCommand.new(:add, "d"),
      Rector::Data::DifferencerCommand.new(:add, "e")
    ]
  end

  it "returns :remove commands for elements that were added" do
    commands = subject.commands_to_reconcile(["a"])

    commands.should =~ [
      Rector::Data::DifferencerCommand.new(:remove, "b"),
      Rector::Data::DifferencerCommand.new(:remove, "c")
    ]
  end

  it "returns a heterogenous set of commands when elements were both added and removed" do
    commands = subject.commands_to_reconcile(["a", "b", "d"])

    commands.should =~ [
      Rector::Data::DifferencerCommand.new(:remove, "c"),
      Rector::Data::DifferencerCommand.new(:add, "d")
    ]
  end
end
