require 'spec_helper'

RSpec.describe Betforker do
  let(:unstructured) { unstructured_events }
  let(:structured) { structured_events }
  $config = {}

  describe '#build_events' do
    let(:bookmakers) { ['First', 'Second'] }
    let(:sport) { 'tennis' }

    it 'successfully' do
      allow(Betforker).to receive(:pull_live_events).
	and_return(unstructured)
      result = Betforker.build_events bookmakers, sport

      expect(result.size).to eq 3
      result.each do |e|
	expect(e.class).to eq Event
	expect(e.addresses.size).to be > 1
      end
    end

    it 'with empty hash of events' do
      allow(Betforker).to receive(:pull_live_events).
	and_return({})
      result = Betforker.build_events bookmakers, sport
      expect(result.size).to eq 0
    end
  end

  describe '#structure_events' do
    it 'returns right hash' do
      result = Betforker.structure_events unstructured
      expect(result).to eq structured
    end
  end
end

