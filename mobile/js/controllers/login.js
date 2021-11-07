angular.module('app.login', [
  'app.services',
  'ng-token-auth']
)

.controller('signinCtrl', function($scope, $controller, $auth, $state, $ionicHistory, $window, Account, $location) {
  $controller('loginCtrl', { $scope: $scope });

  $scope.registration = {}

  $scope.signinWithEmail = function() {
    $auth.submitLogin($scope.registration)
      .then(function(user) {
        $scope.onboard(user)
      })
      .catch(function() {
        alert('You have entered invalid login information.')
      })
  }
})

.controller('signupCtrl', function($scope, $rootScope, $auth, $state, $controller, $ionicHistory, $window, Account, $location) {
  $controller('loginCtrl', { $scope: $scope });

  $scope.registration = {}

  $scope.signupWithEmail = function() {
    $scope.registration.password_confirmation = $scope.registration.password

    $auth.submitRegistration($scope.registration)
      .then(function() {
        $state.go('menu.onboardChildren')
      })
      .catch(function() {
        alert('There was an error submitting your registration.')
      })
  }
})

.controller('loginCtrl', function($scope, $rootScope, $auth, $state, $ionicHistory, $window, Account, $location) {

  $ionicHistory.nextViewOptions({ disableBack: true });

  $rootScope.$on('auth:validation-success', function(env, user) {
    // TODO https://github.com/lynndylanhurley/ng-token-auth/issues/104
    //      major hack to get around login issue. This did not occur with `9dba6cc`
    if(user.uid !== undefined) {
      $scope.onboard(user);
    }
  })

  $scope.$on('auth:login-success', function(env, user) {
    // $scope.onboard();
  })

  $scope.googleSignIn = function() {
    $auth.authenticate('google')
      .catch(function(response) {
        Rollbar.error("error on google oauth")
      })
  };

  $scope.onboard = function(user) {
    if(user.child_id != null) {
      // TODO this is a bit of a hack: they could go to any other URL, but for now
      //      we are just hiding the other URLs from them. We should add real authentication
      //      on the backend APIs and reroute them on the ui-router level based on a clear role definition

      $state.go('childMenu.showChildAccounts', { childId: user.child_id })
    } else {
      Account.query(function(response) {
        if(response.length > 0) {
          $state.go('menu.familyDashboard', { inherit: false })
        } else {
          $state.go('menu.onboardChildren', { inherit: false })
        }
      })
    }
  }
})
