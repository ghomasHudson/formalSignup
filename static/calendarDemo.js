/**
 * calendarDemoApp - 0.9.0
 */
var calendarDemoApp = angular.module('calendarDemoApp', ['ui.calendar', 'ui.bootstrap','ui.bootstrap.modal']);



// Service
calendarDemoApp.factory('ajax', ['$http', function($http) {
  return {
    getUser: function(id) {
      return $http.get('/api/user/'+id).success(function() {
      })
    },
    saveUser: function(id,data) {
      data._method = 'patch';
      return $http.post('/api/user/'+id,data).success(function() {
      })
    },
    getSignups: function() {
      return $http.get('/api/signup/').success(function() {
      })
    },
    newSignup: function(data) {
      return $http.post('/api/signup/',data).success(function() {
      })
    },
    updateSignup: function(id,data) {
      data._method = 'patch';
      return $http.post('/api/signup/'+id,data).success(function() {
      })
    },
    deleteSignup: function(id) {
      return $http.delete('/api/signup/'+id).success(function() {
      })
    }
}}]);


calendarDemoApp.controller('MainCtrl',['$scope','$compile', '$timeout', '$window', 'uiCalendarConfig','ajax', function($scope, $compile, $timeout,$window, uiCalendarConfig,serverComm) {
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();
    $scope.user = {};
    $scope.newEvent = {}
    $scope.currentlyEditingID = null;

    /* event source that contains custom events on the scope */
    $scope.events = [];


    //USER
  $scope.getUser = function() {
    serverComm.getUser(userId).success(function(data) {
    $scope.user = data;
    console.log("User", $scope.user[0]);
    $('#colPicker').colorpicker({"format":"hex"});
    $('#colPicker').colorpicker('setValue',$scope.user.color);

    });
  };

  $scope.saveUser = function() {
    serverComm.saveUser(userId,$scope.user).success(function(data) {
    });
  };

  $scope.getSignups = function() {
    serverComm.getSignups().success(function(data) {
    $scope.signups = data;
    console.log("Signups", $scope.signups);
    $scope.signupsToEvents();
    });
  };

  $scope.signupsToEvents = function(){
    for (i = 0; i < $scope.signups.length; i++) { 
      signup = $scope.signups[i];
      if (signup.user == null){
        //Remove events from deleted users
        break;
      }
      newTitle = signup.user.displayName;
      guest = signup.guest
      console.log(guest)
      if (guest == true){
        newTitle += ' + Guest';
      }
      $scope.events.push({
        "id":signup._id,
        "title":newTitle,
        "color":signup.user.color,
        "userID": signup.user._id,
        "guest":guest,
        "start":signup.date,
        allDay:true
      })
      
    }
    console.log($scope.events)
    $("#loader").fadeOut("slow");
  }

  function getEventWithId(id){
    for (i = 0; i < $scope.events.length; i++) { 
      e = $scope.events[i];
      if (e.id == id){
        return e
      }
    }
    return null;
  }



    /* alert on eventClick */
    $scope.alertOnEventClick = function( date, jsEvent, view){
        $scope.currentlyEditingID = date.id
        currentEvent = getEventWithId($scope.currentlyEditingID);
        console.log(currentEvent.userID)
        if (currentEvent.userID == $scope.user._id){
          //Only allow user to edit their own events - also enforce on server
          $scope.signupModal = true;
          ukDate = new Date(currentEvent.start)
          ukDate = ukDate.toLocaleDateString('en-GB')
          $scope.newEvent = {date:ukDate,guest:currentEvent.guest}
        }


    };
    $scope.signupClose = function(){
        $scope.signupModal = false;
        $scope.currentlyEditingID = null;
        $scope.newEvent = {};
    };
    $scope.signupDelete = function(){
        $scope.signupModal = false;
        for (i = 0; i < $scope.events.length; i++) { 
          e = $scope.events[i];
          if (e.id == $scope.currentlyEditingID){
            $scope.events.splice(i,1);
            serverComm.deleteSignup($scope.currentlyEditingID);
            $scope.currentlyEditingID = null;
            $scope.newEvent = {};
        } 
    }
    };

    $scope.signupSave = function() {
      $scope.signupModal = false;
      newTitle = $scope.user.displayName;
      guest = false;
      if ($scope.newEvent.guest){
        newTitle += ' + Guest';
        guest = true
      }

      date = new Date($scope.newEvent.date.split("/")[2],$scope.newEvent.date.split("/")[1]-1,$scope.newEvent.date.split("/")[0])
      newEventdata = {
        "date":date,
        "user":$scope.user._id,
        "guest":guest
      }

      serverComm.updateSignup($scope.currentlyEditingID,newEventdata).success(function(data) {
        
        for (i = 0; i < $scope.events.length; i++) { 
          e = $scope.events[i];
          if (e.id == $scope.currentlyEditingID){
            $scope.events[i] = {
              id:data._id,
              guest: guest,
              userID: $scope.user._id,
              title: newTitle,
              start: date,
              allDay: true,
              className: ['newEvent',$scope.user.color],
              color: $scope.user.color
              }
            $scope.currentlyEditingID = null;
            $scope.newEvent = {};
        } 
      }
    });

    };
    
    $scope.addEvent = function() {
      newTitle = $scope.user.displayName;
      guest = false;
      if ($scope.newEvent.guest){
        newTitle += ' + Guest';
        guest = true
      }

      date = new Date($scope.newEvent.date.split("/")[2],$scope.newEvent.date.split("/")[1]-1,$scope.newEvent.date.split("/")[0])
      newEventdata = {
        "date":date,
        "user":$scope.user._id,
        "guest":guest
      }

      serverComm.newSignup(newEventdata).success(function(data) {
        $scope.events.push({
        id:data._id,
        guest: guest,
        userID: $scope.user._id,
        title: newTitle,
        start: date,
        allDay: true,
        className: ['newEvent',$scope.user.color],
        color: $scope.user.color
      });
        $scope.newEvent = {};
      });
    };
    /* Change View */
    $scope.changeView = function(view,calendar) {
      uiCalendarConfig.calendars[calendar].fullCalendar('changeView',view);
    };
    /* Change View */
    $scope.renderCalender = function(calendar) {
      $timeout(function() {
        if(uiCalendarConfig.calendars[calendar]){
          uiCalendarConfig.calendars[calendar].fullCalendar('render');
        }
      });
    };
     /* Render Tooltip */
    $scope.eventRender = function( event, element, view ) {
        element.attr({'tooltip': event.title,
                      'tooltip-append-to-body': true});
        $compile(element)($scope);
    };
    /* config object */
    $scope.uiConfig = {
      calendar:{
        height: 450,
        header:{
          left: '',
          center: 'title',
          right: 'today prev,next'
        },
        businessHours: {dow: [ 2,4 ]},
        eventClick: $scope.alertOnEventClick,
        durationEditable: false,
        eventRender: $scope.eventRender
      }
    };
    /* event sources array*/
    $scope.eventSources = [$scope.events];


    //Init
    $scope.getUser();
    $scope.getSignups();
  }])
