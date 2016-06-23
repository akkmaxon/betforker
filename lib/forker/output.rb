module Output

  def self.to_screen(forks_to_screen)
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

    `notify-send -t #{$config[:time_of_notification] * 1000} "#{to_screen}"`
    `paplay /usr/share/sounds/freedesktop/stereo/complete.oga` if $config[:sound_notification]
  end

  def self.before_work(events)
    open($config[:log_file], 'a') do |f|
      f.write("\n-------------------I have found #{events.size} events------------- #{Time.now}\n")
    end
  end

  def self.after_work(time_of_beginning)
    open($config[:log_file], 'a') do |f|
      f.write("\nIt is took #{Time.now.to_i - time_of_beginning} seconds.\n")
    end
  end

  def self.parsed_bookies(data)
    open($config[:log_file], 'a') do |f|
      f.write("\n############################\n")
      data.each do |buk|
        buk.each do |key, val|
          f.write(" #{key}:  #{val}\n")
        end
      end
    end
  end

  def self.thrown_forks(data)
    open($config[:log_file], 'a') do |f|
      f.write("\nThrown forks are: \n")
      f.write(" #{data}\n")
    end
  end

  def self.comparer_log(first, second, forks, break_now)
    open($config[:log_file], 'a') do |f|
      f.write("\ncomparing #{first} and #{second}\n")
      f.write(" Break is #{break_now}\n")
      f.write(" Forks are:\n") unless forks.empty?
      f.write(" #{forks}\n")
    end
  end

  def self.provider_filter(bookies)
    open($config[:log_file], 'a') do |f|
      f.write("\nProvider does not let you download: #{bookies.join(', ')} \n")
    end
  end
end
