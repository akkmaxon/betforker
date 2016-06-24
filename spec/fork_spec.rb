require 'spec_helper'

RSpec.describe Forker::Fork do
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
      expect(output).to include data[:players]
      expect(output).to include data[:bookmakers]
      expect(output).to include 'On match percent: 3.3'
    end
  end
end
