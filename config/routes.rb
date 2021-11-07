Rails.application.routes.draw do
  root to: redirect('/app/')

  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    omniauth_callbacks: 'overrides/omniauth_callbacks'
  }

  namespace :web do
    resources :families
  end

  namespace :api, :defaults => { :format => :json } do
    namespace :v1 do
      resources :chores do
        post 'pay' => 'chores#pay'
      end

      resources :currencies
      resources :families do
        post 'setup' => 'families#setup', on: :collection
      end

      resources :children do
        post 'setup' => 'children#setup'
        get 'unclaimed-chores' => 'child_chores#unclaimed'
        resources :chores, controller: 'child_chores' do
          post 'claim' => 'child_chores#claim'
          post 'request-payment' => 'child_chores#request_payment'
        end
      end

      resources :accounts
      resources :transactions
    end
  end
end
