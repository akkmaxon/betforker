module Forker
  module Config
    def update
      print_current_config
      if true_or_false ask 'Будешь что-нибудь менять? (y/N) '
	new_values = manual_enter
	update_config new_values
	print_current_config
      end
    end

    def update_config(values)
      values.each do |key, value|
	$config[key] = value
      end
    end

    def print_current_config
      puts 'Текущая конфигурация:'
      $config.each do |key, value|
	puts "\t#{key} => #{value}"
      end
    end

    def manual_enter
      result = {}
      $config.each_with_index do |key, index|
	puts " #{index} > #{key}"
      end
      puts "#{$config.size} > поменять все"
      entry = ask('Выбери то, что хочешь изменить (число): ', Integer) { |q| q.in = 0..$config.size }
      result.merge case entry
		   when 0 then set_marathon_changable
		   when 1 then set_williamhill_changable
		   when 2 then set_download_timeout
		   when 3 then set_min_percent
		   when 4 then set_time_of_notification
		   when 5 then set_filtering
		   when 6 then set_sound_notification
		   when 7 then set_log
		   when 8 then set_phantomjs_logger
		   when 9 then set_sport
		   when 10 then set_bookmakers
		   else all_fields
		   end
    end

    def all_fields
      config = {}
      config[:marathon_changable] = set_marathon_changable
      config[:williamhill_changable] = set_williamhill_changable
      config[:download_timeout] = set_download_timeout
      config[:min_percent] = set_min_percent
      config[:time_of_notification] = set_time_of_notification
      config[:filtering] = set_filtering
      config[:sound_notification] = set_sound_notification
      config[:log] = set_log
      config[:phantomjs_logger] = set_phantomjs_logger
      config[:sport] = set_sport
      config[:bookmakers] = set_bookmakers
      config
    end

    def set_marathon_changable
      address = ask("\tВпиши новый адрес формата https://newmarathontrololo.com > ")
      { marathon_changable: address }
    end

    def set_williamhill_changable
      address = ask("\tВпиши новый адрес формата http://sports.newwilliamhillrololo.com > ")
      { williamhill_changable: address }
    end

    def set_download_timeout
      timeout = ask("\tdownloader timeout > ", Integer)
      { download_timeout: timeout }
    end

    def set_min_percent
      percent = ask("\tминимальный процент (число) > ", Float) do |q|
	q.in = Forker::Comparer::FAKE_PERCENT...Forker::Comparer::UNREAL_PERCENT
      end
      { min_percent: percent }
    end

    def set_time_of_notification
      time = ask("\tвремя показа вилки в секундах > ", Integer) { |q| q.in = 1..120 }
      { time_of_notification: time }
    end

    def set_filtering
      { filtering: true_or_false(ask("\tфильтровать показ вне перерывов (y/N) > ")) }
    end

    def set_sound_notification
      { sound_notification: true_or_false(ask("\tзвук найденной вилки (y/N) > ")) }
    end

    def set_log
      { log: true_or_false(ask("\tпоказывать в терминале, что происходит (y/N) > ")) }
    end

    def set_phantomjs_logger
      { phantomjs_logger: true_or_false(ask("\tпоказывать логи phantomjs (y/N) > ")) }
    end

    def set_sport
      { sport: 'tennis' }
    end

    def set_bookmakers
      { bookmakers: ['Marathon', 'WilliamHill'] }
    end

    def true_or_false(answer)
      if answer =~ /^y/i then true else false end
    end
  end
end
