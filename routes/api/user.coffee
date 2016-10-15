express = require 'express'
router = express.Router()
mongoose = require 'mongoose'

User = mongoose.model 'User'
nodemailer = require 'nodemailer'
Host = mongoose.model 'Host'

ObjId = mongoose.Types.ObjectId


recurseUpdate = (obj,diff)->				#Loop through key value pairs, if value is an object recurse else update values
	for key, value of diff
		if (typeof value) == 'object' && (typeof obj[key]) == 'object' #(Naively) just assumes 'object' type is key-value pairs
			obj[key] = recurseUpdate(obj[key],value)
		else
			obj[key] = value
	return obj


router.post '/:info?', (req,res,next)->	#CREATE
	console.log("NEW USER")
	deets = if req.params.info then JSON.parse(encodeURIComponent(req.params.info)) else req.body
	deets = {}
	delete deets._id
	console.log deets
	user = new User deets
	user.username = "admin"
	user.password = "admin"
	user.displayName = "John Smith"
	user.color = '#'+Math.floor(Math.random()*16777215).toString(16)
	user.save (err)->
		if err
			console.log err
		res.redirect '/dash'

#
router.get '/', (req,res,next)->	#READ
	User.
	find().
	exec (e, users)->
		if e
			return console.log e
		for user in users
			user.password = ""
		res.json users
#
router.get '/:id?', (req, res, next)->	#READ
	if req.params&&req.params.id&&req.params.id.match /^[0-9a-fA-F]{24}$/
		User.
		findById(req.params.id).
		exec (e, user)->
			if e
				return next e
			user.password = ""
			console.log(user)
			res.json user


router.patch '/:id', (req, res)->
	console.log("modifying", req.params.id)
	User.
	findById(req.params.id).
	exec (err, user)->
		if err
			res.json err
		else if user == null
			res.send 404
		else
			req.body.password = user.password
			user = recurseUpdate(user,req.body)
			user.save (err)->
				if err
					console.log err
					res.status 500
					return err
				res.json {'message':'Object updated'}
#
###router.delete '/:id', (req,res,next)->	#DELETE
	if req.user.isAdmin
		CsiSt	aff.
		findById(req.params.id).
		exec (err,staff)->
			if err
				res.json err
			else if req.user.company != csiId || staff.company == req.user.company
				staff.remove()
			else
				res.json {'go_away':"You aren't in that company!"}
	else
		res.json {'go_away':"You aren't admin!"}###
#

module.exports = router
