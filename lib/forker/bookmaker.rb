require 'nokogiri'

class Bookmaker
  attr_reader :live_address

  def initialize
    @live_address = String.new
  end

  def live_page_parsed html_source
    #returns hash {'WhoWho' => 'addr', ...}
  end

  def event_parsed address
    #returns hash {'game1' => { 'num_of_game' => 'coeff', 'num_of_game' => 'coeff'},
    #              'game2' => { 'num_of_game' => 'coeff', 'num_of_game' => 'coeff'},
    #              'match1' => 'some_coeff',
    #              'match2' => 'some_coeff'}
  end

  def unified_names

  end
end
