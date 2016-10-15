mongoose = require 'mongoose'
Schema = mongoose.Schema

encrypt = require 'mongoose-encryption'


userCore =
	username: String,
	password: String,
	displayName: String,
	color: String,

	#True: System always signs up user and the drops place.
	#False: System only signs up user if place requested.
	cautiousMode:
		type: Boolean,
		default: true

	sendEmails:
		type: Boolean,
		default: true

	dieteryRequirements: 
		type: String,
		default: ""
	liverIn: 
		type: Boolean,
		default: false


userSchema = new Schema userCore

secret = "bigsecretkey"
#encryptionKey = process.env.SOME_32BYTE_BASE64_STRING;
#jknjn{ encryptionKey: encKey, signingKey: sigKey }
userSchema.plugin(encrypt, {secret: secret, encryptedFields:['password']})
 
User = mongoose.model('User', userSchema);

mongoose.model 'User', User
