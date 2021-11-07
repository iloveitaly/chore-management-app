// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
angular.module('app', [
  'angular-google-analytics',
  'ngIntercom',
  'ionic',
  'ordinal',
  'ui.utils.masks',
  'app.config',
  'app.controllers',
  'app.controllers.child',
  'app.controllers.onboarding',
  'app.controllers.chores',
  'app.routes',
  'app.services',
  'app.directives',
  'app.login'
])

.run(function($ionicPlatform, $rootScope, $auth, $state, $intercom, User, Account, Currency, ENV, Analytics) {
  $ionicPlatform.ready(function() {
    // https://forum.ionicframework.com/t/select-dropdown-issue-on-ios/5573/3
    if(window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false);
    }

    // TODO use white status bar
    if(window.StatusBar) {
      // org.apache.cordova.statusbar required
      // StatusBar.styleDefault();
    }
  });

  $auth.validateUser().then(function(user) {
    $intercom.boot(user);

    Rollbar.configure({
      payload: {
        person: {
          // username: "foo",
          id: user.id,
          email: user.email
        }
      }
    });

  });

  $rootScope.$on('newAppVersion', function() {
    window.location.reload();
  })

  $rootScope.formatCurrency = function(amount, account) {
    if(account.$resolved === false) {
      return "Loading..."
    }

    return Currency.format(amount, account.currency_id)
  }

  var failedAuthentication = function(env, user) {
    // TODO this is a major hack: if the state is empty, it hasn't been set by the
    //      routing librar yet. There isn't an easy way to wait on the resolution
    //      so, when we run into this race condition we just avoid making a decision

    if(_.isEmpty($state.current.name)) {
      return null;
    }

    // TODO somehow this should be handled via the UI router
    if(!$state.includes('childMenu') && !$state.is('signup') && !$state.is('signin')) {
      $state.go('login')
    }
  }

  // TODO we should use some sort of app-wide promise instead of throwing user auth logic in various places
  $rootScope.$on('auth:validation-success', function(env, user) {
    User.setUser(user);

    Analytics.set('&uid', user.id);
  })

  // TODO auth:invalid is not being thrown correctly here

  $rootScope.$on('auth:validation-error', failedAuthentication)
  $rootScope.$on('auth:invalid', failedAuthentication)
  $rootScope.$on('auth:session-expired', failedAuthentication)

  $rootScope.$on('auth:login-success', function(env, user) {
    // alert('eh')
  })

})

.config(function($authProvider, $provide, $ionicConfigProvider, $intercomProvider, $httpProvider, AnalyticsProvider, ENV) {
  if(ENV.environment == "production") {
    AnalyticsProvider.setAccount(ENV.googleAnalyticsID);
    AnalyticsProvider.setPageEvent('$stateChangeSuccess');
    // AnalyticsProvider.enterDebugMode(true);

    $intercomProvider.appID(ENV.intercomAppID);
    $intercomProvider.asyncLoading(true);
  }

  // TODO the interceptor was messing with the authentication interceptor
  //      search ng-token-auth for relative issues
  $httpProvider.interceptors.push('ReloadInterceptor');

  $ionicConfigProvider.
    backButton.
    text('').
    icon('ion-chevron-left');

  $ionicConfigProvider.scrolling.jsScrolling(true)

  // http://stackoverflow.com/questions/17441254/why-angularjs-currency-filter-formats-negative-numbers-with-parenthesis/30122327#30122327
  $provide.decorator('$locale', ['$delegate', function($delegate) {
     if($delegate.id == 'en-us') {
       $delegate.NUMBER_FORMATS.PATTERNS[1].negPre = '';
       $delegate.NUMBER_FORMATS.PATTERNS[1].negSuf = '';
     }
     return $delegate;
   }]);

  //  https://github.com/angular/angular.js/issues/9807#issuecomment-198619687

  var isMobile = window.cordova !== undefined;

  // https://github.com/lynndylanhurley/ng-token-auth/issues/90
  $authProvider.configure({
    apiUrl: '',

    validateOnPageLoad: true,
    forceValidateToken: true,
    // forceHardRedirect: true,

    emailRegistrationPath: "/auth",
    emailSignInPath:       "/auth/sign_in",

    authProviderPaths: {
      google: '/auth/google_oauth2'
    },

    // confirmationSuccessUrl: window.location.href,
    // tokenFormat: {
    //   "access-token": "{{ token }}",
    //   "token-type": "Bearer",
    //   "client": "{{ clientId }}",
    //   "expiry": "{{ expiry }}",
    //   "uid": "{{ uid }}"
    // },

    // omniauthWindowType: isMobile ? 'inAppBrowser' : 'newWindow',
    // storage: 'sessionStorage'
    storage: 'localStorage'
  });
})

// http://stackoverflow.com/questions/14512583/how-to-generate-url-encoded-anchor-links-with-angularjs
.filter('escape', function() {
    return function(input) {
      if(input) {
        return window.encodeURIComponent(input);
      }

      return "";
    }
});

;
