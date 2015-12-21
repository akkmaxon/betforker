class Eventsfinder

  def initialize(args)
    @bookies = args[:bookies]
    @downloader = args[:downloader]
    @ev = Hash.new
  end

  def events
    bookie_under_filter = Array.new
    @bookies.each do |bookmaker|
      who = eval("#{bookmaker}.new")
      html = @downloader.download(who.live_address)
      @ev.merge! who.live_page_parsed(html) #hash addr => players
      bookie_under_filter << bookmaker if html.include?('minjust.ru')
    end
    Output.new.provider_filter(bookie_under_filter) unless bookie_under_filter.empty?
    @ev = events_structured
    remove_single_events
  end

  private

  def events_structured
    #change hash from address => event view to event => address view
    new_evs = Hash.new
    @ev.each do |key, value|
      unless new_evs[value]
        new_evs[value] = [key]
      else
        new_evs[value].push(key)
      end
    end
    new_evs
  end

  def remove_single_events
    new_evs = Hash.new
    @ev.each do |key, val|
      new_evs[key] = val if val.size > 1
    end
    new_evs
  end
end
