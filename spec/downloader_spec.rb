require 'spec_helper'

RSpec.describe Forker::Downloader do
  before do
    Downloader.prepare_phantomjs
  end

  after do
    Capybara.current_session.reset!
  end

  describe '#download_live_page' do

    it 'for marathon properly' do
      page = Downloader.download_live_page 'Marathon'
      login_attr = Nokogiri::HTML(page).css('#auth').attribute('action').text
      expect(page.size).to be > 1024
      expect(login_attr).to eq MARATHON_CHANGABLE + ':443/en/login.htm'
      expect(page).to include 'Marathonbet'
      expect(page).to include '"oddsType":"Decimal"'
      expect(page).to include '"locale_name":"en"'
    end

    it 'for williamhill properly' do
      page = Downloader.download_live_page 'WilliamHill'
      login_attr = Nokogiri::HTML(page).css('#login').attribute('action').text
      expect(page.size).to be > 1024
      expect(page).to include WILLIAMHILL_CHANGABLE
      expect(page).to include 'Join Now'
      expect(page).to include 'priceFormat: "decimal"'
    end

    it 'marathon without cookies' do
      allow(Marathon).to receive(:set_cookies).
	and_return([])
      page = Downloader.download_live_page 'Marathon'
      expect(page).to include '"oddsType":"Fractions"'
    end

    it 'williamhill without cookies' do
      allow(WilliamHill).to receive(:set_cookies).
	and_return([])
      Downloader.prepare_phantomjs
      page = Downloader.download_live_page 'WilliamHill'
      expect(page).to include 'priceFormat: "fraction"'
    end
  end

  describe '#download_event_pages' do
    let(:sport) { 'tennis' }
    let(:addresses) do
      %w[ Marathon WilliamHill].map do |bookie|
	live_page = Downloader.download_live_page bookie
	links = eval(bookie).parse_live_page(live_page, sport)
	links.keys.first
      end
    end

    it 'marathon properly' do
      result = Downloader.download_event_pages addresses
      page = result['marathon']
      expect(page.class).to eq String
      expect(page.size).to be > 1024
      expect(page).to include 'Marathonbet'
      expect(page).to include 'live-today-member-name'
      expect(page).to include 'result-description-part'
      expect(page).to include 'All Markets'
    end

    it 'williamhill properly' do
      result = Downloader.download_event_pages addresses
      page = result['williamhill']
      expect(page.class).to eq String
      expect(page).to include 'All Markets'
      expect(page).to include 'Match Betting Live'
    end
  end
end
