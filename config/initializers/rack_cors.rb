# for inioc: http://www.dovetaildigital.io/blog/2015/8/21/rails-and-ionic-make-love-part-one
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      methods: [:get, :post, :put, :delete, :options, :head],
      max_age: 0
  end
end
