require 'test/unit'
require 'nokogiri'
require 'forker'

$event_pages = []
(1..8).each do |num|
  $event_pages << "test/html/sbobet/sb#{num}.htm"
end

$live_page = open('test/html/sbobet/sbobet_live.htm').read
class TestSbobet < Test::Unit::TestCase

  def setup
    @sb = Sbobet.new
  end

  def teardown
  end

  def test_sb_event_parsed
    $event_pages.each do |event_page|
      @sb = Sbobet.new
      res = @sb.event_parsed(open(event_page).read)
      p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Sbobet', res[:bookie])
    end
  end

  def test_sb_live_page
    result = @sb.live_page_parsed($live_page)
#    result.each {|k,r| puts k; puts r}
    assert_equal(Hash, result.class)
    result.each do |addr, who|
      assert(addr.include? 'sbobet')
      assert_equal(String, who.class)
    end
  end
end
