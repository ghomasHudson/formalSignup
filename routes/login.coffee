express = require 'express'
router = express.Router()
mongoose = require 'mongoose'


# GET home page.
router.get '/login', (req, res, next) ->
	res.render 'template',
		content:'login'

router.get '/newUser', (req, res, next) ->
	console.log("Make a vol")
	res.render 'template',
		content:'login'


module.exports = router
