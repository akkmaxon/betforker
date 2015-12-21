require_relative 'test_helper'

class SbobetTest < Minitest::Test

  def setup
    @sb = Sbobet.new
    @html_folder = 'test/html/sbobet/'
  end

  def test_sbobet_live_page_parsing
    html = open("#{@html_folder}sbobet_live.htm").read
    result = @sb.live_page_parsed(html)
    assert_equal Hash, result.class
    assert_equal 8, result.size
    result.each do |addr, who|
      assert addr.include?('sbobet')
      assert_equal String, addr.class
      assert_equal String, who.class
    end
#    result.each {|k,r| puts k; puts r}
  end

  def test_sbobet_event_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}sb#{num}.htm"
    end
    events.each do |event_page|
      @sb = Sbobet.new
      res = @sb.event_parsed(open(event_page).read)
#     p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Sbobet', res[:bookie])
    end
  end
end
