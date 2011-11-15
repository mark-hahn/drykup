###
  File: drykup.coffee
  Author: Mark Hahn
  DryCup is a CoffeeScript html generator compatible with CoffeeKup but without the magic.
  DryKup is open-sourced via the MIT license.
  See https://github.com/mark-hahn/drykup
###

# ------------------- Constants stolen from coffeeKup (Release 0.3.1) ---------------------
# ----------------------------- See KOFFEECUP-LICENSE file --------------------------------

# Values available to the `doctype` function inside a template.
# Ex.: `doctype 'strict'`
doctypes =
  'default': '<!DOCTYPE html>'
  '5': '<!DOCTYPE html>'
  'xml': '<?xml version="1.0" encoding="utf-8" ?>'
  'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
  'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
  '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
  'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
  'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
  'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

# Private HTML element reference.
# Please mind the gap (1 space at the beginning of each subsequent line).
elements =
  # Valid HTML 5 elements requiring a closing tag.
  # Note: the `var` element is out for obvious reasons, please use `tag 'var'`.
  regular: 'a abbr address article aside audio b bdi bdo blockquote body button
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
 html i iframe ins kbd label legend li map mark menu meter nav noscript object
 ol optgroup option output p pre progress q rp rt ruby s samp script section
 select small span strong style sub summary sup table tbody td textarea tfoot
 th thead time title tr u ul video'

  # Valid self-closing HTML 5 elements.
  void: 'area base br col command embed hr img input keygen link meta param
 source track wbr'

  obsolete: 'applet acronym bgsound dir frameset noframes isindex listing
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol
 nobr spacer tt'

  obsolete_void: 'basefont frame'

# Create a unique list of element names merging the desired groups.
merge_elements = (args...) ->
  result = []
  for a in args
    for element in elements[a].split ' '
      result.push element unless element in result
  result

# ------------------- End of constants stolen from coffeeKup ---------------------

util = require('util')
dbg = (txt, obj) -> 
	if not obj? then obj = txt; txt = ''
	util.puts 'DBG ---> ' + txt + '\n' + util.inspect(obj) + '\n'

class Drykup 
	constructor: (@htmlOut = '') -> @indent = ''
	clearHtml: -> @htmlOut = ''
	defineGlobalTagFuncs: -> if window then for name, func of @ then window[name] = func
	
	addText: (s) -> if s then @htmlOut += @indent + s + '\n'; ''

	normalTag: (tagName, args) ->
		attrstr = ''; innertext = func = null
		for arg in args
			switch typeof arg
				when 'string', 'number' then innertext = arg
				when 'function' then func = arg
				when 'object'
					for name, val of arg
						attrstr += ' ' + name + '="' + val.toString().replace('"', '\\"') + '"'
				else console.log 'DryKup: invalid argument, tag ' + tagName + ', ' + arg.toString()
		@htmlOut += @indent + '<' + tagName + attrstr + '>' + '\n'
		if innertext or func
			@indent += '  '
			@addText innertext
			@addText func?()
			@indent = @indent[0..-3]
		@htmlOut += @indent + '</' + tagName + '>' + '\n'
		''

	selfClosingTag: (tagName, args) ->
		attrstr = ''
		for arg in args
			if typeof arg is 'object'
				for name, val of arg
					attrstr += ' ' + name + '="' + val.toString().replace('"', '\\"') + '"'
			else console.log 'DryKup: invalid argument, tag ' + tagName + ', ' + arg.toString()
		@htmlOut += @indent + '<' + tagName + attrstr + ' />' + '\n'
		''

drykup = -> 
	dk = new Drykup()
	dk.doctype = (type) -> dk.addText doctypes[type]
	dk.text    =    (s) -> dk.addText s
	dk.coffeescript =   -> dk.addText 'coffeescript tag not implemented'
	for tagName in merge_elements 'regular', 'obsolete'
		do (tagName) ->
			dk[tagName] = (args...) -> dk.normalTag tagName, args
	for tagName in merge_elements 'void', 'obsolete_void'
        do (tagName) ->
        	dk[tagName] = (args...) -> dk.selfClosingTag tagName, args
	dk

if module.exports then module.exports = drykup else windows.drykup = drykup

