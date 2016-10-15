mongoose = require 'mongoose'
Schema = mongoose.Schema



signupCore =
	date: Date,
	user: { type: Schema.Types.ObjectId, ref: 'User' },
	guest: Boolean


signupSchema = new Schema signupCore


Signup = mongoose.model('Signup', signupSchema);

mongoose.model 'Signup', Signup
