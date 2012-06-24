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
 select small span strong sub summary sup table tbody td textarea tfoot
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

# ------------------- constants for shorthand aliases -------------------------
attrAliases  = 
	w:'width', h:'height', s:'src', src:'src', hr:'href', href:'href', c:'class', db:'data-bind'
	i:'id', n:'name', v:'value', m:'method', t:'type'
	cp:'cellpadding', b:'border', cs:'colspan', rs:'rowspan', chk:'checked', sel:'selected'

styleValueAliases =
	'm:a':'margin:auto', 'ml:a':'margin-left:auto',  'mt:a':'margin-top:auto'
	'mr:a':'margin-right:auto',  'mb:a':'margin-bottom:auto' 
	'c:b':'clear:both', 'f:l':'float:left', 'f:r':'float:right', 'f:n':'float:none'
	'fw:b':'font-weight:bold', 'fw:n':'font-weight:normal'
	'fs:i':'font-style:italic', 'fs:n':'font-style:normal'
	'p:a':'position:absolute', 'p:r':'position:relative', 'p:f':'position:fixed'
	'd:n':'display:none', 'd:b':'display:block', 'd:f':'display:fixed'
	'ta:l':'text-align:left', 'ta:c':'text-align:center', 'ta:r':'text-align:right'
	'o:a':'overflow:auto', 'o:h':'overflow:hidden'
	'c:a':'cursor:auto', 'c:p':'cursor:pointer'
	'tt:u':'text-transform:uppercase', 'tt:c':'text-transform:capitalize' 
	'tt:l':'text-transform:lowercase'
	'td:n':'text-decoration:none', 'td:u':'text-decoration:underline' 
	'td:lt':'text-decoration: line-through', 'lh:n':'line-height:normal'
	'b:n': 'border:none'
	'b:1pxsb' :'border:1px solid black'
	'bl:1pxsb':'border-left:1px solid black',  'bt:1pxsb':'border-top:1px solid black'
	'br:1pxsb':'border-right:1px solid black', 'bb:1pxsb':'border-bottom:1px solid black'
	'b:1pxsg' :'border:1px solid gray'    
	'bl:1pxsg':'border-left:1px solid gray',  'bt:1pxsg':'border-top:1px solid gray'
	'br:1pxsg':'border-right:1px solid gray', 'bb:1pxsg':'border-bottom:1px solid gray'
	'zi:a':'z-index:auto', 'zi:i':'z-index:inherit'
	'v:v':'visibility:visible', 'v:h':'visibility:hidden'

styleAliases = 
	l:'left', t:'top', r:'right', w:'width', h:'height', c:'color', bc:'background-color'
	fs:'font-size', lh:'line-height', zi:'z-index'
	b:'border', bl:'border-left', bt:'border-top', br:'border-right', bb:'border-bottom'
	m:'margin', ml:'margin-left', mt:'margin-top', mr:'margin-right', mb:'margin-bottom'
	p:'padding', pl:'padding-left', pt:'padding-top', pr:'padding-right', pb:'padding-bottom'
	v:'visibility', ff:'font-family'

# ---------------------------- alias shorthand expansion code ---------------------------------
whiteSpace = (str) ->
	str.replace(/([^~])\+/g, '$1 ').replace(/~\+/g, '+')

expandAttrs = (v = '', styleOnly = false) -> 
	attrs = {}; styles = {}
	v = v.replace /\s+/g, '~`~'
	parts = v.split '~`~'
	for part in parts
		if not (thirds = ///^ ([^=:]*) (=|:) (.*) $///.exec part) then continue
		[d, name, sep, value] = thirds
		if not styleOnly and sep == '=' 
			if name == 'in'
				attrs.id = value
				attrs.name = value
			else
				if (aa = attrAliases[name]) then name = aa
				attrs[name] = whiteSpace value
		if sep == ':' 
			if (sva = styleValueAliases[part]) then [name, value] = sva.split ':'
			else 
				if (sa = styleAliases[name]) then name = sa
				if name != 'z-index' and /^-?\d+$/.test value then value = value + 'px'
				else value = whiteSpace value
			styles[name] = value
	style = ("#{k}:#{v}" for k, v of styles).join '; '
	if styleOnly then return style
	if style then attrs['style'] = style
	attrs
	
expandStyle = (v) ->
	s = ''
	while parts = v.match ///^ ([^{]*) \{ ([^}]*) \} ([\s\S]*) $///
		[x, pfx, style, v] = parts
		s += pfx + '{' + expandAttrs(style, true) + '}'
	s + v

extendX = (newSpecStrs = {}, oldSpecStrs) -> 
	for key, newSpecStr of newSpecStrs
		if not (oldSpecStr = oldSpecStrs[key]) then oldSpecStrs[key] = newSpecStr; continue
		specsObj = {}
		addSpecStr = (specStr) ->
			for spec in (specStr.replace(/\s+/g, '~`~').split '~`~')
				if not (specParts = ///^ ([^=:]*(=|:)) (.*) $///.exec spec) then continue
				specsObj[specParts[1]] = specParts[3]
			null
		addSpecStr oldSpecStr
		addSpecStr newSpecStr
		oldSpecStrs[key] = (nameSep + val for nameSep, val of specsObj).join ' '
	oldSpecStrs

# -------------------------------- main drykup code ------------------------------

util = require('util')
dbg = (txt, obj) -> 
	if not obj? then obj = txt; txt = ''
	util.puts 'DBG ---> ' + txt + '\n' + util.inspect(obj) + '\n'

class Drykup 
	constructor: (opts = {}) -> 
		@indent  = opts.indent  ? ''
		@htmlOut = opts.htmlOut ? ''
		@expand  = opts.expand  ? false
		
	resetHtml: (html = '') -> @htmlOut = html
	
	defineGlobalTagFuncs: -> if window then for name, func of @ then window[name] = func
	
	addText: (s) -> if s then @htmlOut += @indent + s + '\n'; ''
	
	attrStr: (obj) ->
		attrstr = ''
		for name, val of obj
			if @expand and name is 'x' then attrstr += @attrStr expandAttrs val
			else attrstr += ' ' + name + '="' + val.toString().replace('"', '\\"') + '"'
		attrstr

	normalTag: (tagName, args) ->
		attrstr = ''; innertext = func = null
		for arg in args
			switch typeof arg
				when 'string', 'number' then innertext = arg
				when 'function' 		then func = arg
				when 'object'   		then attrstr += @attrStr arg
				else console.log 'DryKup: invalid argument, tag ' + tagName + ', ' + arg.toString()
		@htmlOut += @indent + '<' + tagName + attrstr + '>'
		if func and tagName isnt 'textarea'
			@htmlOut += '\n'
			@indent += '  '
			@addText innertext
			func?()
			@indent = @indent[0..-3]
			@addText '</' + tagName + '>'
		else 
			@htmlOut += innertext + '</' + tagName + '>' + '\n'

	selfClosingTag: (tagName, args) ->
		attrstr = ''
		for arg in args
			if typeof arg is 'object' then attrstr += @attrStr arg
			else console.log 'DryKup: invalid argument, tag ' + tagName + ', ' + arg.toString()
		@addText '<' + tagName + attrstr + ' />' + '\n'

	styleFunc: (str) ->
		if typeof str isnt 'string'
			console.log 'DryKup: invalid argument, tag style, ' + str.toString(); return
		@addText '<style>' + (if @expand then expandStyle str else str)+'\n' + @indent + '</style>'

	extendX: (newSpecStrs = {}, oldSpecStrs) -> 
    	for key, newSpecStr of newSpecStrs
    		if not (oldSpecStr = oldSpecStrs[key]) then oldSpecStrs[key] = newSpecStr; continue
    		specsObj = {}
    		addSpecStr = (specStr) ->
    			for spec in (specStr.replace(/\s+/g, '~`~').split '~`~')
    				if not (specParts = ///^ ([^=:]*(=|:)) (.*) $///.exec spec) then continue
    				specsObj[specParts[1]] = specParts[3]
    			null
    		addSpecStr oldSpecStr
    		addSpecStr newSpecStr
    		oldSpecStrs[key] = (nameSep + val for nameSep, val of specsObj).join ' '
    	oldSpecStrs

drykup = (opts) -> 
	dk = new Drykup(opts)
	
	dk.doctype 		= (type) -> dk.addText doctypes[type]
	dk.text    		=    (s) -> dk.addText s
	dk.coffeescript =   	 -> dk.addText 'coffeescript tag not implemented'
	dk.style 		=    (s) -> dk.styleFunc s
	
	for tagName in merge_elements 'regular', 'obsolete'
		do (tagName) ->
			dk[tagName] = (args...) -> dk.normalTag tagName, args
			
	for tagName in merge_elements 'void', 'obsolete_void'
		do (tagName) ->
        	dk[tagName] = (args...) -> dk.selfClosingTag tagName, args
	dk

if module.exports then module.exports = drykup else window.drykup = drykup

