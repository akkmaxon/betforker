module Forker
  class Event
    attr_reader :addresses
    attr_accessor :webpages, :parsed_webpages

    def initialize(addresses)
      @addresses = addresses || []
      @webpages = {}
      @parsed_webpages = []
    end

    def get_webpages
      # 'bookie_name' => 'html text' hash
      @webpages = Forker::Downloader.download_event_pages(addresses)
    end

    def parse_webpages(bookmakers)
      bookmakers.each do |bookie|
	b = eval bookie
	b.parse_event(self)
      end
    end
  end
end
