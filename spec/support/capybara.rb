Capybara::Angular.default_max_wait_time = 30
OmniAuth.config.test_mode = true

Capybara.register_driver :selenium_chrome_driver do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara::Webkit.configure do |config|
  # Enable debug mode. Prints a log of everything the driver is doing.
  # config.debug = true

  config.allow_unknown_urls

  config.skip_image_loading
end

RSpec.configure do |c|
  c.before(:each, type: :feature) do |example|
    if ENV["SELENIUM"] == "true"
      Capybara.current_driver = :selenium_chrome_driver
      Capybara.javascript_driver = :selenium_chrome_driver
    else
      default_capybara_driver = :selenium

      Capybara.current_driver = default_capybara_driver
      Capybara.javascript_driver = default_capybara_driver
      # page.driver.enable_logging
    end
  end

  c.after(:each, type: :feature) do |example|
    if example.exception
      browser = page.driver.browser.try(:browser)

      if browser == :chrome
        # puts page.driver.console_messages
        # puts page.driver.error_messages
      elsif browser == :firefox
        # http://stackoverflow.com/questions/8996267/is-there-a-way-to-print-javascript-console-errors-to-the-terminal-with-rspec-cap
         errors = page.driver.browser.manage.logs.get(:browser)

         if errors.present?
           puts errors.map(&:message).join("\n")
         end
      end
    end
  end

  # TODO move out of capybara config; should be general config
  # c.before(:each) do |s|
  #   # http://stackoverflow.com/questions/3816322/getting-the-full-rspec-test-name-from-within-a-beforeeach-block
  #   md = s.example.metadata
  #   x = md[:example_group]
  #
  #   puts "=> #{x[:file_path]}:#{x[:line_number]} #{md[:description_args]}"
  # end
end
