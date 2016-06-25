require 'spec_helper'

RSpec.describe Forker::Downloader do
  describe '#download_live_page' do
    it 'for marathon properly' do
      page = Downloader.download_live_page 'Marathon'
      login_attr = Nokogiri::HTML(page).css('#auth').attribute('action').text
      expect(page.size).to be > 1024
      expect(page).to include 'Marathonbet'
      expect(page).to include '"oddsType":"Decimal"'
      expect(page).to include '"locale_name":"en"'
      expect(login_attr).to be eq MARATHON_CHANGABLE + ':443/en/login.htm'
    end

    it 'for williamhill properly' do
      page = Downloader.download_live_page 'WilliamHill'
      login_attr = Nokogiri::HTML(page).css('#login').attribute('action').text
      expect(page.size).to be > 1024
      expect(page).to include WILLIAMHILL_CHANGABLE
      expect(page).to include 'Join Now'
      expect(page).to include 'priceFormat: "decimal"'
      expect(login_attr).to be eq WILLIAMHILL_BASE
    end
  end

  describe '#download_event_pages'
end
