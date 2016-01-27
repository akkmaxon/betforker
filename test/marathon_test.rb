require_relative 'test_helper'

class MarathonTest < Minitest::Test

  def setup
    @mar = Marathon.new
    @html_folder = 'test/html/marathon/'
  end

  def test_good_live_page_parsing
    html_source = open("#{@html_folder}mar_live.htm").read
    result_hash = @mar.live_page_parsed(html_source)
    assert_equal Hash, result_hash.class
    assert_equal 10, result_hash.size
    result_hash.each do |addr, who|
      assert addr.include?('mbet128')
      assert_equal String, addr.class
      assert_equal String, who.class
    end
#   result_hash.each {|k,r| puts k; puts r}
  end

  def test_good_event_page_parsing
    events = []
    (1..4).each do |num|
      events << "#{@html_folder}marathon#{num}.htm"
    end
    events.each do |event|
      @mar = Marathon.new
      res = @mar.event_parsed(open(event).read)
#     p res
      assert_equal(String, res[:home_player][:name].class)
      assert_equal(String, res[:away_player][:name].class)
      assert_equal(Hash, res[:home_player].class)
      assert_equal(Hash, res[:away_player].class)
      assert_equal(String, res[:score].class)
      assert_equal('Marathon', res[:bookie])
    end
  end
  
  def test_marathon1_page
  #####Pliskova vs Beygelzimer##########
    address = "#{@html_folder}marathon1.htm"
    result = @mar.event_parsed(open(address).read)
    assert_equal 'Pliskova', result[:home_player][:name]
    assert_equal 'Beygelzimer', result[:away_player][:name]
    assert_equal '15:40 (0:1 (4:6, 4:2))', result[:score]
    assert_equal 1.68, result[:home_player][:match]
    assert_equal 2.2, result[:away_player][:match]
    assert_equal 1.2, result[:home_player][:set]["2"]
    assert_equal 4.55, result[:away_player][:set]["2"]
    assert_equal 2.05, result[:home_player][:game]["8"]
    assert_equal 1.77, result[:away_player][:game]["8"]
  end

  def test_marathon2_page
  #####Humberg vs Haylaz##########
    address = "#{@html_folder}marathon2.htm"
    result = @mar.event_parsed(open(address).read)
    assert_equal 'Humbert', result[:home_player][:name]
    assert_equal 'Haylaz', result[:away_player][:name]
    assert_equal 1.009, result[:home_player][:match]
    assert_equal 20.00, result[:away_player][:match]
    assert_equal 1.055, result[:home_player][:set]["2"]
    assert_equal 9.00, result[:away_player][:set]["2"]
    assert_equal 1.25, result[:home_player][:game]["6"]
    assert_equal 3.90, result[:away_player][:game]["6"]
  end
end
