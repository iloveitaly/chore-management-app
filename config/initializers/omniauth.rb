Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV["GOOGLE_OAUTH_CLIENT"],
    ENV["GOOGLE_OAUTH_SECRET"],
    prompt: 'select_account'
end

OmniAuth.config.logger = Rails.logger
