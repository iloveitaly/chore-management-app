require 'database_cleaner'

RSpec.configure do |c|
  c.add_setting(:seed_tables)
  c.seed_tables =  %w(
    currencies
  )

  # clean before test suite in case cruft was left over from a dirty test execution
  c.before(:suite) do
    DatabaseCleaner.clean_with(:truncation,
      reset_ids: true,
      except: c.seed_tables
    )
  end

  # https://github.com/mattheworiordan/capybara-screenshot/blob/4b4a3aa7891208b5955e799f440de3b0d71d02ae/lib/capybara-screenshot/rspec.rb#L77-L82
  c.before(:each) do |example|
    DatabaseCleaner.strategy = :transaction

    # use transaction unless javascript enabled tests
    unless example.metadata[:type] == :feature
      DatabaseCleaner.start
    end
  end

  c.after(:each) do |example|
    unless example.metadata[:type] == :feature
      DatabaseCleaner.clean
    end

    DatabaseCleaner.clean_with(:truncation, except: c.seed_tables )
  end
end
