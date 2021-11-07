# NOTE we 'pre-configure' a child's login without knowing their
#      oauth uid. We need to customize the login process

module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    # https://github.com/lynndylanhurley/devise_token_auth/blob/10863b31270b31cec72a07e1a195aa21686ede2b/app/controllers/devise_token_auth/omniauth_callbacks_controller.rb#L79
    def assign_provider_attrs(user, auth_hash)
      super

      # NOTE only check for child association on first login
      if user.new_record?
        email = auth_hash['info']['email']
        if child = Child.find_by(email: email)
          user.child = child
        end
      end
    end
  end
end
