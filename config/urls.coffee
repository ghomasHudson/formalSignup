module.exports =
	'ENV' : process.env.ENV || 'dev',
	'mongoDB' : process.env.dbURL || 'mongodb://webapp:wineGums@ds015928.mongolab.com:15928/formaldetails'