# DryKup
Markup as CoffeeScript Without Magic

_This is not real yet.  It is just a spec that I am working on implementing._

DryKup is a fork of Maurice Machado's excellent [CoffeeKup](https://github.com/mauricemach/coffeekup).  Until DryKup
has better documentation, you can study coffeeKup and check here for the differences.  I wrote a micro-book on 
coffeekup [here](https://github.com/mark-hahn/coffeekup-intro) and I will do the same for DryKup.

## My apology for the weird name, DryKup

The first reason I named it dryKup is that I like short names as I am a lazy typist.  

More to the point, coffeeKup has what I call *magic*. There are things going on behind the scenes that present a barrier to new users.  This magic also causes restrictions in the operation which DryKup tries to remove.  The word *natural* is an antonym of *magic*.  A type of coffee known as *natural* coffee is also known as *dry* coffee. Hence dryKup is the natural version of coffeeKup.

## Drykup is *just* coffeeKup which is *just* coffeeScript which is *just* javaScript

The dryKup template code (which is actually a coffescript DSL) is 100% compatible with the coffeeKup template function.

## Differences between DryKup and CoffeeCup

1) There is no compile phase.  Unlike coffeeKup, drykup just runs immediately.  DryKup is a simple library that you include with your app to generate html directly by executing the dryKup *template*.  This may be a disadvantage compared to coffeeKup because coffeKup compiled templates are fast.  If you are only running a template once, then dryKup is faster because it doesn't have the compile step overhead.  There is a slim chance dryKup may be as fast even for multiple runs.  This conjecture needs to be tested.

2) DryKup does not destroy the closure for the template.  This means you don't have to pass in the *locals* vars.

3) All variables in the template closure are *live* without using any `with` statement. DryKup can be used in javaScript strict mode.


## How does DryKup do this?

There are two major parts of the magic in coffeeKup.  Both consist of adding more coffeeScript to the template function source and then creating a new *compiled* function. The first magic is defining the HTML tags as functions.  The second magic is adding a hidden variable to keep the HTML results as it is generated.

DryKup gets rid of this magic by explicity defining the HTML tag functions and a dryKup object instance which has a `html` property to hold the output.  So nothing is hidden and everything just executes as normal coffeeScript with no compile phase.

## Why you should use DryKup instead of CoffeeKup.

The short answer is that there is no reason.  CoffeKup has advantages and dryKup has its own. It's a matter of personal style.  If I had to pick a single reason for creating dryKup, it would be the retention of closure.

## Example DryKup code: *The Mandatory Hello World*

	{head, title, body} = drykup = require 'drykup'
	head ->                     
		title 'Hello World'
	body ->

Executing this code will result in the property `drykup.html` containing this ...

	<head>
		<title>Hello World</title>
	</head>
	<body>
	</body>

As you can see, the executable tag functions, `head`, `title`, and `body`, are simple functions from the dryKup module. These function declarations can get somewhat large, but you can just cut and paste the code.  Also, these only need to be defined once in a module with multiple templates.  Also, you may be surprised at how few different tags you actually use.  You can build up the definition code by just running into function undefined errors and adding them on the fly.

The dryKup philosophy is that the template is natural code with visible clear definitions.  This is no different than requiring variable definitions in the beginning of any source.

## Installing

	npm i drykup

## Usage

There is no command-line.  No options.  Just `require` the lib and use it.

## License

Standard MIT license.  See `LICENSE` file.
