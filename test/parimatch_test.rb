require 'test/unit'
require 'nokogiri'
require 'forker'

$event_pages = []
(1..8).each do |num|
  $event_pages << "test/html/parimatch/parimatch#{num}.html"
end

$live_page = open('test/html/parimatch/pm_live.html').read
class TestParimatch < Test::Unit::TestCase

  def setup
    @pm = Parimatch.new
  end

  def teardown
  end

  def test_pm_event_parsed
    $event_pages.each do |event_page|
      @pm = Parimatch.new
      res = @pm.event_parsed(open(event_page).read)
      p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Parimatch', res[:bookie])
    end
  end

  def test_pm_live_page
    result = @pm.live_page_parsed($live_page)
    result.each {|k,r| puts k; puts r}
    assert_equal(Hash, result.class)
    result.each do |addr, who|
      assert(addr.include? 'parimatch.com')
      assert_equal(String, who.class)
    end
  end
end
