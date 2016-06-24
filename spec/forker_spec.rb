require 'spec_helper'

RSpec.describe Forker do
  describe '#structure_events' do
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
    it 'returns right hash' do
      result = Forker::structure_events unstructured
      expect(result).to eq structured
    end
  end
end

