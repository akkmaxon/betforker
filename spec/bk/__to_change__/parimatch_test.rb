require_relative 'test_helper'

class ParimatchTest < Minitest::Test

  def setup
    @pm = Parimatch.new
    @html_folder = 'test/html/parimatch/'
  end

  def test_parimatch_live_page_parsing
    html = open("#{@html_folder}pm_live.html").read
    result = @pm.live_page_parsed(html)
    assert_equal Hash, result.class
    assert_equal 16, result.size
    result.each do |addr, who|
      assert addr.include?('parimatch.com')
      assert_equal String, addr.class
      assert_equal String, who.class
    end
#   result.each {|k,r| puts k; puts r}
  end

  def test_parimatch_event_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}parimatch#{num}.html"
    end
    events.each do |event_page|
      @pm = Parimatch.new
      res = @pm.event_parsed(open(event_page).read)
#     p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Parimatch', res[:bookie])
    end
  end

end
