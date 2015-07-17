class Output

  def initialize
    @log_file = $config[:log_file]
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
    case ENV['XDG_CURRENT_DESKTOP']
    when 'KDE'
      `kdialog --passivepopup "#{to_screen}" #{$config[:time_of_notification]}`
    when 'XFCE'
      `notify-send -t #{$config[:time_of_notification] * 1000} "#{to_screen}"`
    when 'GNOME'
      `notify-send -t #{$config[:time_of_notification] * 1000} "#{to_screen}"`
    else
      puts "output to somewhere"
    end
  end

  def before_work events
    open(@log_file, 'a') do |f|
      f.write("\n-------------------I have found #{events.size} events------------- #{Time.now}\n")
      f.close
    end
  end

  def after_work time_of_beginning
    open(@log_file, 'a') do |f|
      f.write("\nIt is took #{Time.now.to_i - time_of_beginning} seconds.\n")
      f.close
    end
  end

  def parsed_bookies data
    open(@log_file, 'a') do |f|
      f.write("\n############################\n")
      data.each do |buk|
        buk.each do |key, val|
          f.write(" #{key}:  #{val}\n")
        end
      end
      f.close
    end
  end

  def thrown_forks data
    open(@log_file, 'a') do |f|
      f.write("\nThrown forks are: \n")
      f.write(" #{data}\n")
      f.close
    end
  end

  def comparer_log first, second, forks, break_now
    open(@log_file, 'a') do |f|
      f.write("\ncomparing #{first} and #{second}\n")
      f.write(" Break is #{break_now}\n")
      f.write(" #{forks}\n")
      f.close
    end

  end
end
