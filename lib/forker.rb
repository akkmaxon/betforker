require 'capybara/poltergeist'
require 'yaml'
require 'nokogiri'
require 'mechanize'
require 'forker/version'
require 'forker/event'
require 'forker/parsed_page'
require 'forker/downloader'
require 'forker/comparer'
require 'forker/fork'
require 'forker/output'
require 'forker/bookmakers/williamhill'
require 'forker/bookmakers/betfair'
require 'forker/bookmakers/marathon'
require 'forker/bookmakers/parimatch'
require 'forker/bookmakers/sbobet'
require 'forker/bookmakers/winlinebet'
require 'forker/names_winlinebet'

module Forker
  include Bookmakers
  include Downloader

  MARATHON_BASE_ADDRESS = 'https://www.mirrormarafonbet.com/en/'
  MARATHON_TENNIS_LIVE_PAGE_ADDRESS = MARATHON_BASE_ADDRESS + 'live/22723'
  WILLIAMHILL_BASE_ADDRESS = 'http://sports.bukstavki77.com/bet/en-ie/'
  WILLIAMHILL_LIVE_PAGE_ADDRESS = WILLIAMHILL_BASE_ADDRESS + 'betlive/all'

  def build_events(bookmakers, sport)
    need_to_be_structured = pull_live_events bookmakers, sport
    structured_events = structure_events need_to_be_structured
    structured_events.values.map { |addresses| Event.new(addresses, sport) }
  end

  def pull_live_events(bookmakers, sport)
    result = {}
    bookmakers.each do |bookie|
      page = download_live_page_for bookie
      result.merge eval("#{bookie}.parse_live_page #{page}")
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
