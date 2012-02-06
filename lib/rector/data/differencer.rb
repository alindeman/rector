module Rector
  module Data
    class DifferencerCommand < Struct.new(:command, :value)
      COMMANDS = [:add, :remove]
    end

    class DifferencerFactory
      def self.for(obj)
        case obj
        when Numeric
          NumericDifferencer.new(obj)
        when Enumerable
          EnumerableDifferencer.new(obj)
        end
      end
    end

    class NumericDifferencer < Struct.new(:obj)
      def commands_to_reconcile(other)
        [DifferencerCommand.new(:add, other - obj)]
      end
    end

    class EnumerableDifferencer < Struct.new(:obj)
      def commands_to_reconcile(other)
        elements_to_add    = other - obj
        elements_to_remove = obj - other

        [].tap do |commands|
          commands.concat elements_to_add.map    { |e| DifferencerCommand.new(:add,    e) }
          commands.concat elements_to_remove.map { |e| DifferencerCommand.new(:remove, e) }
        end
      end
    end
  end
end
