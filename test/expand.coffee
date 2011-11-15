
{head, title, body, style, div, a, img} = drykup = require('../bin/drykup') expand: yes

console.log style.toString()

colors = userDoc = {}
menuBtns = []

style "	 body {m:0 p:0 ff:helvetica,arial,sans-serif fs:13}
		.notifyBtn {f:l c:p ml:4 mr:10 bc:#eee b:1pxsg fs:10 pl:3 pr:3 
					-moz-border-radius:5  border-radius:5}
		.unselectable {
			-moz-user-select:-moz-none
			-khtml-user-select:none
			-webkit-user-select:none
			user-select:none }
		.subHead {c:b f:l fw:b fs:i fs:14}
		 table 	 {mt:10 b:1px+solid+#ccc border-collapse:collapse}
		.rowSel  {bc:#eee}
		.button  {fs:11 pt:1 pr:3 pb:1 pl:3 c:p f:r ml:5 -moz-border-radius:3 border-radius:3}
		.round5  {-moz-border-radius:5  border-radius:5 }
		.round10 {-moz-border-radius:10 border-radius:10}
	"

div x:"i=notifyNotice p:r t:-30 l:0 h:0 p:0 fs:13 ta:c bc:black c:white fw:b c:p b:n
		db=html:n.notice", ->
	div x:"i=menuBar c:b f:l min-width:950 h:18 w:100% bc:#{colors.bkg}" , ->
		for btn in menuBtns
			[url, name, w, wbold, h] = btn
			[divW, ml] = (if name is 'review' then  [w+25, 5] else [w+40, 20]) 
			mt = 15-h
			if pageName is name
				div x:"c=menuBtnSel f:l w:#{divW} h:100% bc:#{colors.menuBkgSel}", ->
					img x:"c=btnImgSel src=/views/images/menu-bar-#{name}-wht-#{w}x#{h}.png
							w:#{w} w=#{w} h:#{h} h=#{h} ml:#{ml} mt:#{mt} b:n"
			else
				if name isnt 'log-out' or userDoc
					div x:"c=menuBtnNotSel c:p f:l data-loc=/page/#{url}", ->
						div x:"c=menuBtnNrml w:#{divW} h:100%", ->
							img x:"c=btnImgNorml 
									src=/views/images/menu-bar-#{name}-blk-#{w}x#{h}.png
									w:#{w} w=#{w} h:#{h} h=#{h} ml:#{ml} mt:#{mt} b:n"
						div x:"c=menuBtnHover w:#{divW} h:100% d:n", ->
							img x:"c=btnImgHover w:#{w} w=#{w} h:#{h} h=#{h} ml:#{ml} mt:#{mt} b:n
									src=/views/images/menu-bar-#{name}-blk-bold-#{wbold}x#{h}.png"
		if userDoc
			div x:"f:l mt:1 bc:t fs:11 p:r l:-10 t:2 max-width:220 o:h", "(#{userDoc.emailAddress})"
		a x:"b:n href=/", ->
			img x:"f:r mt:1 mr:35 w=122 w:122 h:18 h=18 b:n src=/views/images/logo-122x18.png"
	
div id:"menuBar2", x:"c:b f:l h:24 w:100% bc:#{colors.menu2Bkg}", -> menuBar2?()

console.log '.... HTML ....\n\n' + drykup.htmlOut
