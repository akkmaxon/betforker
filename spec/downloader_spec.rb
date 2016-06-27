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
end
