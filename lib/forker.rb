require 'capybara/poltergeist'
require 'yaml'
require 'nokogiri'
require 'mechanize'
require 'thor'
require 'highline/import'
require 'forker/version'
require 'forker/event'
require 'forker/parsed_page'
require 'forker/downloader'
require 'forker/comparer'
require 'forker/fork'
require 'forker/config'
require 'forker/bookmakers/williamhill'
require 'forker/bookmakers/marathon'

module Forker

  ##########################################################################
  MARATHON_CHANGABLE = 'https://www.marafonsportsbook.com'
  WILLIAMHILL_CHANGABLE = 'http://sports.bukstavki77.com'
  ##########################################################################

  MARATHON_BASE = MARATHON_CHANGABLE + "/en"
  MARATHON_TENNIS_LIVE = MARATHON_BASE + '/live/22723'
  WILLIAMHILL_BASE = WILLIAMHILL_CHANGABLE + "/bet/en-ie"
  WILLIAMHILL_LIVE = WILLIAMHILL_BASE + '/betlive/all'

  def build_events(bookmakers, sport)
    Downloader.prepare_phantomjs
    need_to_be_structured = pull_live_events bookmakers, sport
    structured_events = structure_events need_to_be_structured
    print_all_events(structured_events, sport) if $config[:log]
    structured_events.values.map { |addresses| Event.new(addresses, sport) }
  end

  def pull_live_events(bookmakers, sport)
    result = {}
    bookmakers.each do |bookie|
      page = download_live_page_for bookie
      result.merge! eval(bookie).parse_live_page(page, sport)
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

  def print_all_events(events, sport)
    print '=' * 20
    print "V #{events.size} events of #{sport} V"
    puts '=' * 20
    events.each do |names, addresses|
      puts names + ':'
      addresses.each do |address|
	puts " - #{address}"
      end
    end
    print '=' * 20
    print "^ #{events.size} events of #{sport} ^"
    puts '=' * 20
  end

  include Bookmakers
  include Downloader
  include Config
end

include Forker
