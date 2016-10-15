express = require 'express'
router = express.Router()
mongoose = require 'mongoose'

#Make formal Requests

request = require('request')

module.exports = {
	checkConnection:(username,password,callback) ->
		options = {
		    url: 'https://community.dur.ac.uk/castle.jcrformals/password/',
		    method: 'GET',
		    port: 443,
		    auth: {
		        user: username,
		        pass: password
		    }
		}
		request options, (error, response, body) ->
		  console.log(response.statusCode)
		  if response.statusCode == 200
		  	callback(true)
		  else
		  	callback(false)
		  return



signupCautious:(user)->
	#Signup user to all possible formals
	if user.liverIn
		liverinString = "Liver+Out"
	else
		liverinString = "Liver+In"

	options = {
	    url: 'https://community.dur.ac.uk/castle.jcrformals/password/',
	    method: 'GET',
	    port: 443,
	    auth: {
	        user: user.username,
	        pass: user.password
	    }
	}

	console.log("Add pass")
	return;
	options.auth.pass = ""

	for i in [0...4]
		msg = "Name="+user.displayName+
		"&Dietery+Requirements="+user.dieteryRequirements+
		"&Guest="+""+
		"&liver+in+status="+liverinString+
		"&pageNumber="+i+
		"&submit=Submit"

		options.body = msg
		request options, (error, response, body) ->
		  console.log(response.statusCode)


	signupNotCautious:(event)->
		#Signup based on a specific event
		console.log("signup begun")
		if event.user.liverIn
			liverinString = "Liver+Out"
		else
			liverinString = "Liver+In"
		if event.guest
			guestString = "guest"
		else
			guestString = ""
		url = 'http://community.dur.ac.uk/castle.jcrformals/password/'

		options = {
		    url: 'https://community.dur.ac.uk/castle.jcrformals/password/',
		    method: 'GET',
		    port: 443,
		    auth: {
		        user: event.user.username,
		        pass: event.user.password
		    }
		}

		console.log("Add pass")
		return;
		options.auth.pass = ""


		#Check which index matches date
		request options, (error, response, body) ->
			if response.statusCode == 200
				body = body.replace(/<(\w+)\b[^<>]*>[\s\S]*?<\/\1>/g, ',')
				body = body.replace(/(<([^>]+)>)/ig, ',')
				body = body.replace(/[,]+/g, ',');
				body = body.replace(/[\s]+/g, ' ');
				body = body.slice(1,-1)
				console.log(body)
				dateArray = []
				for date in body.split(',')
					date = date.split(" ")
					date = date[date.length-1]
					dateArray.push(new Date(date))

				#find index match with event date:
				for i in [0...dateArray.length]
					d = dateArray[i]
					console.log(d,event.date)
					if d.valueOf() == event.date.valueOf()
						console.log("Found",d,event.date)

						#Now do request
						msg = "Name="+event.user.displayName+
						"&Dietery+Requirements="+event.user.dieteryRequirements+
						"&Guest="+guestString+
						"&liver+in+status="+liverinString+
						"&pageNumber="+i+
						"&submit=Submit"

						options.body = msg
						request options, (error, response, body) ->
						  console.log(response.statusCode)
						  if response.statusCode == 200
						    return

}