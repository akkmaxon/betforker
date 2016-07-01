module Forker
  module Config
    module_function

    PERSONAL_CONFIG = "#{ENV['HOME']}/.forker.conf.yml"

    def config_initialization!
      template= YAML.load File.open(File.dirname(__FILE__) + '/../../config.yml', 'r')
      write_personal_config(template) unless File.exist? PERSONAL_CONFIG
      personal= YAML.load File.open(PERSONAL_CONFIG, 'r')
      $config = check_personal_configuration template, personal
    end

    def check_personal_configuration(template, personal)
      same_values = []
      2.times do
	if template.keys == personal.keys
	  template.values.each_with_index do |tempval, index|
	    same_values << same_typeofs(tempval.class, personal.values[index].class)
	  end
	  if same_values.include? false
	    new = {}
	    template.each do |key, value|
	      new[key] = if same_typeofs value.class, personal[key].class
			   personal[key]
			 else
			   value
			 end
	    end
	    personal = new
	    write_personal_config(personal)
	  end
	  break
	else
	  new = {}
	  template.each do |key, value|
	    new[key] = if personal[key] then personal[key] else value end
	  end
	  personal = new
	  write_personal_config(personal)
	end
      end
      personal
    end

    def same_typeofs(a, b)
      (a == b) or (a == TrueClass and b == FalseClass) or
      (a == FalseClass and b == TrueClass)
    end

    def write_personal_config(config)
      File.open(PERSONAL_CONFIG, 'w') do |file|
	yaml = YAML.dump config
	file.write yaml
      end
    end

    def update
      print_current_config
      if true_or_false ask 'Будешь что-нибудь менять? (y/N) '
	new_values = manual_enter
	update_config new_values
	print_current_config
      end
    end

    def update_config(values)
      $config = {}
      values.each do |key, value|
	$config[key] = value
      end
    end

    def print_current_config
      puts 'Текущая конфигурация:'
      $config.each do |key, value|
	puts "   #{translate key} => #{value}"
      end
    end

    def manual_enter
      result = {}
      $config.each_with_index do |value, index|
	puts "   #{index} - #{translate value.first}"
      end
      puts "   #{$config.size} - поменять все"
      entry = ask('Выбери то, что хочешь изменить (число): ', Integer) { |q| q.in = 0..$config.size }
      result.merge case entry
		   when 0 then set_marathon_changable
		   when 1 then set_williamhill_changable
		   when 2 then set_min_percent
		   when 3 then set_filtering
		   when 4 then set_sound_notification
		   when 5 then set_sport
		   when 6 then set_bookmakers
		   when 7 then set_log
		   when 8 then set_time_of_notification
		   when 9 then set_download_timeout
		   when 10 then set_phantomjs_logger
		   else all_fields
		   end
    end

    def all_fields
      config = {}
      config.merge! set_marathon_changable
      config.merge! set_williamhill_changable
      config.merge! set_min_percent
      config.merge! set_filtering
      config.merge! set_sound_notification
      config.merge! set_sport
      config.merge! set_bookmakers
      config.merge! set_log
      config.merge! set_time_of_notification
      config.merge! set_download_timeout
      config.merge! set_phantomjs_logger
      config
    end

    def translate(config_key)
      case config_key
      when :marathon_changable then 'адрес marathon'
      when :williamhill_changable then 'адрес williamhill'
      when :download_timeout then 'download timeout'
      when :min_percent then 'минимальный процент вилки'
      when :time_of_notification then 'время показа найденной вилки в секундах'
      when :filtering then 'показ только тех вилок, что можно поставить'
      when :sound_notification then 'звук сообщений'
      when :log then 'показ событий в терминале'
      when :phantomjs_logger then 'phantomjs logs'
      when :sport then 'виды спорта'
      when :bookmakers then 'список букмекеров'
      else config_key
      end
    end

    def set_marathon_changable
      address = ask("Впиши новый адрес формата https://www.mirrorofmarathon.com > ")
      { marathon_changable: address }
    end

    def set_williamhill_changable
      address = ask("Впиши новый адрес формата http://sports.mirrorofwilliamhill.com > ")
      { williamhill_changable: address }
    end

    def set_download_timeout
      timeout = ask("downloader timeout > ", Integer)
      { download_timeout: timeout }
    end

    def set_min_percent
      percent = ask("минимальный процент (число) > ", Float) do |q|
	q.in = Forker::Comparer::FAKE_PERCENT...Forker::Comparer::UNREAL_PERCENT
      end
      { min_percent: percent }
    end

    def set_time_of_notification
      time = ask("время показа вилки в секундах > ", Integer) { |q| q.in = 1..120 }
      { time_of_notification: time }
    end

    def set_filtering
      { filtering: true_or_false(ask("показывать вилки ТОЛЬКО в перерывах (y/N) > ")) }
    end

    def set_sound_notification
      { sound_notification: true_or_false(ask("включить звук (y/N) > ")) }
    end

    def set_log
      { log: true_or_false(ask("показывать в терминале, что происходит (y/N) > ")) }
    end

    def set_phantomjs_logger
      { phantomjs_logger: true_or_false(ask("показывать логи phantomjs (y/N) > ")) }
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
