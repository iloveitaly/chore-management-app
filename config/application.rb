require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# https://github.com/evrone/quiet_assets/issues/47
class RackWithQuietAssets
  def initialize(app)
    @app = app

    quiet_assets_paths = [ %r[\A/{0,2}#{Rails.application.config.assets.prefix}] ]
    @assets_regex = /\A(#{quiet_assets_paths.join('|')})/
  end

  def call(env)
    if env['PATH_INFO'] =~ @assets_regex
      Rails.logger.silence do
        @app.call(env)
      end
    else
      @app.call(env)
    end
  end
end

module Web
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.middleware.use RackWithQuietAssets
    # config.middleware.insert_after ActionDispatch::Static, RackWithQuietAssets
  end
end
