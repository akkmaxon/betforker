require 'spec_helper'

RSpec.describe Eventsfinder do
  describe '#events' do
    let(:all_events) do
      {
	'mar_first_addr' => 'FirstSecond',
	'mar_second_addr' => 'ThirdFourth',
	'mar_third_addr' => 'FifthSixth',
	'wh_first_addr' => 'ThirdFourth',
	'wh_second_addr' => 'NoSuchPlayers',
	'wh_third_addr' => 'FirstSecond',
	'pm_first_addr' => 'FifthSixth',
	'pm_second_addr' => 'FirstSecond',
	'br_first_addr' => 'FirstSecond',
	'br_second_addr' => 'ThirdFourth',
	'br_third_addr' => 'FifthSixth'
	}
    end
    let(:structured_events) do
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
  
    it 'find successfully' do
      result = Eventsfinder.events(all_events)
      expect(result.class).to eq Hash
      expect(result.size).to eq 3
      expect(result).to eq structured_events
      result.each do |key, val|
	expect(key.class).to eq String
	expect(val.class).to eq Array
	expect(val.size).to be > 1
      end
    end
  end
end
