express = require 'express'
router = express.Router()
mongoose = require 'mongoose'

Signup = mongoose.model 'Signup'
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
	console.log("NEW SIGNUP",req.body)
	signup = new Signup req.body
	signup.save (err)->
		if !err
			res.json signup.toJSON()
		else
			res.error 400

#
router.get '/', (req,res,next)->	#READ
	Signup.
	find().populate('user','displayName color').
	exec (e, signups)->
		console.log(signups)
		if e
			return console.log e
		res.json signups

#
router.get '/:id?', (req, res, next)->	#READ
	res.json "hi"

router.patch '/:id?', (req, res)->	#UPDATE
	Signup.
	findById(req.params.id).
	exec (err,signup)->
		if err
			res.json err
		else if signup == null
			res.sendStatus 404
		else
			signup = recurseUpdate(signup,req.body)
			signup.save (err)->
				if err
					console.log err
					res.status 500
			res.json signup

router.delete '/:id', (req,res,next)->	#DELETE
	Signup.
	findById(req.params.id).
	exec (err,signup)->
		if err
			res.json err
		else if signup == null
			res.sendStatus 404
		else
			Signup.findByIdAndRemove signup._id, (err)->
				if err
					console.log err
			res.sendStatus 204

module.exports = router
