require "rspec"

require_relative "../lib/rector"

RSpec.configure do |c|
  c.mock_with :mocha

  c.before do
    Rector.reset
  end
end
