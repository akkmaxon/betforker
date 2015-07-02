class Downloader

  def initialize
    @macro_head = <<-EOF
SET !ERRORIGNORE YES
SET !TIMEOUT_PAGE 30
FILTER TYPE=IMAGES STATUS=ON
TAB T=1
    EOF
    @to_task = <<-EOF
SET !ERRORIGNORE YES
URL GOTO=imacros://run/?m=task.iim
    EOF
    @to_waiter = <<-EOF
SET !ERRORIGNORE YES
WAIT SECONDS=1
URL GOTO=imacros://run/?m=waiter.iim
    EOF
  end

  def download address
    addr = address.gsub('%2d', '<SP>')
    pause = 10 if addr.include?('williamhill')
    pause ||= 4
    flag = Time.now.to_i
    macro = <<-EOF
#{@macro_head}
TAB CLOSEALLOTHERS
URL GOTO=#{addr}
WAIT SECONDS=#{pause}
SAVEAS TYPE=HTM FOLDER=* FILE=RESPONSE#{flag}.htm
URL GOTO=imacros://run/?m=waiter.iim
    EOF
    iim_dumper(macro)
    page_load(flag)
  end

  def iim_dumper macro
    File.open($config[:task], 'w') {|f| f.write(macro) }
    File.open($config[:waiter], 'w') {|f| f.write(@to_task) }
    sleep(3)
    File.open($config[:waiter], 'w') {|f| f.write(@to_waiter) }
  end

  def page_load flag
    not_ready_yet = true
    file = "#{$config[:macros_folder]}RESPONSE#{flag}.htm"
    while not_ready_yet
      sleep(2)
      next unless File.exists?(file)
      page = open(file).read
      break
    end
    page
  end

end
