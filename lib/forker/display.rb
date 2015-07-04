class Display

  def to_log forks_to_log
    open($config[:log_forks], 'a') do |f|
      lenght_of_line = 40
      f.write("#" * lenght_of_line)
      f.write("\n#{Time.now}\n")
      forks_to_log.each do |fork|
        fork.each do |key, val|
          space = " "
          f.write(space * ((lenght_of_line - val.size) / 2))
          f.write("#{val}\n")
        end
      end
      f.write("#" * lenght_of_line)
      f.write("\n\n")
      f.close
    end

  end

  def to_screen forks_to_screen
    to_screen = "#{forks_to_screen[0][:bookies]}\n"
    forks_to_screen.each do |fork|
      fork.each do |key, val|
        next if key == :bookies
        to_screen += "#{val}  "
      end
      to_screen += "\n"
    end
    `kdialog --passivepopup "#{to_screen}" 60`
  end

  def debug_parsed_bookies data
    open($config[:log_parsed_bookies], 'a') do |f|
      f.write("\n##############------------------------------################")
      f.write("\n#{data[0][:bookie]}                                   #{data[1][:bookie]}\n")
      f.write("#{data[0][:score]}         #{data[1][:score]}\n")
      f.write("#{data[0][:home_player][:name]}                       #{data[0][:away_player][:name]}")
      f.write("          #{data[1][:home_player][:name]}                       #{data[1][:away_player][:name]}\n")
      f.write("match #{data[0][:home_player][:match]}     match #{data[0][:away_player][:match]}")
      f.write("                       match #{data[1][:home_player][:match]}     match #{data[1][:away_player][:match]}\n")
      if data[0][:home_player].has_key?(:game)
        f.write("games #{data[0][:home_player][:game]}  games #{data[0][:away_player][:game]}")
      else
        f.write("                                         ")
      end
      if data[1][:home_player].has_key?(:game)
        f.write("         games #{data[1][:home_player][:game]}  games #{data[1][:away_player][:game]}\n")
      else
        f.write("\n")
      end
      if data[0][:home_player].has_key?(:set)
        f.write("sets #{data[0][:home_player][:set]}  sets #{data[0][:away_player][:set]}")
      else
        f.write("                                         ")
      end
      f.write("         sets #{data[1][:home_player][:set]}  sets #{data[1][:away_player][:set]}\n") if data[1][:home_player].has_key?(:set)
      f.close
    end
  end
end
