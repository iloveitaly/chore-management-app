angular.module('app.controllers', ['app.services', 'ng-token-auth'])

.controller('childMenuCtrl', function($scope, $auth, $state, $stateParams, User, Account, Currency, Child, Family, $auth, ENV) {
  // NOTE $stateParams is empty at this point!
  $scope.child = Child.get({ id: $state.params.childId });

  // TODO child login does not hit the standard `failedAuthentication()` method because
  // of the read-only child structure. Need to refactor this in the future to leverage
  // the standard authentication stack

  $scope.signOut = function() {
    $auth.signOut()
      .then(function(resp) {
        $state.go('login')
      })
      .catch(function(resp) {
        $state.go('login')
      });
  }
})

.controller('menuCtrl', function($scope, User, Account, Currency, Child, Family, $auth, ENV) {
  $scope.accounts = User.getAccounts();
  $scope.currencies = Currency.getCurrencies();
  $scope.family = new Family({});
  $scope.appVersion = ENV.appVersion;
  $scope.children = Child.query();

  $scope.refreshChildrenList = function() {
    $scope.children = Child.query();
  }

  $auth.validateUser().then(function(data) {
    $scope.family = Family.get({ id: data.family_id })
  })

  $scope.signOut = function() {
    $auth.signOut()
      .then(function(resp) {
          // handle success response
      })
      .catch(function(resp) {
        // handle error response
      });
  }
})

.controller('settingsCtrl', function($scope, $auth, Family) {
  // NOTE the family will already be loaded by the menu contrller at this point
  // TODO we should refresh this URL when the family is updated
  $scope.familyViewUrl = "http://" + window.location.hostname + "/web/families/" + $scope.family.id

  // TODO I don't think this will end up updating the menu contrller's version of this
  //      we need to reach into the menu contrller's scope and ensure that this object
  //      is updated for everyone
  $auth.validateUser().then(function(data) {
    $scope.family = Family.get({ id: data.family_id })
  })
})

.controller('addAccountCtrl', function($scope, $state, $ionicHistory, User, Account, Child) {
  $scope.account = new Account();
  $scope.child = new Child();
  $scope.children = Child.query();

  // NOTE using ng-repeat on the `<option/>` level breaks some of the magic bindings
  //     add the 'create new' option via a post-AJAX promise to avoid breaking ng magic
  $scope.children.$promise.then(function() {
    $scope.children.unshift({
      id: 'create',
      name: '-- Create new child --'
    })
  })

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.addAccount = function() {
    if($scope.account.child_id !== 'create') {
      $scope.saveAccountAndRedirect()
    } else {
      $scope.child.$save(
        function(new_child) {
          $scope.children.push(new_child);
          $scope.account.child_id = new_child.id;

          $scope.saveAccountAndRedirect();
        },

        function() {
          alert('Make sure you have filled out a child name and email correctly.');
        }
      );
    }
  }

  $scope.saveAccountAndRedirect = function() {
    $scope.account.$save(
      function(account) {
        User.refreshAccounts()

        $state.go('menu.accountsList')
      },

      function(response) {
        alert('Invalid account name');
      }
    )
  }
})

.controller('editAccountCtrl', function($scope, $state, $stateParams, $ionicHistory, User, Account, Child) {
  // TODO remove and use menu controller instead
  $scope.children = Child.query()

  $scope.child = new Child();

  // TODO dup from add ctrl; DRY this up
  $scope.children.$promise.then(function() {
    $scope.children.unshift({
      id: 'create',
      name: '-- Create new child --'
    })
  })

  $scope.account = Account.get({ id: $stateParams.accountId }, function(response) {
    $scope.account.interest_rate_enabled = response.interest_rate && response.interest_rate > 0.0

    if($scope.account.interest_rate_enabled == true) {
      $scope.account.interest_rate /= 100.0 * 100.0
    }
  });

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.deleteAccount = function() {
    if(!confirm("Are you sure you want to delete this account? This action cannot be undone.")) {
      return;
    }

    Account.delete({ id: $scope.account.id }, function() {
      User.refreshAccounts()

      $state.go('menu.accountsList')
    })
  }

  $scope.editAccount = function() {
    if($scope.account.child_id !== 'create') {
      $scope.updateAccountAndRedirect()
    } else {
      $scope.child.$save(
        function(new_child) {
          $scope.children.push(new_child);
          $scope.account.child_id = new_child.id;

          $scope.updateAccountAndRedirect();
        },

        function() {
          alert('Make sure you have filled out a child name and email correctly.');
        }
      );
    }
  }

  $scope.updateAccountAndRedirect = function() {
    // TODO copying here to avoid the user seeing modifications to the model
    //      there has got to be a better approach here

    var account = angular.copy($scope.account);

    if(account.interest_rate_enabled === false) {
      account.interest_rate = 0.0
    } else {
      account.interest_rate = parseInt(account.interest_rate * 100 * 100)
    }

    Account.update(account,
      function(account) {
        User.refreshAccounts()

        $state.go('menu.showAccount', { accountId: $stateParams.accountId })
      },

      function(response) {
        alert('Looks like you missed something, check your settings and try again!')
      }
    )
  }

})

.controller('accountsListCtrl', function($scope, User, Account, Currency) {
  $scope.data = { showReorder: false };

  User.refreshAccounts();

  $scope.reorderItem = function(account, index, fromIndex, toIndex) {
    $scope.accounts.splice(fromIndex, 1);
    $scope.accounts.splice(toIndex, 0, account);

    Account.update({ id: account.id, position: toIndex }, function() {
      User.refreshAccounts()
    })
  };

  // TODO there has got to be a way to refresh the accounts resource
  $scope.doRefresh = function() {
    User.refreshAccounts()

    $scope.$broadcast('scroll.refreshComplete');
  }
})

.controller('showAccountCtrl', function($rootScope, $scope, $stateParams, Account, Currency, Transaction) {
  $scope.account = Account.get({ id: $stateParams.accountId })

  $scope.refreshTransactions = function() {
    // TODO we shouldn't need to worry about child_id vs childId
    $scope.transactions = Transaction.query({ account_id: $stateParams.accountId })
  }

  Currency.getCurrencies().$promise.then($scope.refreshTransactions)

  $scope.pullToRefresh = function() {
    $scope.refreshTransactions();
    $scope.$broadcast('scroll.refreshComplete');
  }
})

.controller('editTransactionCtrl', function($scope, $state, $stateParams, $q, $ionicHistory, $auth, Currency, User, Account, Transaction) {
  $scope.transaction = Transaction.get({ id: $stateParams.transactionId });

  $q.all([$scope.transaction.$promise, Currency.getCurrencies().$promise]).then(function() {
    if(!Currency.isZeroDecimalCurrency($scope.transaction.currency_id)) {
      $scope.transaction.amount = $scope.transaction.amount / 100.0
    }
  })

  $scope.editTransaction = function() {
    // TODO DRY this up into some helper method
    $scope.transaction.amount = Number(String($scope.transaction.amount).replace(/[^0-9\.]+/g, ""));

    Transaction.update($scope.transaction,
      function(transaction) {
          $state.transitionTo('menu.showAccount', { accountId: $scope.transaction.account_id }, {})

          $ionicHistory.nextViewOptions({
            disableBack: true
          });
        },
        function(response) {
          alert('Make sure you have a description and amount entered')
        }
    )
  }
})

.controller('addTransactionCtrl', function($scope, $state, $stateParams, $ionicHistory, $auth, User, Account, Transaction) {
  $scope.accounts = User.getAccounts();
  $scope.account = Account.get({ id: $stateParams.accountId });
  $scope.transaction = new Transaction({ accountId: $stateParams.accountId });
  $scope.type = 'income'

  $scope.otherAccounts = []

  User.refreshAccounts().$promise.then(function(accounts) {
    $scope.otherAccounts = _.filter(accounts, function(account) { return account.id != $stateParams.accountId })
  })

  $auth.validateUser().then(function(data) {
    $scope.transaction.payor = data.name
  });

  $scope.account.$promise.then(function(account) {
    $scope.transaction.split_income = account.split_income
  })

  $scope.setType = function(type) {
    $scope.type = type
  }

  $scope.addTransaction = function() {
    var transaction = angular.copy($scope.transaction)

    // TODO not sure why we are not setting the type on the transfer object itself
    transaction.type = $scope.type

    // TODO handle this on a input mask rather than pre-submit
    // http://stackoverflow.com/questions/559112/how-to-convert-a-currency-string-to-a-double-with-jquery-or-javascript

    var parsed_amount = Number(String(transaction.amount).replace(/[^0-9\.-]+/g, ""));

    // TODO https://github.com/iloveitaly/family-currency/issues/39
    if(parsed_amount < 0) {
      alert('You must specify a positive amount.')
      return;
    }

    transaction.amount = parsed_amount;

    // TODO handle zero decimal > int conversion

    if($scope.type == 'expense') {
      transaction.amount *= -1
    }

    transaction.$save({ account_id: $stateParams.accountId })
      .then(
        function(transaction) {
          $state.transitionTo('menu.showAccount', { accountId: $stateParams.accountId }, {})

          $ionicHistory.nextViewOptions({
            disableBack: true
          });
        },
        function(response) {
          alert('Make sure you have a description and amount entered.' + ($scope.type == 'transfer' ? ' Make sure the destination bank has the same currency as the current account.' : ''))
        }
    )

  }
})

.controller('childrenCreateCtrl', function($scope, $state, $ionicHistory, Child) {
  $scope.child = new Child({ email_enabled: true });

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.addChild = function() {
    $scope.child.$save(
      function(child) {

        $state.go('menu.childenIndex')
      },

      function(response) {
        alert('Invalid child name or email.')
      }
    )
  }
})

.controller('childrenIndexCtrl', function($scope, $state, $stateParams, User, Account, Child, Currency) {
  // this bubbles up to the menu controller, ensuring that the children list
  // is globally refreshed when a new child is added

  $scope.refreshChildrenList();
})

.controller('familyDashboardCtrl', function($ionicHistory) {
  $ionicHistory.nextViewOptions({ disableBack: true });
})

// TODO this should be moved to a separate JS file
.controller('showChildAccountsCtrl', function($scope, $state, $stateParams, User, Account, Child, Currency) {
  $scope.child = Child.get({ id: $stateParams.childId })
  $scope.currencies = Currency.getCurrencies();

  $scope.doRefresh = function() {
    $scope.child = Child.get({ id: $stateParams.childId })
    
    $scope.$broadcast('scroll.refreshComplete');
  }
})

.controller('showChildAccountTransactionsCtrl', function($scope, $state, $stateParams, User, Account, Child, Transaction, Currency) {
  // TODO set back button https://github.com/driftyco/ionic/issues/1647

  $scope.account = Account.get({ id: $stateParams.accountId })

  $scope.refreshTransactions = function() {
    // TODO we shouldn't need to worry about child_id vs childId
    $scope.transactions = Transaction.query({ account_id: $stateParams.accountId })
  }

  Currency.getCurrencies().$promise.then($scope.refreshTransactions)

  $scope.pullToRefresh = function() {
    $scope.refreshTransactions();
    $scope.$broadcast('scroll.refreshComplete');
  }
})
