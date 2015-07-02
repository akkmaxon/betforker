class Display

  def to_screen forks_to_screen
    lenght_of_line = 40
    puts "#" * lenght_of_line
    forks_to_screen.each do |fork|
      fork.each do |key, val|
        space = " "
        print space * ((lenght_of_line - val.size) / 2)
        puts val
      end
    end
    puts "#" * lenght_of_line
  end

  def debug_parsed_bookies data
    puts '##############------------------------------------------################'
    puts "#{data[0][:bookie]}                                   #{data[1][:bookie]}"
    puts "#{data[0][:score]}         #{data[1][:score]}"
    print "#{data[0][:home_player][:name]}                       #{data[0][:away_player][:name]}"
    puts "          #{data[1][:home_player][:name]}                       #{data[1][:away_player][:name]}"
    print "match #{data[0][:home_player][:match]}     match #{data[0][:away_player][:match]}"
    puts "                       match #{data[1][:home_player][:match]}     match #{data[1][:away_player][:match]}"
    print "games #{data[0][:home_player][:game]}  games #{data[0][:away_player][:game]}"
    puts "         games #{data[1][:home_player][:game]}  games #{data[1][:away_player][:game]}"
  end

end
