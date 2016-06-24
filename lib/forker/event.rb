module Forker
  class Event
    attr_reader :addresses
    attr_accessor :webpages, :parsed_webpages

    def initialize(addresses, sport)
      @sport = sport
      @addresses = addresses || []
      @webpages = {}
      @parsed_webpages = []
      @forks = []
    end

    def find_forks
      unless @parsed_webpages.empty?
	get_webpages
	parse_webpages

      end
      @forks
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
  end
end
__END__
class Forksfinder

  attr_reader :forks, :parsed_bookies

  def initialize args
    @downloader = args[:downloader]
    @parsed_bookies = Array.new
    @comparer = Comparer.new
    @forks = Array.new
  end

  def parse addresses
    addresses.each do |addr|
      begin
        html = @downloader.download(addr)
      rescue Mechanize::ResponseCodeError
        puts "#{address} is not accessible"
      end
      @parsed_bookies << construct_hash(html, addr)
    end
  end

  def forking
    forks_found = Array.new
    while @parsed_bookies.size > 1
      first_bookie = @parsed_bookies.shift
      @parsed_bookies.each do |second_bookie|
        forks_found = @comparer.compare(first_bookie.clone, second_bookie.clone)
        forks_found.each {|fork| @forks << fork} unless forks_found.empty?
      end
    end
  end

  private
  def construct_hash html_source, address
    who = check_bookmaker(address)
    hashik = who.event_parsed(html_source)
    if hashik[:home_player][:name] < hashik[:away_player][:name]
      hashik = change_names(hashik)
    end
    hashik
  end

  def change_names hashik
    new_hashik = {
      bookie: hashik[:bookie],
      score: hashik[:score],
      home_player: hashik[:away_player],
      away_player: hashik[:home_player]
    }
  end

  def check_bookmaker address
    bookie = ""
    exceptions = { Forker::MARATHON_ADDRESS => 'Marathon', Forker::WILLIAMHILL_ADDRESS => 'WilliamHill'}
    $config[:bookies].each {|b| bookie = b if address.include?(b.downcase)}
    if bookie.empty?
      exceptions.each {|k,b| bookie = b if address.include?(k.downcase)}
    end
    who = eval("#{bookie}.new")
  end

end
