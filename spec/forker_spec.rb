require 'spec_helper'

RSpec.describe Forker do
  let(:unstructured) do
    {
      'mar_first_addr' => 'FirstSecond',
      'wh_third_addr' => 'FirstSecond',
      'pm_second_addr' => 'FirstSecond',
      'br_first_addr' => 'FirstSecond',
      'mar_second_addr' => 'ThirdFourth',
      'wh_first_addr' => 'ThirdFourth',
      'br_second_addr' => 'ThirdFourth',
      'mar_third_addr' => 'FifthSixth',
      'pm_first_addr' => 'FifthSixth',
      'br_third_addr' => 'FifthSixth',
      'wh_second_addr' => 'NoSuchPlayers',
      'wh_fourth_addr' => 'NoMoreSuchPlayers'
      }
  end
  let(:structured) do
    {
      'FirstSecond' => ['mar_first_addr',
			'wh_third_addr',
			'pm_second_addr',
			'br_first_addr'],
      'ThirdFourth' => ['mar_second_addr',
			'wh_first_addr',
			'br_second_addr'],
      'FifthSixth' => ['mar_third_addr',
		       'pm_first_addr',
		       'br_third_addr']
      }
  end

  describe '#build_events' do
    let(:bookmakers) { ['First', 'Second'] }
    let(:sport) { 'tennis' }

    it 'successfully' do
      allow(Forker).to receive(:pull_live_events).
	and_return(unstructured)
      result = Forker::build_events bookmakers, sport

      expect(result.size).to eq 3
      result.each do |e|
	expect(e.class).to eq Event
	expect(e.addresses.size).to be > 1
      end
    end

    it 'with empty hash of events' do
      allow(Forker).to receive(:pull_live_events).
	and_return({})
      result = Forker::build_events bookmakers, sport
      expect(result.size).to eq 0
    end
  end

  describe '#structure_events' do
    it 'returns right hash' do
      result = Forker::structure_events unstructured
      expect(result).to eq structured
    end
  end
end

