#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance

SetBatchLines, -1
;~ SetControlDelay, -1
;~ SetKeyDelay, -1
DetectHiddenWindows, On
;~ SetTitleMatchMode, 3
Process, Priority,, High

#Include GDIP.ahk
#Include Gdip_ImageSearch.ahk

Menu, Tray, Icon, IconDeactive.ico
Menu, Tray, Add , Restart , l_Restart
Menu, Tray, Add , Quit , l_Quit
Menu, Tray, Click , 1
Menu, Tray, NoStandard

active:=0, gdipToken := Gdip_Startup(), clicker := new Clicker()

global OffsetX:=6, OffsetY:=-65, MouseOffset:=40
global ResetState := 0, ResetSubstate := 0
global StatCnt:=0, StatPer:=0, StatBuy:=0, Stat:=0
;~ super global var
global Bitmaps, Images, Mouses, Maps, NDSteps, Main, Subs
global timer:=Object, IsTB:=false, IsVKT:=false

SetUpGameHWND()
;~ init var & const
LoadBitmaps()
SetUpMap()
SetUpImage()
SetUpNgaoDu()

Suspend, On
;~ Hotkey, IfWinActive, ahk_class MozillaWindowClass
Hotkey, IfWinActive, S4
Hotkey, F1, l_ToggleKeys
Hotkey, Esc, l_StopExec
Hotkey, ^LButton, l_SetWinOrPos
;~ Hotkey, Space, l_SimClick
;~ Hotkey, LButton, l_MultiClick
loop 4
	Hotkey % A_Index, l_Num%A_Index%
return

l_ToggleKeys:
	suspend
	if(active:=!active) {
		Hotkey, Esc, On
		Hotkey, ^LButton, On
		;~ Hotkey, Space, On
		;~ Hotkey, LButton, On
		loop 4
			Hotkey % A_Index , On
		Menu, Tray, Icon, IconReady.ico
	} else {
		Hotkey, Esc, Off
		Hotkey, ^LButton, Off
		;~ Hotkey, Space, Off
		;~ Hotkey, LButton, Off
		loop 4
			Hotkey % A_Index , Off
		clicker.Stop()
		Menu, Tray, Icon, IconDeactive.ico
	}
	return
l_Num1:
	if !EnableSH
		ToggleSH(EnableSH:=!EnableSH)
	clicker.Start("FarmQDExec")
	return
l_Num2:
	clicker.Start("FnExec", 350,, Mouses)
	return
l_Num3:
	clicker.Start()
	return
l_Num4:
 	clicker.Start("FnExec", 250, Images, Mouses)
	;~ clicker.Start("QTExec", 550)
 	return
/* Label_5:
 * 	;~ clicker.Start("TimTriKy", 750)
 * 	;~ clicker.Start("NgaoDu", 550)
 * 	;~ clicker.Start("ThapTL", 550)
 * 	clicker.Start("DucTB", 550)
 * 	return
 */
l_StopExec:
	if EnableSH
		ToggleSH(EnableSH:=!EnableSH)
	clicker.Stop()
	return
l_SimClick:
	;~ MouseGetPos, x, y
	clicker.SequencesClick(Mouses)
	return
l_MultiClick:
	MouseGetPos, x, y
	y-=MouseOffset
	;~ OutputDebug % "" x "," y
	clicker.MemberClick({x:x, y:y})
	clicker.DoClick({x:x, y:y})
	return
l_SetWinOrPos:
	if(GetKeyState("LButton", "P")) {
		MouseGetPos x, y, win
		y-=MouseOffset
		Mouses.Push({x: x, y: y})
		FileAppend % "{x:" x ", y:" y "}`n", point.txt
		if (Main = -1) {
			loop % Subs.length()
			{
				if (Subs[A_Index] = win)
				{
					Main:=Subs.RemoveAt(A_Index)
					break
				}
			}
		}
		OutputDebug % "" Main
	}
	return
l_Restart:
	Reload
	return
l_Quit:
	For k, v in Bitmaps
		Gdip_DisposeImage(v)
	Bitmaps:={}, clicker:=Object, Mouses:="", Images:="", Maps:=""
	Gdip_Shutdown(gdipToken)
	ExitApp
	return

class Clicker {
	__New() {
		
	}
	
	FnExec(ImgSeq, MouseSeq) {
		static index:=1
		if ResetSubstate
		{
			ResetSubstate:=0, index:=1
		}
		if this.FindImage2("skip")
			return
		
		if(!ImgSeq) {
			this.SequencesClick(MouseSeq, !true)
		}
		clicked := false
		if this.FindImage({area:"89|288|856|420", name:"nhanx2", pnt:{x:695, y:440}})
		{	
			if this.FindImage({area:"89|288|856|420", name:"nhanthuong", pnt:{x:704, y:518}})
				return
		}
		else if(this.FindImage({area:"89|288|856|420", name:"exchange"}))
		{
			;~ OutputDebug % "" index
			if index = 2 ;~ dont buy tc
			{
				index++
				return
			}
			
			x:=252+index*80, y:=450
			this.DoClick({x:x, y:y}) ;~ select
			this.DoClick({x:685, y:542}) ;~ exchange
			if this.FindImage({area:"89|288|856|420", name:"confirm1", pnt:{x:461, y:387}}) 
			or this.FindImage({area:"89|288|856|420", name:"confirm2", pnt:{x:445, y:398}})
			{
				index++
				if (index = 5)
				{
					if this.FindImage({area:"89|288|856|420", name:"thoatTB", pnt:{x:783, y:543}})
						index:=1
				}
			}
			return
		}
		else 
		{
			if this.FindImage({area:"540|308|115|180", name:"xbtn"}) 
			and !this.FindImage({area:"540|308|115|180", name:"attack"}) 
			and !this.FindImage({area:"540|308|115|180", name:"tiencong"})
			;~ and !IsTB
				return 0 ;~ bad connection
				;~ OutputDebug % "bad connection!!"
			for s in ImgSeq 
			{
				clicked := this.FindImage(ImgSeq[s])
				if (clicked) {
					name := ImgSeq[s].name
					if( name = "hetluot" or name = "tiencong") {
						;~ this.DoClick(646,216) ;~ close
						index++
					}
					break
				}
			}
			
			if !clicked
				clicked:= this.FindImage2("loadcbfail")
		}
			
		if( MouseSeq && index > MouseSeq.length()) {
			;~ OutputDebug % "FnExec Delta: " (A_TickCount-dt)
			return 1
		}

		if(!clicked && MouseSeq) {
			this.DoClick(MouseSeq[index])
		}
		return 0
		;~ OutputDebug % "FnExec Delta: " (A_TickCount-dt)
	}
	
	;~ call function
	Stop() {
		if(timer)
			SetTimer % timer, Delete
		Mouses:=[]
		Menu, Tray, Icon, IconReady.ico
		ResetState := 0
		if Stat
		{
			FileAppend % "Buy: " StatBuy ", Times: " StatCnt ", Period(mins):" (A_TickCount-StatPer)/(1000*60) "`n", Statistics.txt
			bm:=GDIP_BitmapFromScreen("hwnd:" Subs[1] "|280|100|55|15")
			Gdip_SaveBitmapToFile(bm, "End.png", 100)
			Gdip_DisposeImage(bm)
			Stat:=0, StatCnt:=0, StatPer:=0, StatBuy:=0
		}
	}
	Start(FnName:="NA", period:=175, ImgSeq:=0, MouseSeq:=0) {
		if timer
			SetTimer % timer, Delete
		if (FnName<>"NA")
			timer := ObjBindMethod(this, FnName, ImgSeq, MouseSeq) 
		else if this.FindImage2("duc", false)
			timer := ObjBindMethod(this, "DucTB"), period:=550
		else if this.FindImage2("vkt", false)
			timer := ObjBindMethod(this, "VKTFarming"), period:=250 
		else if this.FindImage2("canquet", false)
			timer := ObjBindMethod(this, "FnExec", Images, Mouses), period:=250 
		else if this.FindImage2("dinhphu", false)
			timer := ObjBindMethod(this, "TimTriKy"), period:=750
		else if this.FindImage2("vuot_disable", false)
			timer := ObjBindMethod(this, "ThapTL"), period:=350
		else 
			timer := ObjBindMethod(this, "GoldFarming"), period:=250
		
		SetTimer % timer, % period
		Menu, Tray, Icon, IconExecuting.ico
		ResetState := 1, ResetSubstate := 1
	}
	
	QTExec(prm*) {
		
		if this.FindImage({area:"825|440|115|115", name:"skill"})
			return
		
		if this.FindImage2("tanglinh") 
		{
			loop, 5
			{
				Sleep 200
				this.DoClick({x:396, y:267})
			}
			return
		} 
		
		if this.FindImage({area:"825|440|115|115", name:"nothing"})
		;~ or this.FindImage2("tanglinh", false) 
			this.SequencesClick(Mouses)
		;~ else if this.FindImage2("tanglinh") 
		;~ {
			;~ loop, 5
			;~ {
				;~ Sleep 200
				;~ this.DoClick({x:396, y:267})
			;~ }
		;~ } 
		;~ else if this.FindImage({area:"825|440|115|115", name:"skill"})
		;~ {
			;~ OutputDebug % "skill found!!"
			;~ this.DoClick({x:924, y:383})
		;~ }
		;~ if this.FindImage2("tinhtu")
			;~ return
		;~ this.SequencesClick(Mouses)
	}
	DucTB( param* )
	{
		static state:=0, tick:=0, count:=0
		if ResetState ;~ reset state once before run
		{
			ResetState:=state:=tick:=0
		}
		if this.FindImage2("ducthatbai", false)
		or this.FindImage2("kodubac", false)
		{
			if this.FindImage2("tab_kho")
			{
				state:=1
				return
			}
		}
		if state=1
		{
			if this.FindImage2("silverchest")
				if this.FindImage2("moruong")
					return
			;~ if this.FindImage2("nhanhover")
			if this.FindImage2("nhan")	
			{
				tick:=A_TickCount, count++, state:=2
				FileAppend % "Open chest at " A_Hour ":" A_Min ":" A_Sec ", total: " count " times`n", Statistics.txt
				return
			}
			
		}
		if state=2
		{
			if (A_TickCount-tick > 550) ;~ wait for sync
			{
				if this.FindImage2("tab_cuonghoa")
					return
				
				if this.FindImage2("duc", false)
				{
					tick:=state:=0
					return
				}
			}
		}
		if state=0
		{
			this.DoClick({x:584, y:465})
		}
	}
	
	TimTriKy(prm*) {
		;~ if this.FindImage2("noichuyen") 
		;~ or this.FindImage2("caotu") 
		;~ danh pham
		if this.FindImage2("thuongnhan") 
		or this.FindImage2("phuthuong") 
		;~ farm VH
		or this.FindImage2("cap6") 
		or this.FindImage2("cap5") 
		or this.FindImage2("cap4") 
		or this.FindImage2("6caphover") 
		or this.FindImage2("5caphover") 
		or this.FindImage2("4caphover") 
			return
		this.SequencesClick(Mouses)	
	}
	
	NgaoDu(prm*) {
		static step:=1, lastmove:=0
		if ResetState ;~ reset state once before run
		{
			ResetState := 0, step:=1
		}
		if this.FindImage({area:"461|553|70|19", name:"ndstart", pnt:{x:531, y:454}})
		or this.FindImage({area:"509|304|38|39", name:"eor"})
		{
			this.Stop()
			return
		}
		diff := A_TickCount - lastmove
		if(diff >= 5050) {
			if this.FindImage2("cuongche")
				return
			if this.FindImage2("xucxac" NDSteps[step])
				if (++step > NDSteps.length())
					step:=1 ; restart
			lastmove := A_TickCount
		}
	}
	
	ThapTL(prm*)
	{
		static state:=0
		if ResetState ;~ reset state once before run
		{
			ResetState := 0, state:=0
		}
		if state=0 
		{
			
			if this.FindImage2("vuot_disable", false)
			{
				;~ OutputDebug % "do click!! at input " state
				this.DoClick({x:707, y:283})
				state++
			}
			else
			{
				this.DoClick({x:547, y:502})
			}
		}
		else if state=1
		{
			;~ ControlFocus,,ahk_id %Main%
			ControlSend,ahk_parent,999, ahk_id %Main%
			;~ Send, {Raw}999
			if this.FindImage2("vuotthap")
				state++
		}
		else if state=2
		{
			;~ OutputDebug % "do click!! at input " state
			if this.FindImage2("dongy")
				state:=0
		}
	}
	FarmQDExec(prm*) {
		static index:=0, next:=0
		if ResetState ;~ reset state once before run
		{
			ResetState := 0, index:=0, next:=0
		}
		if(next) {
			next:=0
			if( index < Maps.length() ) {
				if index = 1 
					this.DoClick({x:907, y:584})
				else if index = 3 ;~ ma nguc
					this.DoClick({x:623, y:148})
				else	
					this.DoClick({x:427, y:624}) 
				index:=0
			} else {
				this.Stop()
			}
			;~ CurMouse:=1
			return
		}
		
		if(!index) {
			index:=this.GetMapPosClick()
			if index=-1
				this.Stop()
			else if !index
			{
				next:=1
				return
			}
			else 
				ResetSubstate := 1
		}
				
		next:=this.FnExec(Images, Maps[index].pnt)
	}
	
	MultiSubs(prms*)
	{
		if IsVKT
			this.VKTFarming()
		else
			this.GoldFarming()
	}
	
	GoldFarming()
	{
		static state:=0, index:=0, tick_1:=0, tick_2:=0, s_index_1:=0, s_index_2:=0
		if ResetState
		{
			ResetState:=0, state:=0, index:=0, tick_1:=0, tick_2:=0, Stat:=1, StatBuy:=0, StatCnt:=0, StatPer:=A_TickCount
			bm:=GDIP_BitmapFromScreen("hwnd:" Subs[1] "|280|100|55|15")
			Gdip_SaveBitmapToFile(bm, "Start.png", 100)
			Gdip_DisposeImage(bm)
		}
		if (state=0)
		{
			if (index<Subs.length()+1)
			{
				loop % Subs.length()+1
				{
					win:=Subs[A_Index-1]
					if this.FindImage2("attack", true, win)
					{
						index++
					}
					else
					{
						this.DoClick(Mouses[1], win)
					}
				}
			}
			
			if (index=Subs.length()+1 and this.FindImage2("lapdoi"))
			{	
				state++, index:=0
			}
		}
		else if (state=1)
		{
			allin:=0
			loop % Subs.length()
			{
				if this.FindImage2("inteam", false, Subs[A_Index])
					allin++
				else if this.FindImage2("host,host2,host3", true, Subs[A_Index])
					return
			}
			if (allin=Subs.length())
			{
				state++, index:=0
			}
		}
		else if (state=2)
		{
			this.FindImage2("confirm2")
			if this.FindImage2("khaichien")
				return
			
			if(index < Subs.length()+1) {
				loop % Subs.length()+1
				{
					win:=Subs[A_Index-1]
					if this.FindImage2("loadcbfail", true, win) {
						index++
					} else if(this.FindImage({area:"784|699|226|32", name:"thoat"}, win)) {
						this.DoClick({x:965, y:613}, win)
						index++
					} else if(this.FindImage({area:"784|699|226|32", name:"ketqua"}, win)) {
						this.DoClick({x:820, y:613}, win)
					}  
				}
				;~ return
			}
			if(index = Subs.length()+1) {
				state:=4, index:=0, s_index_1:=0, s_index_2:=0
			}
		}
		else if (state=4)
		{
			;~ if (index < Subs.length()+1)
			allok:=0
			{
				loop % Subs.length()+1
				{
					win:=Subs[A_Index-1]
					if (tick_%A_Index% > 0) 
					{
						allok++, diff:=A_TickCount-tick_%A_Index%
						if (diff>50000)
							tick_%A_Index%:=0
					}
					else if this.FindImage2("100ql,100ql2", false, win)
					{
						this.QuayTinhTu(s_index_%A_Index%, tick_%A_Index%, win)
						;~ OutputDebug % "s_spining_" A_Index "=" s_spining_%A_Index%
						if (s_index_%A_Index% = 0)
							allok++
					}
					else 
					{
						this.FindImage2("xbtn", true, win) ;~ double check
						allok++
					}
				}
			}
			if (allok=Subs.length()+1)
				index:=0, state:=0, StatCnt++
		}
	}
	
	VKTFarming()
	{
		static state:=0, index:=0, tick:=0, dt:=0
		
		if ResetState ;~ reset state once before run
		{
			ResetState:=0, state:=0, index:=0, tick:=0
		}
		
		if (state=0)
		{
			if(this.FindImage({area:"212|455|48|58", name:"vkt"})) {
				this.DoClick({x:245, y:378})
			} else if(this.FindImage({area:"469|626|70|25", name:"tcvkt"})) {
				this.DoClick({x:504, y:533})
			} else if(this.FindImage({area:"738|632|67|21", name:"ldvkt"})) {
				this.DoClick({x:775, y:538})
				;~ ok, wait for team up
				state++
				this.MemberClick({x:257, y:381}) ;~ go in
				this.MemberClick({x:510, y:533}) ;~ attk
			}
		}
		else if (state=1)
		{
			if (index<Subs.length())
			{
				loop % Subs.length()
				{
					if this.FindImage2("inteam", false, Subs[A_Index])
					{
						;~ OutputDebug % "Ok, " Subs[A_Index] " ready!"
						index++
					}
					else if this.FindImage2("host,host2,host3", true, Subs[A_Index]) 
					{
						;~ OutputDebug % "" Subs[A_Index] " found host, joined in!!"
					}
				}
				;~ return
			}	
			
			if (index=Subs.length()) ;~ and this.FindImage2("khaichien"))
			{
				if this.FindImage({area:"784|699|226|32", name:"thoat"})
				{ ;~ ok go
					state++, index:=0, tick:=0
				} else {
					this.DoClick({x:810, y:541})
				}
			}
		}
		else if (state=2)
		{
			if(this.FindImage({area:"472|555|42|18", name:"thoatvkt"})) {
				loop % Subs.length() 
				{
					if(!this.FindImage({area:"472|555|42|18", name:"thoatvkt"}, Subs[A_Index]))
						return
				}
				this.MemberClick({x:505, y:460})
				this.DoClick({x:505, y:460})
				state:=0, index:=0
				return
			}
			
			diff := A_TickCount - tick
			per := 7250 / (Subs.length() + 1)
			if(diff > per) { 
				x:=257+index*76, y:=381+index*54, tick := A_TickCount
				this.DoClick({x:x, y:y}, Subs[index]) ;~ join lane
				this.DoClick({x:467, y:387},  Subs[index]) ;~ accept buy
				if (++index > Subs.length())
					index:=0
			}
		}
	}
	
	QuayTinhTu(byref state, byref tick, win)
	{	;~ state
		;~ 	0: start
		;~ 	1:
		;~ 	2:
		;~ 	3: open > check number of chest
		;~ 	4: click on buy
		;~ 	5: input chests to buy then confirm
		;~ 	6:
		;~ 	7:
		;~ 	8:
		;~ 	9: click on selfopen chest
		;~ 	10: confirm open then close
		;~ OutputDebug % "QuayTinhTu:: >> " win
		if !win
			win:=Main
		
		if state=0
		{
			if this.FindImage2("tinhtu",true, win)
				state++
		}
		else if state=3 ;~ spin open
		{
			if this.FindImage2("zeroleft", false, win)
			{
				if this.FindImage2("buy", true, win)
				{
					state++
				}
			}
			else if this.FindImage2("selfopen", true, win) ;~ have some chests, just open it
			{
				state:=10
			}
			else if this.FindImage2("xbtn", true, win) ;~ spinning, close it
			{
				state:=0
			}
		}
		else if state=4 ;~ buy
		{
			if this.FindImage2("confirm2", false, win)
			{
				this.DoClick({x:440, y:318}, win)
				state++ ;~ move next state to avoid doubleclick-like
			}
		}
		else if state=5
		{
			ControlSend,ahk_parent,{Raw}0, ahk_id %win%
			if this.FindImage2("confirm2", true, win)
			{
				state++
				if (win=Subs[1])
					StatBuy++
			}
		}
		else if state=9 ;~ open chest
		{
			if this.FindImage2("selfopen", true, win)
				state++
		}
		else if state=10
		{
			if this.FindImage2("confirm2", true, win)
				if this.FindImage2("xbtn", true, win)
					tick:=A_TickCount, state:=0
		}
		else
		{
			state++
		}
		
		return state
	}

	
	
	;~ internal function
	IsEmpty(Arr) {
		return !Arr._NewEnum()[k, v]
	}
	
	DoClick(point, win:=0) {
		x:=point.x, y:=point.y+MouseOffset
		if !win 
			win:=Main
		ControlClick x%x% y%y%, ahk_id %win%,,,, NA
	}
	
	MemberClick(point) {
		loop % Subs.length() 
		{
			this.DoClick(point, Subs[A_Index])
		}
	}
	
	SequencesClick(Seq, recieve:=false, win:=0)
	{
		if this.IsEmpty(Seq)
			return
		if recieve
			this.FindImage2("countdown")
		loop % Seq.length()
		{
			this.DoClick(Seq[A_Index])
			;~ this.MemberClick(Seq[A_Index])
		}
	}
	
	ClickIfPixelExist(screen){
		area:=screen.area
		StringSplit, s, area, |
		x:=s1+OffsetX, y:=s2+OffsetY, w:=s3, h:=s4
		bmpArea := GDIP_BitmapFromScreen("hwnd:" Main "|" x "|" y "|" w "|" h) 
		x:=0, y:=0 ;~, w:= Gdip_GetImageWidth(bmpArea), h:=Gdip_GetImageHeight(bmpArea)
		total:=0, cnt:=0, ave:=0
		while (y < h){
			while (x < w) {
				c := Gdip_GetPixel(bmpArea, x, y), x++
				setformat,integer,hex
				c+=0
				setformat,integer,decimal
				if(c <> screen.argb) {
					total+=c, cnt++
				}
			}
			x:=0, y++
		}
		
		ave := Round(total/cnt)
		x:=(ave < 4281972639)?screen.pnt.x1:screen.pnt.x2, y:=screen.pnt.y
		this.DoClick({x:x, y:y})
		
		Gdip_DisposeImage(bmpArea)
	}
	
	FindImage(screen, win:=0) {
		if !win
			win:=Main
		area:=screen.area
		StringSplit, s, area, |
		x:=s1+OffsetX, y:=s2+OffsetY, w:=s3, h:=s4
		bmpArea := GDIP_BitmapFromScreen("hwnd:" win "|" x "|" y "|" w "|" h) 
		;~ if screen.name = "canquet"
		;~ {
			;~ Gdip_SaveBitmapToFile(bmpArea, "canquet.png", 100)
			;~ Gdip_SaveBitmapToFile(Bitmaps[screen.name], "find.png", 100)
		;~ }
		res := Gdip_ImageSearch(bmpArea, Bitmaps[screen.name])
		if res > 0 
		{
			;~ OutputDebug % "[FindImage] image " screen.name "!!"
			if screen.pnt <> ""
				this.DoClick(screen.pnt)
		}
		else
		{
			;~ if screen.name = "canquet"
			;~ {
				;~ OutputDebug % "[FindImage] image " screen.name " not found!!"
			;~ }
		}
		Gdip_DisposeImage(bmpArea)
		return (res > 0)
	}
	FindImage2(names, click:=true, win:=0) {
		if !win
			win:=Main
		;~ x:=0, y:=85, w:=700, h:=600
		bmpArea := GDIP_BitmapFromScreen("hwnd:" win "|0|73|1010|600") 
		Loop, Parse, names, `,
		{
			;~ Gdip_SaveBitmapToFile(bmpArea, "screen2.png", 100)
			;~ Gdip_SaveBitmapToFile(Bitmaps[A_LoopField], name "2.png", 100)
			;~ bmpFind := Gdip_CreateBitmapFromFile("res\" screen.name ".png")
			;~ res := Gdip_ImageSearch(bmpArea, bmpFind)
			res := Gdip_ImageSearch(bmpArea, Bitmaps[A_LoopField], list)
			if res > 0 
			{
				if click
				{
					StringSplit, C, list, `,
					x:=C1, y:=75+C2-MouseOffset
					if names contains "host,host2,host3"
					{
						x:=C1+200
					}
					this.DoClick({x:x,y:y}, win)
				}
				goto EndFnc
			}
		}	
		EndFnc:
		Gdip_DisposeImage(bmpArea)
		return (res > 0)
	}
	GetMapPosClick()
	{
		loop % Maps.length()
		{
			name:=Maps[A_Index].name
			if(this.FindImage({area:"440|705|120|22", name:name})) {
				if (name = "gcd2" or name = "hhuy" or name = "duongco") {
					;GoPrev:=true
					return 0
				}
				return A_Index
			}
		}
		return -1
	}
}


LoadBitmaps()
{
	Bitmaps:={}
	texture:=Gdip_CreateBitmapFromFile("Clicker.png")
	Loop, Read, Clicker.txt
	{
		StringSplit, S, A_LoopReadLine, =
		name:=Trim(S1)
		StringSplit, C, % Trim(S2), % A_Space
		;~ OutputDebug % "name: " name " x: " C1 ", y:" C2 ", w:" C3 ", h:" C4
		Bitmaps[name] := Gdip_CloneBitmapArea(texture, C1, C2, C3, C4)
		;~ Gdip_SaveBitmapToFile(Bitmaps[name], "raw\" name ".png", 100)
	}
	Gdip_DisposeImage(texture)
}
SetUpGameHWND() {
	Main:=-1, Subs:=[], T:="S2,S4"
	Loop, Parse, T, `,
	{
		WinGet, all, List, %A_LoopField%
		;~ OutputDebug % "found " all " " A_LoopField
		loop % all
		{
			Subs.Push(all%A_Index%)
			WinMove, % "ahk_id " all%A_Index%,, -5, 321, 1010, 678
			OutputDebug % "" A_Index ": " all%A_Index%
		}
	}
	
	if( Subs.length() = 1) {
		Main:=Subs.Pop()
	}
	return
}
SetUpMap() {
	Maps:=[]
	Maps.Push({name:"pbevent", pnt:[{x:721, y:178},{x:606, y:275},{x:751, y:439},{x:630, y:406},{x:581, y:370},{x:576, y:441},{x:533, y:402},{x:449, y:353},{x:402, y:382},{x:326, y:449}]})
	Maps.Push({name:"pbbingo", pnt:[{x:719, y:166},{x:828, y:222},{x:648, y:262},{x:735, y:332},{x:575, y:319},{x:306, y:252}]}) ;~ ,{x:208, y:299},{x:362, y:343},{x:490, y:373},{x:709, y:419}]})
	Maps.Push({name:"tinhthiet", pnt:[{x:138, y:267},{x:96, y:323}]}) ;~ tinhthiet >> map huong lang
	Maps.Push({name:"manguc", pnt:[{x:853, y:160}]}) ;~ ma nguc thach
	;~ Maps.Push({name:"khienmasa", pnt:[{x:445, y:329}]}) ;~ khien ma sa >> map khuong toc
	;~ Maps.Push({name:"mapdqt", pnt:[{x:517, y:270},{x:632, y:242}, {x:518, y:267},{x:603, y:309}]})
	;~ Maps.Push({name:"nhamgiap", pnt:[{x:577, y:466}]})  ;~ hoa nham >> map tieu di 
	Maps.Push({name:"tieudi", pnt:[{x:654, y:176}]})
	Maps.Push({name:"dongdoan", pnt:[{x:763, y:178}]})
	Maps.Push({name:"khuongtoc", pnt:[{x:933, y:218}]})
	Maps.Push({name:"trankhien", pnt:[{x:764, y:263}]})
	Maps.Push({name:"duongnghi", pnt:[{x:782, y:216}]})
	Maps.Push({name:"hoanghao", pnt:[{x:882, y:231}]})
	Maps.Push({name:"dienchuong", pnt:[{x:272, y:253}]})
	Maps.Push({name:"malong", pnt:[{x:792, y:250}]})
	Maps.Push({name:"vuonghon", pnt:[{x:324, y:432}]})
	Maps.Push({name:"hotuan", pnt:[{x:705, y:192}]})
	Maps.Push({name:"hhuy", pnt:[{x:696, y:193}]})
	Maps.Push({name:"gcd2", pnt:[{x:316, y:433}]})
	Maps.Push({name:"vuongco", pnt:[{x:771, y:160}]})
	Maps.Push({name:"sonviet", pnt:[{x:718, y:160}]})
	Maps.Push({name:"gcdan", pnt:[{x:920, y:254}]})
	Maps.Push({name:"vanuong", pnt:[{x:476, y:191}]})
	Maps.Push({name:"ctuyen2", pnt:[{x:805, y:322}]})
	Maps.Push({name:"ctuyen1", pnt:[{x:790, y:187}]})
	Maps.Push({name:"chunghoi", pnt:[{x:798, y:480}]})
	Maps.Push({name:"duongco", pnt:[{x:813, y:301}]})
	Maps.Push({name:"vudoc", pnt:[{x:815, y:211}]})
	;~ Maps.Push({name:"vudoc", pnt:[{x:378, y:176}]})
	Maps.Push({name:"lubo2", pnt:[{x:768, y:247}]})
	Maps.Push({name:"lubo1", pnt:[{x:604, y:209}]})
	;~ Maps.Push({name:"lubo1", pnt:[{x:491, y:413}]})
	Maps.Push({name:"mocthu", pnt:[{x:789, y:212}]})
	Maps.Push({name:"thachtran", pnt:[{x:836, y:275}]})
	;~ Maps.Push({name:"thachtran", pnt:[{x:744, y:476}]})
	Maps.Push({name:"dinhnguyen", pnt:[{x:775, y:186}]})
	Maps.Push({name:"hatien", pnt:[{x:665, y:117}]})
	;~ Maps.Push({name:"hatien", pnt:[{x:524, y:352}]})
	Maps.Push({name:"tmy2", pnt:[{x:750, y:174}]})
	Maps.Push({name:"tmy1", pnt:[{x:726, y:165}]})
	;~ Maps.Push({name:"tmy1", pnt:[{x:230, y:318}]})
	Maps.Push({name:"nbd", pnt:[{x:583, y:256}]})
	Maps.Push({name:"dongtrac", pnt:[{x:522, y:160}]})
	;~ Maps.Push({name:"dongtrac", pnt:[{x:743, y:234}]})
	Maps.Push({name:"thiencong", pnt:[{x:908, y:312}]})
	Maps.Push({name:"diacong", pnt:[{x:596, y:230}]})
	;~ Maps.Push({name:"diacong", pnt:[{x:757, y:362}]})
	Maps.Push({name:"tatu", pnt:[{x:372, y:182}]})
	Maps.Push({name:"biencuong2", pnt:[{x:936, y:315}]})
	Maps.Push({name:"biencuong1", pnt:[{x:905, y:441}]})
	Maps.Push({name:"tmyhuaxuong", pnt:[{x:744, y:130}]})
	Maps.Push({name:"hanhuyen", pnt:[{x:737, y:136}]})
	return
}
SetUpImage() {
	Images:=[]
	Images.Push({area:"446|455|60|18", name:"hetluot", pnt:{x:643, y:222}})
	Images.Push({area:"549|431|75|45", name:"attack", pnt:{x:585, y:343}})
	Images.Push({area:"549|431|75|45", name:"tiencong", pnt:{x:643, y:222}})
	Images.Push({area:"629|594|178|38", name:"lapdoi", pnt:{x:695, y:513}})
	Images.Push({area:"629|594|178|38", name:"khaichien", pnt:{x:765, y:513}})
	Images.Push({area:"784|699|226|32", name:"ketqua", pnt:{x:820, y:613}})
	Images.Push({area:"784|699|226|32", name:"thoat", pnt:{x:965, y:613}})
	Images.Push({area:"425|530|80|30", name:"xemlai", pnt:{x:547, y:444}})
	;~ Images.Push({area:"515|539|56|13", name:"thoat2", pnt:{x:547, y:444}})
	Images.Push({area:"422|458|70|20", name:"dongy", pnt:{x:462, y:369}})
	Images.Push({area:"89|288|856|420", name:"canquet", pnt:{x:576, y:392}})
	Images.Push({area:"89|288|856|420", name:"quetnhanh", pnt:{x:696, y:378}})
	Images.Push({area:"89|288|856|420", name:"chien", pnt:{x:598, y:413}})
	Images.Push({area:"89|288|856|420", name:"nhanx2", pnt:{x:695, y:440}})
	Images.Push({area:"89|288|856|420", name:"suachua", pnt:{x:446, y:425}})
	Images.Push({area:"89|288|856|420", name:"nhanthuong", pnt:{x:704, y:518}})
	Images.Push({area:"89|288|856|420", name:"confirm1", pnt:{x:461, y:387}})
	Images.Push({area:"89|288|856|420", name:"confirm2", pnt:{x:445, y:398}})
	Images.Push({area:"89|288|856|420", name:"thoatTB", pnt:{x:783, y:543}})
	return
}

SetUpNgaoDu() {
	;~ NDCuongChe:=[{x:359, y:446},{x:442, y:449},{x:516, y:444},{x:578, y:438},{x:658, y:445},{x:731, y:436}]
	;~ NDSteps:=[1,6,6,5,6,5,3,2,6,2,4,2,6,2,5,5,6,1,4,3,1,4,4,1]
	NDSteps:=[6,5,3,5,6,5,3,2,6,6,5,5,6,6,5,4,3,1,4,4]
	return
}
ToggleSH(turnOn){
	if !ce:=WinExist("Cheat Engine 6.7")
		return
	ControlClick, Enable Speedhack, ahk_id %ce%,,,, NA
	if turnOn
	{
		Sleep 250
		ControlSetText, 1.0, 50, ahk_id %ce%
		ControlClick, Apply, ahk_id %ce%,,,, NA
	}
	return
}