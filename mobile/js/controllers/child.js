'use strict';

angular.module('app.controllers.child', [
  'app.services'
])

.controller('listUnclaimedChoresCtrl', function($scope, $state, $stateParams, $ionicHistory, ChildChore) {
  $scope.chores = ChildChore.unclaimed({ childId: $stateParams.childId });
  $scope.childId = $stateParams.childId;

  $scope.doRefresh = function() {
    ChildChore.unclaimed({ childId: $stateParams.childId });
    $scope.$broadcast('scroll.refreshComplete');
  }

  $scope.claimChore = function(chore) {
    chore.$claim({ childId: $scope.childId, id: chore.id },
      function(child) {
        $scope.chores = ChildChore.unclaimed({ childId: $stateParams.childId });
      },

      function(response) {
        alert('Unexpected error');
      }
    )
  }
})

.controller('listChildChoresCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore, Child, ChildChore) {
  $scope.chores = ChildChore.query({ childId: $stateParams.childId });
  $scope.childId = $stateParams.childId;

  $scope.doRefresh = function() {
    ChildChore.query({ childId: $stateParams.childId });
    $scope.$broadcast('scroll.refreshComplete');
  }

  $scope.requestPayment = function(chore) {
    if(confirm("Did you complete this chore?")) {
      chore.$requestPayment({ childId: $scope.childId, id: chore.id },
        function(child) {
          $scope.chores = ChildChore.query({ childId: $stateParams.childId });
        },

        function(response) {
          alert('An unexpected error occured');
        }
      )
    }
  }
})

.controller('showChildChoreCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore, Child, ChildChore) {
  $scope.chore = ChildChore.get({ childId: $stateParams.childId, id: $stateParams.id });
})

.controller('childrenShowCtrl', function($scope, $state, $stateParams, $ionicHistory, Child) {
  $scope.child = Child.get({ id: $stateParams.childId })
})

.controller('childrenEditCtrl', function($scope, $state, $stateParams, $ionicHistory, Child) {
  $scope.child = Child.get({ id: $stateParams.childId });
  $scope.accountsForCurrency = {}
  $scope.split_earnings_schedule = {}

  $scope.child.$promise.then(function(child) {
    _.reduce(child.accounts, function(hash, account) {
      if(_.isEmpty(hash[account.currency_id])) {
        hash[account.currency_id] = []
      }

      hash[account.currency_id].push(account)

      return hash
    }, $scope.accountsForCurrency)
  })

  $scope.childViewUrl = "http://" + window.location.hostname + "/app/#/child/" + $stateParams.childId
  $scope.emailFrequencies = [
    ['weekly', 'Weekly'],
    ['monthly', 'Monthly']
  ]

  $scope.emailMonthDays = _.range(1, 30)
  $scope.emailWeekDays = [
    [1, 'Saturday'],
    [3, 'Sunday'],
    [4, 'Monday'],
    [5, 'Tuesday'],
    [6, 'Wednesday'],
    [7, 'Thursday'],
    [8, 'Friday']
  ]

  $scope.child.$promise.then(function(newChild) {
    if(newChild.email_frequency == 'weekly') {
      $scope.child.email_week_day = newChild.email_day
      $scope.child.email_month_day = 1
    } else {
      $scope.child.email_month_day = newChild.email_day
      $scope.child.email_week_day = 1
    }
  })

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.editChild = function() {
    // ensure totals equal 100%
    if($scope.child.split_earnings) {
      var splitEarningsAccounts = $scope.accountsForCurrency[$scope.child.default_currency_id];
      var scheduleSum = _.reduce(splitEarningsAccounts, function(sum, account) {
        return sum + account.split_percentage;
      }, 0.0)

      if(scheduleSum != 100) {
        alert('Split percentage must equal 100.')
        return
      }

      $scope.child.split_earnings_schedule = _.reduce(splitEarningsAccounts, function(schedule, account) {
        schedule.push({
          account_id: account.id,
          split_percentage: account.split_percentage
        })

        return schedule
      }, [])
    }

    Child.update($scope.child,
      function(child) {
        $state.go('menu.childenIndex');
      },

      function(response) {
        alert('Invalid child name or email.');
      }
    );
  }
})

;
