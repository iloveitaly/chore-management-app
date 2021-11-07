'use strict';

angular.module('app.controllers.onboarding', [
  'app.services'
])

.controller('childrenOnboardCtrl', function($scope, $state, $stateParams, $ionicHistory, $auth, Child, Family) {
  $scope.familyName = "";

  // TODO this should be handled app-wide in the menu contrller
  $auth.validateUser().then(function(data) {
    $scope.family = Family.get({ id: data.family_id })
    $scope.family.$promise.then(function(family) {
      $scope.familyName = family.name
    })
  })

  $scope.children = [
    new Child(),
    new Child(),
    new Child()
  ]

  $scope.addChild = function() {
    $scope.children.push(new Child())
  }

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.addChildren = function() {
    var setupParams = {
      family: { children: $scope.children },
      name: $scope.familyName
    };

    Family.setup(setupParams,
      function(response) {
        $state.go('menu.onboardChild', { childId: response.setup_child })
      },
      function(response) {
        alert('There was an error creating your children')
      })
  }
})

.controller('childOnboardCompleteCtrl', function($scope, $state, $stateParams, $ionicHistory, Child, Account) {
  $scope.data = {};
  $scope.nextSlide = function() {
    $scope.data.slider.slideNext();
  }
})

.controller('childOnboardCtrl', function($scope, $state, $stateParams, $ionicHistory, Child, Account) {
  $scope.child = Child.get({ id: $stateParams.childId })
  $scope.setup = {
    id: $stateParams.childId
  }

  $ionicHistory.nextViewOptions({ disableBack: true });

  $scope.setupChild = function() {
    Child.setup($scope.setup,
      function(response) {
        if(response.next_child === null) {
          // at this point, they've went through the children onboarding process
          // refresh so the side menu is properly setup
          $scope.refreshChildrenList();

          $state.go('onboardComplete')
        } else {
          $state.go('menu.onboardChild', { childId: response.next_child })
        }
      },
      function(response) {
        alert('Error setting up this child')
      })
  }
})
