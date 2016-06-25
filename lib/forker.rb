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
require 'forker/bookmakers/marathon'
require 'forker/bookmakers/__to_change__/betfair'
require 'forker/bookmakers/__to_change__/parimatch'
require 'forker/bookmakers/__to_change__/sbobet'
require 'forker/bookmakers/__to_change__/winlinebet'
require 'forker/names_winlinebet'

module Forker
  include Bookmakers
  include Downloader

  ##########################################################################
  MARATHON_CHANGABLE = 'mirrormarafonbet.com'
  WILLIAMHILL_CHANGABLE = 'bukstavki77.com'
  ##########################################################################

  MARATHON_BASE = "https://www.#{MARATHON_CHANGABLE}/en/"
  MARATHON_TENNIS_LIVE = MARATHON_BASE + 'live/22723'
  WILLIAMHILL_BASE = "http://sports.#{WILLIAMHILL_CHANGABLE}/bet/en-ie/"
  WILLIAMHILL_LIVE = WILLIAMHILL_BASE + 'betlive/all'

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

  def download_live_page_for(bookie)
    Downloader.download_live_page bookie
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
