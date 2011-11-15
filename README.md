# DryKup
Markup as CoffeeScript Without Magic

DryKup is an informal fork of Maurice Machado's excellent [CoffeeKup](https://github.com/mauricemach/coffeekup).  It is not a real fork because there is little common code. Until DryKup has better documentation, you can study coffeeKup and check here for the differences.  I wrote a micro-book on coffeekup [here](https://github.com/mark-hahn/coffeekup-intro) and I will do the same for DryKup.

The dryKup github project can be found [here](https://github.com/mark-hahn/drykup).

## Status: *Version 0.1*

DryKup has only been tested on the three included test files.  I will be moving it into existing production code soon so it should get to beta status quite quickly.

## My apology for the weird name, DryKup

The first reason I named it dryKup is that I like short names as I am a lazy typist.  

More to the point, coffeeKup has what I call *magic*. There are things going on behind the scenes that present a barrier to new users.  This magic also causes restrictions in the operation which DryKup tries to remove.  The word *natural* is an antonym of *magic*.  A type of coffee known as *natural* coffee is also known as *dry* coffee. Hence dryKup is the natural version of coffeeKup.

## Drykup is *just* coffeeKup which is *just* coffeeScript which is *just* javaScript

The dryKup template code (which is actually a coffescript DSL) is almost compatible with the coffeeKup template function. Here are some differences ...
 
1) Values returned from arguments with type `function` are ignored.  This is how coffeeKup used to work.  So this coffeeKup code ...

    a href:'/home', -> 'Go Home'
    
... must be replaced with the following or the *Go Home* will not be in the output. I'm not sure why anyone would put the function in there to begin with.

	a href:'/home', 'Go Home'
 
2) DryKup does not destroy the closure for the template.  This means you don't have to pass in the *locals* var or other params to any compile function.

3) All variables in the template closure are *live* without using any `with` statement. DryKup can be used in javaScript strict mode.

## How DryKup works compared to CoffeeCup

There is no compile phase.  Unlike coffeeKup, drykup just runs immediately.  DryKup is a simple library that you include with your app to generate html directly by executing the dryKup *template*.  This may be a disadvantage compared to coffeeKup because coffeKup compiled templates are fast.  If you are only running a template once, then dryKup is faster because it doesn't have the compile step overhead.  There is a slim chance dryKup may be as fast even for multiple runs.  This conjecture needs to be tested.



## How does DryKup do this?

There are two major parts of the magic in coffeeKup.  Both consist of adding more coffeeScript to the template function source and then creating a new *compiled* function. The first magic is defining the HTML tags as functions.  The second magic is adding a hidden variable to keep the HTML results as it is generated.

DryKup gets rid of this magic by explicity defining the HTML tag functions and a dryKup object instance which has a `htmlOut` property to hold the output.  So nothing is hidden and everything just executes as normal coffeeScript with no compile phase.

## Why you should use DryKup instead of CoffeeKup.

The short answer is that there is no reason.  CoffeKup has advantages and dryKup has its own. It's a matter of personal style.  If I had to pick a single reason for creating dryKup, it would be the retention of closure.

## Example DryKup code: *The Mandatory Hello World*

	{head, title, body} = drykup = require('drykup')()
	head ->                     
		title 'Hello World'
	body ->

Executing this code will result in the property `drykup.htmlOut` containing this ...

	<head>
		<title>Hello World</title>
	</head>
	<body>
	</body>

As you can see, the executable tag functions, `head`, `title`, and `body`, are simple functions from the dryKup module. These function declarations can get somewhat large, but you can just cut and paste the code.  Also, these only need to be defined once in a module with multiple templates.  Also, you may be surprised at how few different tags you actually use.  You can build up the definition code by just running into function undefined errors and adding them on the fly.

Note that in a browser, dryKup is defined globally as `window.drykup`. And if you are really 
brave you can make the tag functions themselves be global.  Just execute `drykup.defineGlobalTagFuncs()`.

The dryKup philosophy is that the template is natural code with visible clear definitions.  This is no different than requiring variable definitions in the beginning of any source.

## Installing

	npm i drykup

## Usage

You create and instance of the `Drykup` class by calling this factory function.  See test examples for real-world usage.
 
    drykup = require('drykup')(options)
    
`options` is not required.  If included it must be an object with optional properties.  Here are 
some examples.

    htmlOut: '<doctype xxx>'  # Initial value of the html buffer.  Defaults to ''.
    indent:'     '            # This text is applied to the beginning of each output line.
    expand: true              # This flag will cause all attribute and style specifications
                              #      to use a weird shorthand languge.  I will document it soon.

## License

Standard MIT license.  See `LICENSE` file.
