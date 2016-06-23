module Eventsfinder

  def self.events(all_events = get_live_events)
    events = structured_events all_events
    remove_single_events events
  end

  def self.get_live_events
    # returns hash addr => players
    events = Hash.new
    bookie_under_filter = Array.new
    bookies.each do |bookmaker|
      who = eval "#{bookmaker}.new"
      begin
        html = downloader.download who.live_address
      rescue Mechanize::ResponseCodeError
        puts "#{bookmaker} is not available now"
	next
      end
      events.merge! who.live_page_parsed html
      bookie_under_filter << bookmaker if html.include? 'minjust.ru'
    end
    Output.new.provider_filter(bookie_under_filter) unless bookie_under_filter.empty?
    events
  end

  def self.structured_events(unstructured)
    #change hash from address => players view to players => address view
    structured = Hash.new
    unstructured.each do |key, value|
      unless structured[value]
        structured[value] = [key]
      else
        structured[value].push(key)
      end
    end
    structured
  end

  def self.remove_single_events(events)
    unique = Hash.new
    events.each do |key, val|
      unique[key] = val if val.size > 1
    end
    unique
  end
end
