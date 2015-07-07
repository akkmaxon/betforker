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
    to_screen = ""
    forks_to_screen.each do |fork|
      fork.each do |key, val|
        if key == :bookies
          to_screen << "#{val}\n" unless to_screen.include?(val)
        else
          to_screen << "#{val}  "
        end
      end
      to_screen += "\n"
    end
    `kdialog --passivepopup "#{to_screen}" 30`
  end

  def debug_parsed_bookies data
    open($config[:log_parsed_bookies], 'a') do |f|
      f.write("\n############################")
      data.each do |buk|
        buk.each do |key, val|
          f.write("\n #{key}:  #{val}")
        end
      end
      f.close
    end
  end
end
