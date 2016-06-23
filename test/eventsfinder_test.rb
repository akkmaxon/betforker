require 'spec_helper'

RSpec.describe Events do
end

__END__
class EventsFinderTest < Minitest::Test

  ALL_EVENTS = {
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

  STRUCTURED_EVENTS = {
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
  def test_events_without_real_downloading
    eventsfinder = Eventsfinder.new({
                             bookies: [],
                             downloader: 'Unnecessary'
                           })
    result = eventsfinder.well_structured_events(ALL_EVENTS)
    assert_equal 3, result.size
    assert_equal STRUCTURED_EVENTS, result
    result.each do |key, val|
      assert_equal Array, val.class
      assert_equal String, key.class
      assert val.size > 1
    end
  end
end
