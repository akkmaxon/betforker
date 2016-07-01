require 'spec_helper'

RSpec.describe Betforker::Fork do
  describe '#show' do
    let(:data) do
      { bookmakers: 'First - Second',
	players: 'First Player  VS  Second Player',
	score: '0:0',
	what: 'match',
	percent: '3.3' }
    end

    it 'returns good output' do
      my_fork = Fork.new(data)
      output = my_fork.show
      data.each do |key, value|
	expect(output).to include value
      end
    end
  end
end
