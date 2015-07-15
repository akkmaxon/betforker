require 'test/unit'
require 'nokogiri'
require 'forker'

# $live_page = open('html/wh_live.html').read
$event_pages = []
(1..8).each do |num|
  $event_pages << "test/html/marathon/marathon#{num}.html"
end

$live_page = open('test/html/marathon/mar_live.html').read
class TestMarathon < Test::Unit::TestCase

  def setup
    @mar = Marathon.new
  end

  def teardown
  end

  def test_mar_event_parsed
    $event_pages.each do |event_page|
      @mar = Marathon.new
      res = @mar.event_parsed(open(event_page).read)
#      p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Marathon', res[:bookie])
    end
  end

  def test_mar_live_page
    result = @mar.live_page_parsed($live_page)
#    result.each {|k,r| puts k; puts r}
    assert_equal(Hash, result.class)
    result.each do |addr, who|
      assert(addr.include? 'marathon')
      assert_equal(String, who.class)
    end
  end
end
