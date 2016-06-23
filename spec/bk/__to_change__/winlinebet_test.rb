require_relative 'test_helper'

class WinlinebetTest < Minitest::Test

  def setup
    @win = Winlinebet.new
    @html_folder = 'test/html/winlinebet/'
  end

  def test_winline_live_page_parsing
    html = open("#{@html_folder}win_live.htm").read
    result = @win.live_page_parsed(html)
    assert_equal Hash, result.class
    result.each do |addr, who|
      assert addr.include?('winlinebet')
      assert_equal String, addr.class
      assert_equal String, who.class
    end
#    result.each {|k,r| puts k; puts r}
  end

  def test_winline_event_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}win#{num}.htm"
    end
    events.each do |event_page|
      @win = Winlinebet.new
      res = @win.event_parsed(open(event_page).read)
#     p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Winlinebet', res[:bookie])
    end
  end
end
