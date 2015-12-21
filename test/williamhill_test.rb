require_relative 'test_helper'

class WilliamHillTest < MiniTest::Test

  def setup
    @wh = WilliamHill.new
    @html_folder = 'test/html/williamhill/'
  end

  def test_wh_live_page_parsing
    page = open("#{@html_folder}wh_live.htm").read
    result = @wh.live_page_parsed(page)
    assert_equal(Hash, result.class)
    assert_equal 2, result.size
    result.each do |addr, who|
      assert addr.include?('whbetting.com')
      assert_equal(String, who.class)
    end
#   result.each {|k,r| puts k; puts r}
  end

  def test_wh_event_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}williamhill#{num}.html"
    end
    events.each do |event_page|
      @wh = WilliamHill.new
      res = @wh.event_parsed(open(event_page).read)
#     p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('WilliamHill', res[:bookie])
    end
  end
end
