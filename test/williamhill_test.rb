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
    assert_equal 11, result.size
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

  def test_wh1_page
  #####Bedene vs Ramanathan##########
    address = "#{@html_folder}williamhill1.html"
    result = @wh.event_parsed(open(address).read)
    assert_equal 'Bedene', result[:home_player][:name]
    assert_equal 'Ramanathan', result[:away_player][:name]
    assert_equal 1.85, result[:home_player][:match]
    assert_equal 1.85, result[:away_player][:match]
    assert_equal 1.36, result[:home_player][:set]["2"]
    assert_equal 3.00, result[:away_player][:set]["2"]
    assert_equal 1.12, result[:home_player][:game]["9"]
    assert_equal 5.50, result[:away_player][:game]["9"]
  end

  def test_wh2_page
  #####Melzer vs Casanova##########
    address = "#{@html_folder}williamhill2.html"
    result = @wh.event_parsed(open(address).read)
    assert_equal 'Melzer', result[:home_player][:name]
    assert_equal 'Casanova', result[:away_player][:name]
    assert_equal 1.10, result[:home_player][:match]
    assert_equal 6.50, result[:away_player][:match]
    assert_equal 2.37, result[:home_player][:game]["2"]
    assert_equal 1.53, result[:away_player][:game]["2"]
  end

  def test_wh3_page
  #####Heras vs Andreozzi##########
    address = "#{@html_folder}williamhill3.html"
    result = @wh.event_parsed(open(address).read)
    assert_equal 'Heras', result[:home_player][:name]
    assert_equal 'Andreozzi', result[:away_player][:name]
    assert_equal 11.00, result[:home_player][:match]
    assert_equal 1.03, result[:away_player][:match]
    assert_equal 4.33, result[:home_player][:game]["9"]
    assert_equal 1.20, result[:away_player][:game]["9"]
  end
end
