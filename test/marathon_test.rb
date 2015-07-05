require 'test/unit'
require 'forker'

# $live_page = open('html/wh_live.html').read
$event_pages = []
(1..8).each do |num|
  $event_pages << "test/html/marathon#{num}.html"
end

$live_page = open('test/html/mar_live.html').read
class TestMarathon < Test::Unit::TestCase

  def setup
    @wh = Marathon.new
  end

  def teardown
  end

  def test_event_parsed
    $event_pages.each do |event_page|
      @wh = Marathon.new
      res = @wh.event_parsed(open(event_page).read)
      p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Marathon', res[:bookie])
    end
  end

  def test_live_page
    result = @wh.live_page_parsed($live_page)
    result.each {|k,r| puts k; puts r}
    assert_equal(Hash, result.class)
    result.each do |addr, who|
      assert(addr.include? 'marathon')
      assert_equal(String, who.class)
    end
  end
end
