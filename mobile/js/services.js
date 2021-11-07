'use strict';

angular.module('app.services', [
  'app.config',
  'ngResource'
])

.factory('Currency', function($resource, $locale, $filter, $sce, ENV) {
  var currencies;
  var resource = $resource(ENV.apiEndpoint + 'currencies');

  var currencyService = {
    isZeroDecimalCurrency: function(currencyId) {
      var currency = _.find(this.getCurrencies(), { id: currencyId });
      return currency.zeroDecimal
    },

    getCurrencies: function() {
      if(!currencies) {
        currencies = resource.query()
      }

      return currencies;
    },

    format: function(amount, currencyId) {
      if(!this.getCurrencies().$resolved) {
        return "Loading..."
      }

      var formats = $locale.NUMBER_FORMATS;
      var currency = _.find(this.getCurrencies(), { id: currencyId })

      var fractionSize = currency.zeroDecimal ? 0 : 2;

      if(fractionSize > 0) {
        amount /= 100
      }

      return $sce.trustAsHtml(
        (amount < 0 ? '-' : '') +
        (currency.icon.startsWith('ion-') ? "<i class='" + currency.icon + "'></i> " : currency.icon) +
        $filter('currency')(amount, '', fractionSize)
      );
    }
  }

  return currencyService;
})

.factory('Account', function ($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'accounts/:id', { id: '@id' },
    { 'get':    {method:'GET'},
      'save':   {method:'POST'},
      'update': {method:'PUT'},
      'query':  {method:'GET', isArray:true},
      'remove': {method:'DELETE'},
      'delete': {method:'DELETE'}
  });
})

.factory('User', function(Account, $auth) {
  var accounts;
  var name;

  var user = {
    getName: function() {
      return name;
    },

    setUser: function(data) {
      this.name = data.name
    },

    getAccounts: function() {
      if(!accounts) {
        accounts = this.refreshAccounts()
      }

      return accounts;
    },

    refreshAccounts: function() {
      return Account.query(function(data) {
        angular.copy(data, accounts)
      })
    }
  }

  return user;
})

.factory('Family', function ($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'families/:id', { id: '@id' },
    { 'get':    {method:'GET'},
      'save':   {method:'POST'},
      'setup':  {
        url: ENV.apiEndpoint + 'families/setup',
        method: 'POST'
      },
      'update': {method:'PUT'},
      'query':  {method:'GET', isArray:true},
      'remove': {method:'DELETE'},
      'delete': {method:'DELETE'} }
  );
})

// TODO this is a hack around bad nested resource support. Consider restangular instead.
.factory('ChildChore', function ($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'children/:childId/chores/:id', {},
    { 'get':    {method:'GET'},
      'save':   {method:'POST'},
      'update': {method:'PUT'},
      'query':  {method:'GET', isArray:true},
      'unclaimed': {
        method: 'GET',
        isArray: true,
        url: ENV.apiEndpoint + 'children/:childId/unclaimed-chores'
      },
      'claim': {
        url: ENV.apiEndpoint + 'children/:childId/chores/:id/claim',
        method: 'POST'
      },
      'requestPayment': {
        url: ENV.apiEndpoint + 'children/:childId/chores/:id/request-payment',
        method: 'POST'
      },
      'remove': {method:'DELETE'},
      'delete': {method:'DELETE'}
  });
})

.factory('Chore', function ($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'chores/:id', { id: '@id'},
  { 'get':    {method:'GET'},
    'save':   {method:'POST'},
    'pay':  {
      url: ENV.apiEndpoint + 'chores/:id/pay',
      method: 'POST'
    },
    'update': {method:'PUT'},
    'query':  {method:'GET', isArray:true},
    'remove': {method:'DELETE'},
    'delete': {method:'DELETE'} }
  )
})

.factory('Child', function ($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'children/:id', { id: '@id' },
    { 'get':    {method:'GET'},
      'save':   {method:'POST'},
      'setup':  {
        url: ENV.apiEndpoint + 'children/:id/setup',
        method: 'POST'
      },
      'update': {method:'PUT'},
      'query':  {method:'GET', isArray:true},
      'remove': {method:'DELETE'},
      'delete': {method:'DELETE'}
  });
})

.factory('Transaction', function($resource, ENV) {
  return $resource(ENV.apiEndpoint + 'transactions/:id', { id: '@id' },
    { 'get':    {method:'GET'},
      'save':   {method:'POST'},
      'update': {method:'PUT'},
      'query':  {method:'GET', isArray:true},
      'remove': {method:'DELETE'},
      'delete': {method:'DELETE'}
  });
})

.factory('ReloadInterceptor', function($rootScope, ENV) {
  return {
    response: function(res) {
      // http://stackoverflow.com/questions/25579938/location-path-not-working-from-http-interceptor/
      var apiAppVersion = res.headers('X-Api-Version');
      if(!_.isEmpty(apiAppVersion) && apiAppVersion != ENV.appVersion) {
        $rootScope.$emit('newAppVersion')
      }

      return res;
    }
  }
})

;
