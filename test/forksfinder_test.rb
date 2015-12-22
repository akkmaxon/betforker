require_relative 'test_helper'

$config = { bookies: ["Marathon", "WilliamHill", "Betfair"] }

PARSED_EVENTS = [
  { bookie: 'First',
    score: '0:0',
    home_player: { name: 'Home', :match => '1.1' },
    away_player: { name: 'Away', :match => '9.9' }
  },
  { bookie: 'Second',
    score: '0:0',
    home_player: { name: 'Home', :match => '1.1' },
    away_player: { name: 'Away', :match => '9.9' }
  }
]
class ForksfinderTest < Minitest::Test

  def test_init_bookmaker
    marathon = Forksfinder::init_bookmaker("www.marathonbet.com")
    assert_instance_of Marathon, marathon
    williamhill = Forksfinder::init_bookmaker("sports.whbetting.com")
    assert_instance_of WilliamHill, williamhill
    betfair = Forksfinder::init_bookmaker("www.betfair.com")
    assert_instance_of Betfair, betfair
  end

  def test_change_names
    event = PARSED_EVENTS[0]
    assert_instance_of Hash, event
    changed_event = Forksfinder::change_names(event.dup)
    assert_equal event[:bookie], changed_event[:bookie]
    assert_equal event[:score], changed_event[:score]
    assert_equal event[:home_player], changed_event[:away_player]
    assert_equal event[:away_player], changed_event[:home_player]
    assert_equal event[:home_player][:name], changed_event[:away_player][:name]
    assert_equal event[:away_player][:name], changed_event[:home_player][:name]
    assert_equal event[:home_player][:match], changed_event[:away_player][:match]
    assert_equal event[:away_player][:match], changed_event[:home_player][:match]
  end
end
