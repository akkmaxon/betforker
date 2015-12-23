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
      html = @downloader.download(addr)
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
    $config[:bookies].each {|b| bookie = b if address.include?(b.downcase)}
    #####if whbetting.com 
    bookie = "WilliamHill" if bookie.empty?
    who = eval("#{bookie}.new")
  end

end
