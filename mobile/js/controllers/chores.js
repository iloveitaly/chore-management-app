'use strict';

angular.module('app.controllers.chores', ['app.services'])

.controller('listChoresCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore) {
  $scope.chores = Chore.query();

  $scope.doRefresh = function() {
    $scope.chores = Chore.query();
    $scope.$broadcast('scroll.refreshComplete');
  }
})

.controller('editChoreCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore) {
  $scope.chore = Chore.get({ id: $stateParams.choreId });
  $scope.createdFromRecurringChore = $stateParams.recurring

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.editChore = function() {
    Chore.update($scope.chore,
      function(chore) {
        $state.go('menu.choresList')
      },

      function(response) {
        alert('Looks like you forgot a field!')
      }
    )
  }

  $scope.deleteChore = function() {
    if(!confirm("Are you sure you want to delete this chore? This action cannot be undone.")) {
      return;
    }

    Chore.delete({ id: $scope.chore.id }, function() {
      $state.go('menu.choresList')
    })
  }
})

.controller('addChoreCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore, Child) {
  $scope.children = Child.query();
  $scope.chore = new Chore();

  $scope.addChore = function() {
    $scope.chore.$save(
      function(chore) {
        $state.go('menu.choresList')
      },

      function(response) {
        alert('Required field is missing!')
      }
    )
  }
})

.controller('payChoreCtrl', function($scope, $state, $stateParams, $ionicHistory, Chore, Child) {
  $scope.chore = Chore.get({ id: $stateParams.choreId });
  $scope.child = new Child({});

  $ionicHistory.nextViewOptions({ disableBack: true });

  // TODO filter out the children who don't have accounts
  // $scope.childrenWithAccounts

  // grab the child's accounts when a new child is chosen from the assignment menu
  $scope.$watch('chore.child_id', function(newValue, oldValue) {
    if(newValue) {
      $scope.child = Child.get({ id: newValue });
    }
  });

  $scope.chore.$promise.then(function(chore) {
    $scope.child = Child.get({ id: chore.child_id });
  })

  $scope.pay = function() {
    $scope.chore.$pay(
      function(chore) {
        if(chore.new_chore_id === undefined) {
          $state.go('menu.choresList')
        } else {
          $state.go('menu.editChore', {
            choreId: chore.new_chore_id,
            recurring: true
          })
        }
      },

      function(response) {
        alert('Required field is missing!')
      }
    )
  }
})
