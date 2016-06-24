require 'forker/version.rb'
require 'forker/event.rb'
require 'forker/downloader.rb'
require 'forker/eventsfinder.rb'
require 'forker/forksfinder.rb'
require 'forker/comparer.rb'
require 'forker/output.rb'
require 'forker/bookmakers/williamhill.rb'
require 'forker/bookmakers/betfair.rb'
require 'forker/bookmakers/marathon.rb'
require 'forker/bookmakers/parimatch.rb'
require 'forker/bookmakers/sbobet.rb'
require 'forker/bookmakers/winlinebet.rb'
require 'forker/names_winlinebet.rb'
require 'capybara/poltergeist'
require 'yaml'
require 'nokogiri'
require 'mechanize'

module Forker
  MARATHON_BASE_ADDRESS = 'https://www.mirrormarafonbet.com/en/'
  MARATHON_TENNIS_LIVE_PAGE_ADDRESS = MARATHON_BASE_ADDRESS + 'live/22723'
  WILLIAMHILL_BASE_ADDRESS = 'http://sports.bukstavki77.com/bet/en-ie/'
  WILLIAMHILL_LIVE_PAGE_ADDRESS = WILLIAMHILL_BASE_ADDRESS + 'betlive/all'

  def build_events(bookmakers, sport)
    need_to_be_structured = pull_live_events bookmakers, sport
    structured_events = structure_events need_to_be_structured
    structured_events.values.map { |addresses| Event.new(addresses) }
  end

  def pull_live_events(bookmakers, sport)
    result = {}
    bookmakers.each do |bookie|
      page = download_live_page_for bookie
      result.merge eval("#{bookie}::parse_live_page #{page}")
    end
    result
  end

  def download_live_page_for(bookmaker)
    Downloader::download_live_page bookmaker
  end

  def structure_events(unstructured)
    structured = {}
    unstructured.each do |addr, names|
      unless structured.key? names
	structured[names] = [addr]
      else
	structured[names] << addr
      end
    end
    remove_single_events structured
  end

  def remove_single_events(events)
    events.select do |names, addresses|
      addresses.size > 1
    end
  end
end

include Forker
