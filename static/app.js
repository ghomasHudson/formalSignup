function getTag(tagString){
  return $(tagString)
}


//console.log(getTag("body"))

// app.js
angular.module('sortApp', ["ngSanitize"])

// Service
.factory('ajax', ['$http', function($http) {
  return {
    getUser: function() {
      return $http.get('/api/user/').success(function() {
      });
    }
}}])


// Controller
.controller('mainController', ['$scope', '$window', '$filter', 'ajax', function($scope, $window, $filter, serverComm) {
  
  $scope.user = {};
  
 
  
  //USER
  $scope.getUser = function() {
	  serverComm.getUser(userId).success(function(data) {
		  $scope.user = data;
      $scope.username = $scope.user.username;

		  console.log("User", $scope.user);
		  if ($scope.user.tableHeadings != "") {
		  	  $scope.tableHeadings = JSON.parse($scope.user.tableHeadings);
		  }
	  });
  }
  
  $scope.updateUser = function() {
    $scope.user.tableHeadings = JSON.stringify($scope.tableHeadings)
	  serverComm.updateUser($scope.user).success();
  }


  $scope.initModel = function() {
    console.log("loaded")
    $("#loader").fadeOut("slow");
    $scope.getUser();
  };
  $scope.initModel();
  
}])


//Directive for DOM manipulation - showing modals
.directive('displayModal', function() {
    
    return {
        restrict: 'A', // restricts the use of the directive (use it as an attribute)
        link: function(scope, elm, attrs) { // fires when the element is created and is linked to the scope of the parent controller
            if (scope.modelShow){
              elm.modal();
            }
        }
    };

    
})


function recurseApply(target, data) {
  var key, subDiff;
  for (key in data) {
    if (typeof target === "undefined") {
      target = {};
    }
    if ((typeof data[key]) === 'object' && data[key] !== null) {
      if (Object.keys(data[key]).length > 0) {
        subDiff = recurseApply(target[key], data[key]);
        target[key] = subDiff;
      }
    }
    else {
      target[key] = data[key];
    }
  }
  return target;
}