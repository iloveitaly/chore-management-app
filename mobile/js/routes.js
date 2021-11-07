angular.module('app.routes', [

])

// https://github.com/angular-ui/ui-router
.config(function($stateProvider, $urlRouterProvider) {
  $stateProvider

  .state('login', {
    url: '/login',
    cache: false,
    templateUrl: 'templates/login.html',
    controller: 'loginCtrl'
  })

  .state('signup', {
    url: '/signup',
    cache: false,
    templateUrl: 'templates/login/signup.html',
    controller: 'signupCtrl'
  })

  .state('signin', {
    url: '/signin',
    cache: false,
    templateUrl: 'templates/login/signin.html',
    controller: 'signinCtrl'
  })

  // Onboarding

  .state('menu.onboardChildren', {
    url: '/onboard/children',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/onboarding/family.html',
        controller: 'childrenOnboardCtrl'
      }
    }
  })

  .state('menu.onboardChild', {
    url: '/onboard/child/:childId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/onboarding/child.html',
        controller: 'childOnboardCtrl'
      }
    }
  })

  .state('onboardComplete', {
    url: '/onboard/complete',
    cache: false,
    templateUrl: 'templates/onboarding/complete.html',
    controller: 'childOnboardCompleteCtrl'
  })

  // Children Management

  .state('menu.childenIndex', {
    url: '/children',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/children/index.html',
        controller: 'childrenIndexCtrl'
      }
    }
  })

  .state('menu.addChild', {
    url: '/children/create',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/children/create.html',
        controller: 'childrenCreateCtrl'
      }
    }
  })

  .state('menu.showChild', {
    url: '/children/:childId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/children/show.html',
        controller: 'childrenShowCtrl'
      }
    }
  })

  .state('menu.editChild', {
    url: '/children/:childId/edit',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/children/edit.html',
        controller: 'childrenEditCtrl'
      }
    }
  })

  // Accounts

  .state('menu.accountsList', {
    url: '/accounts',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/accounts/index.html',
        controller: 'accountsListCtrl'
      }
    }
  })

  .state('menu.addAccount', {
    url: '/accounts/create',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/accounts/create.html',
        controller: 'addAccountCtrl'
      }
    }
  })

  .state('menu.editAccount', {
    url: '/account/:accountId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/accounts/edit.html',
        controller: 'editAccountCtrl'
      }
    }
  })

  .state('menu.showAccount', {
    url: '/accounts/:accountId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/accounts/show.html',
        controller: 'showAccountCtrl'
      }
    }
  })

  // Transactions

  .state('menu.editTransaction', {
    url: '/transaction/:transactionId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/transactions/edit.html',
        controller: 'editTransactionCtrl'
      }
    }
  })

  .state('menu.addTransaction', {
    url: '/add-transaction/:accountId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/transactions/create.html',
        controller: 'addTransactionCtrl'
      }
    }
  })

  // Chores

  .state('menu.addChore', {
    url: '/chores/create',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/chores/create.html',
        controller: 'addChoreCtrl'
      }
    }
  })

  .state('menu.editChore', {
    url: '/chores/:choreId',
    params: {
      recurring: false
    },
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/chores/edit.html',
        controller: 'editChoreCtrl'
      }
    }
  })

  .state('menu.payChore', {
    url: '/chores/:choreId/pay',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/chores/pay.html',
        controller: 'payChoreCtrl'
      }
    }
  })

  .state('menu.choresList', {
    url: '/chores',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/chores/index.html',
        controller: 'listChoresCtrl'
      }
    }
  })

  .state('menu.settings', {
    url: '/settings',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/settings.html',
        controller: 'settingsCtrl'
      }
    }
  })

  .state('menu.familyDashboard', {
    url: '/family/dashboard',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/family/dashboard.html',
        controller: 'familyDashboardCtrl'
      }
    }
  })

  .state('menu', {
    url: '/menu',
    templateUrl: 'templates/menu.html',
    controller: 'menuCtrl',
    abstract: true,
    resolve: {
      // currencies: function(Currency) {
      //   return Currency.getCurrencies().$promise
      // }
      // auth: function($auth) {
      //   return $auth.validateUser();
      // }
    }
  })

  .state('childMenu', {
    // TODO better naming...
    url: '/cmenu',
    templateUrl: 'templates/child_menu.html',
    controller: 'childMenuCtrl',
    abstract: true
  })

  // Children (should be a separate app... maybe?)

  .state('childMenu.showChildAccounts', {
    url: '/child/:childId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/child-app/accounts/index.html',
        controller: 'showChildAccountsCtrl'
      }
    }
  })

  .state('childMenu.showChildAccountTransactions', {
    url: '/child/:childId/account/:accountId',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/children/transactions.html',
        controller: 'showChildAccountTransactionsCtrl'
      }
    }
  })

  .state('childMenu.childChoresList', {
    url: '/child/:childId/chores',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/child-app/chores/index.html',
        controller: 'listChildChoresCtrl'
      }
    }
  })

  .state('childMenu.childEnclaimedChoresList', {
    url: '/child/:childId/unclaimed-chores',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/child-app/chores/unclaimed.html',
        controller: 'listUnclaimedChoresCtrl'
      }
    }
  })

  .state('childMenu.childShowChore', {
    url: '/child/:childId/chores/:id',
    cache: false,
    views: {
      'menu': {
        templateUrl: 'templates/child-app/chores/show.html',
        controller: 'showChildChoreCtrl'
      }
    }
  })

  $urlRouterProvider.otherwise('/login')
});
