require 'spec_helper'

RSpec.describe Forker::Downloader do
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
      marathon = result['marathon']
      expect(marathon.class).to eq String
      expect(marathon.size).to be > 1024
      expect(marathon).to include 'Marathonbet'
      expect(marathon).to include 'live-today-member-name'
      expect(marathon).to include 'result-description-part'
      expect(marathon).to include 'All Markets'
    end

    it 'williamhill properly' do
      p addresses
      result = Downloader.download_event_pages addresses
      williamhill = result['williamhill']
      expect(williamhill.class).to eq String
      expect(williamhill).to include 'All Markets'
      expect(williamhill).to include 'Match Betting Live'
    end

    it 'marathon without cookies'
    it 'williamhill without cookies'
    it 'with wrong addresses'
  end
end
