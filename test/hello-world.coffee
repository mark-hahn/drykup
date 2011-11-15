
{head, title, body} = drykup = require('../bin/drykup')()

head ->                     
	title 'Hello World'
body ->

console.log '.... HTML ....\n' + drykup.htmlOut
