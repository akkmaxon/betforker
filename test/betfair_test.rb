require_relative 'test_helper'

class BetfairTest < Minitest::Test

  def setup
    @bf = Betfair.new
    @html_folder = 'test/html/betfair/'
  end

  def test_betfair_live_page_parsing
    html = open("#{@html_folder}bf_live.htm").read
    result = @bf.live_page_parsed(html)
#    result.each {|k,r| puts k; puts r}
    assert_equal Hash, result.class
    result.each do |addr, who|
      assert addr.include?('www.betfair.com')
      assert_equal String, addr.class
      assert_equal String, who.class
    end
  end

  def test_betfair_event_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}betfair#{num}.html"
    end
    events.each do |event_page|
      @bf = Betfair.new
      res = @bf.event_parsed(open(event_page).read)
#      p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Betfair', res[:bookie])
    end
  end
end
