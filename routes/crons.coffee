#crons
console.log("CRON BEGUN")

schedule = require('node-schedule')
mongoose = require 'mongoose'
User = mongoose.model 'User'
Signup = mongoose.model 'Signup'
signupFunctions = require('./formalRequests.coffee')
 
signupRule = new schedule.RecurrenceRule()
signupRule.hour = 8
#signupRule.minute = 0
#signupRule.second = 1

#temp for testing
signupRule.hour = 12
#signupRule.minute = 40
#signupRule.minute = 52
signupRule.second = [0, new schedule.Range(0,59,15)]


#remove above	

 
schedule.scheduleJob(signupRule, ()->
	console.log("signup cron begun")
	d = new Date();
	d.setDate(d.getDate() + 1);
	d.setHours(23)
	d.setMinutes(59)
	d.setSeconds(59)

	d2 = new Date();
	d2.setDate(d2.getDate() + 2);
	d2.setHours(23)
	d2.setMinutes(59)
	d2.setSeconds(59)

	Signup.
	find({date:{,"$gt": d,"$lte": d2}}).populate('user').
	exec (err,signups) ->
		for signup in signups
			#console.log signup.user
			#signupFunctions.checkConnection(signup.user.username,signup.user.password,console.log)
			signupFunctions.signup(signup)
)

removeSignupRule = new schedule.RecurrenceRule()
removeSignupRule.hour = 12
removeSignupRule.minute = 59

#temp for testing
removeSignupRule.hour = 17
removeSignupRule.minute = 50
#remove above	
 
schedule.scheduleJob(removeSignupRule, ()->
	console.log("remove cron begun")

	User.
	find().
	exec (err,user) ->
		console.log("drop formal space for ",user)
		#signupFunctions.checkConnection(user.username,user.password,console.log)
)