require 'betforker'

module MyHelpers

  HTML_PATH = File.expand_path('../support/html', __FILE__)

  def open_right_live_page(bookmaker)
    open("#{HTML_PATH}/#{bookmaker}/live_page.html").read
  end

  def open_event_page(bookmaker, file_name)
    open("#{HTML_PATH}/#{bookmaker}/#{file_name}").read
  end

  def marathon_live_page_without_events
    html = open_right_live_page 'marathon'
    nok = Nokogiri::HTML html
    nok.css('tbody').remove
    nok.to_html
  end

  def williamhill_live_page_without_events
    html = open_right_live_page 'williamhill'
    nok = Nokogiri::HTML html
    nok.css('#sports_holder').remove
    nok.to_html
  end

  def fake_event_webpage
    open_event_page('fake', 'fake.html')
  end

  def unstructured_events
    {
      "#{Betforker::MARATHON_BASE}1" => 'FirstSecond',
      "#{Betforker::WILLIAMHILL_BASE}1" => 'FirstSecond',
      'pm_second_addr' => 'FirstSecond',
      'br_first_addr' => 'FirstSecond',
      "#{Betforker::MARATHON_BASE}2" => 'ThirdFourth',
      "#{Betforker::WILLIAMHILL_BASE}2" => 'ThirdFourth',
      'br_second_addr' => 'ThirdFourth',
      "#{Betforker::MARATHON_BASE}3" => 'FifthSixth',
      'pm_first_addr' => 'FifthSixth',
      'br_third_addr' => 'FifthSixth',
      "#{Betforker::WILLIAMHILL_BASE}3" => 'NoSuchPlayers',
      "#{Betforker::WILLIAMHILL_BASE}4" => 'NoMoreSuchPlayers'
      }
  end

  def structured_events
    {
      'FirstSecond' => ["#{Betforker::MARATHON_BASE}1",
			"#{Betforker::WILLIAMHILL_BASE}1",
			'pm_second_addr',
			'br_first_addr'],
      'ThirdFourth' => ["#{Betforker::MARATHON_BASE}2",
			"#{Betforker::WILLIAMHILL_BASE}2",
			'br_second_addr'],
      'FifthSixth' => ["#{Betforker::MARATHON_BASE}3",
		       'pm_first_addr',
		       'br_third_addr']
      }
  end

  def page_from_provider
    <<-EOF
    <!doctype html>
    <html><body>
    <p> minjust.ru is blocking you </p>
    <p> eais and gov.ru too </p>
    </body></html>
    EOF
  end

  def updated_event(event)
    event.parsed_webpages << Betforker::ParsedPage.new
  end

  def parsed_marathon
    parsed = ParsedPage.new bookie: 'Marathon'
    parsed.score = '0:0 (3:2)'
    parsed.home_player = {
      name: 'HomePlayer',
      match: 1.5,
      game: { '6' => 1.5,
       '7' => 2.5 },
       set: { '1' => 1.5,
       '2' => 1.5 } }
    parsed.away_player = {
      name: 'AwayPlayer',
      match: 2.5,
      game: { '6' => 2.5,
       '7' => 1.5 },
       set: { '1' => 2.5,
       '2' => 2.5 } }
    parsed
  end

  def parsed_williamhill
    parsed = ParsedPage.new bookie: 'WilliamHill'
    parsed.home_player = {
      name: 'HomePlayer',
      match: 1.2,
      game: { '6' => 1.2,
       '7' => 4.0 },
       set: { '1' => 1.2,
       '2' => 1.2 } }
    parsed.away_player = {
      name: 'AwayPlayer',
      match: 4.0,
      game: { '6' => 4.0,
       '7' => 1.2 },
       set: { '1' => 4.0,
       '2' => 4.0 } }
    parsed
  end

end

RSpec.configure do |config|
  config.include MyHelpers
  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
