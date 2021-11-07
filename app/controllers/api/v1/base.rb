class Api::V1::Base < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  
  before_action :add_api_version

  protected

    def current_family
      current_user.family
    end

    # http://stackoverflow.com/questions/23056808/detect-application-version-change-on-a-single-page-application
    def add_api_version
      response.headers['X-Api-Version'] = ENV['HEROKU_RELEASE_VERSION']
    end
end
