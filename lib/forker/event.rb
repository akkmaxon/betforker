module Forker
  class Event
    attr_reader :addresses, :forks
    attr_accessor :webpages, :parsed_webpages

    def initialize(addresses, sport)
      @sport = sport
      @addresses = addresses || []
      @webpages = {}
      @parsed_webpages = []
      @forks = []
    end

    def find_forks
      # [Fork, Fork, Fork]
      unless @parsed_webpages.empty?
	get_webpages
	parse_webpages
	forking
      end
      @forks.flatten
    end

    def get_webpages
      # 'bookie_name' => 'html text' hash
      pages = Forker::Downloader.download_event_pages(addresses)
      @webpages = pages if pages.size > 1
    end

    def parse_webpages(bookmakers, sport)
      # [ParsedPage, ParsedPage, ParsedPage]
      bookmakers.each do |bookie|
	b = eval bookie
	b.parse_event(self, sport)
      end
    end

    def forking
      # [Fork, Fork,[],[Fork, Fork]]
      while @parsed_webpages.size > 1
	first = @parsed_webpages.shift
	@parsed_webpages.each do |second|
	  @forks << Forker::Comparer.compare(first, second)
	end
      end
    end
  end
end
