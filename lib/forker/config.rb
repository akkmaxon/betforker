module Forker
  module Config
    def update
      print_current_config
      if true_or_false ask 'Do you want to edit the config? (y/N) '
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
      puts 'Current config is:'
      $config.each do |key, value|
	puts "\t#{key} => #{value}"
      end
    end

    def manual_enter
      result = {}
      puts 'Enter new values below:'
      all_fields result
    end

    def all_fields(config)
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

    def set_min_percent
      ask("\tminimal percent (number): ", Float) do |q|
	q.in = Forker::Comparer::FAKE_PERCENT...Forker::Comparer::UNREAL_PERCENT
      end
    end

    def set_time_of_notification
      ask("\ttime of showing notifications (seconds): ", Integer) { |q| q.in = 1..120 }
    end

    def set_filtering
      true_or_false ask("\tfiltering markets (y/N): ")
    end

    def set_sound_notification
      true_or_false ask("\tsound notifications (y/N): ")
    end

    def set_log
      true_or_false ask("\twork in log mode (y/N): ")
    end

    def set_phantomjs_logger
      true_or_false ask("\tshow phantomjs logs (y/N): ")
    end

    def set_sport
      'tennis'
    end

    def set_bookmakers
      ['Marathon', 'WilliamHill']
    end

    def true_or_false(answer)
      if answer =~ /^y/i then true else false end
    end
  end
end
