#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance

SetBatchLines, -1
SetControlDelay, -1
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

;~ super global var
global Bitmaps:={}
global GameHWND, HostHWND, OffsetX:=6, OffsetY:=-65, MouseOffset:=40, EnableSH
global timer:=Object, Mouses, Images, CurMouse
global FarmDQT:=false
global Maps, GoPrev:=false, CurMap:=0
global Searches, VKTState:=-1, VKTLastJoin:=0, VKTLastMem:=0, IsVKT:=false
global NDSteps, NDCurStep, NDLastMove
global TTLState:=0, DucTBState:=0
global TBExchange:=0,isTB:=false

;~ init var & const
Mouses:=[]
LoadBitmaps()
SetUpMap()
SetUpImage()
SetUpGameHWND()
SetUpVKT()
SetUpNgaoDu()

Suspend, On
Hotkey, IfWinActive, S4
Hotkey, F1, l_ToggleKeys
Hotkey, Esc, l_StopExec
Hotkey, ^LButton, l_SetWinOrPos
Hotkey, Space, l_SimClick
;~ Hotkey, LButton, l_SimClick
loop 5
	Hotkey % A_Index, Label_%A_Index%
return

LoadBitmaps()
{
	texture:=Gdip_CreateBitmapFromFile("Clicker.png")
	Loop, Read, Clicker.txt
	{
		StringSplit, S, A_LoopReadLine, =
		name:=Trim(S1)
		StringSplit, C, % Trim(S2), % A_Space
		OutputDebug % "name: " name " x: " C1 ", y:" C2 ", w:" C3 ", h:" C4
		Bitmaps[name] := Gdip_CloneBitmapArea(texture, C1, C2, C3, C4)
		;~ Gdip_SaveBitmapToFile(Bitmaps[name], "output\" name ".png", 100)
	}
	Gdip_DisposeImage(texture)
}
SetUpGameHWND() {
	HostHWND:=-1, GameHWND:=[]
	WinGet, all, List, S2
	OutputDebug % "found " all " S2!"
	loop % all
	{
		GameHWND.Push(all%A_Index%)
		WinMove, % "ahk_id " all%A_Index%,, -5, 0, 1010, 678
	}
	WinGet, all, List, S4
	OutputDebug % "found " all " S4!"
	loop % all
	{
		GameHWND.Push(all%A_Index%)
		WinMove, % "ahk_id " all%A_Index%,, -5, 0, 1010, 678
	}
	
	if( GameHWND.length() = 1) {
		HostHWND:=GameHWND.Pop()
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
	Images.Push({area:"515|539|56|13", name:"thoat2", pnt:{x:547, y:444}})
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
SetUpVKT() {
	Searches:=[]
	;~ qd
	Searches.Push({area:"413|362|64|26", p:{x:635, y:270}})
	Searches.Push({area:"413|429|64|26", p:{x:635, y:335}})
	Searches.Push({area:"413|494|64|26", p:{x:635, y:402}})
	Searches.Push({area:"413|557|64|26", p:{x:635, y:465}})
	;~ vkt
	Searches.Push({area:"367|334|65|26", p:{x:590, y:242}})
	Searches.Push({area:"367|401|65|26", p:{x:590, y:307}})
	Searches.Push({area:"367|466|65|26", p:{x:590, y:374}})
	Searches.Push({area:"367|529|65|26", p:{x:590, y:437}})
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
		ControlSetText, 1.0, 10, ahk_id %ce%
		ControlClick, Apply, ahk_id %ce%,,,, NA
	}
	return
}
l_ToggleKeys:
	suspend
	if(active:=!active) {
		Hotkey, Esc, On
		Hotkey, ^LButton, On
		Hotkey, Space, On
		;~ Hotkey, LButton, On
		loop 5
			Hotkey % A_Index , On
		Menu, Tray, Icon, IconReady.ico
	} else {
		Hotkey, Esc, Off
		Hotkey, ^LButton, Off
		Hotkey, Space, Off
		;~ Hotkey, LButton, Off
		loop 5
			Hotkey % A_Index , Off
		clicker.Stop()
		Menu, Tray, Icon, IconDeactive.ico
	}
	return
Label_1:
	if !EnableSH
		ToggleSH(EnableSH:=!EnableSH)
	clicker.Start("FarmQDExec")
	return
Label_2:
	clicker.Start("FnExec", 350,, Mouses)
	return
Label_3:
	clicker.Start("HostExec")
	return
Label_4:
	clicker.Start("FnExec", 350, Images, Mouses)
	;~ clicker.Start("TimTriKy", 250)
	;~ clicker.Start("ThamBao", 250)
;~	clicker.Start("QTExec", 550)
	;~ clicker.Start("DucTB", 550)
	return
Label_5:
	clicker.Start("TimTriKy", 350)
	;~ clicker.Start("NgaoDu", 550)
	;~ clicker.Start("ThapTL", 550)
	return
l_StopExec:
	if EnableSH
		ToggleSH(EnableSH:=!EnableSH)
	clicker.Stop()
	return
l_SimClick:
	;~ MouseGetPos, x, y
	clicker.SequencesClick(Mouses)
	return
l_SetWinOrPos:
	if(GetKeyState("LButton", "P")) {
		MouseGetPos x, y, win
		y-=MouseOffset
		Mouses.Push({x: x, y: y})
		FileAppend % "{x:" x ", y:" y "}`n", point.txt
		if (HostHWND = -1) {
			loop % GameHWND.length()
			{
				if (GameHWND[A_Index] = win)
				{
					HostHWND:=GameHWND.RemoveAt(A_Index)
					break
				}
			}
		}
		;~ OutputDebug % "" HostHWND
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
		if(!ImgSeq) {
			this.SequencesClick(MouseSeq)
		}
		
		if this.FindImage2("skip")
			return
		
		if this.FindImage({area:"540|308|115|180", name:"xbtn"}) 
		and !this.FindImage({area:"540|308|115|180", name:"attack"}) 
		and !this.FindImage({area:"540|308|115|180", name:"tiencong"})
		and !isTB
			return ;~ bad connection
			;~ OutputDebug % "bad connection!!"
		
		clicked := false
		if this.FindImage({area:"89|288|856|420", name:"nhanx2", pnt:{x:695, y:440}})
		{	
			if this.FindImage({area:"89|288|856|420", name:"nhanthuong", pnt:{x:704, y:518}})
				return
		}
		else if(this.FindImage({area:"89|288|856|420", name:"exchange"}))
		{
			OutputDebug % "" TBExchange
			x:=332+TBExchange*80, y:=450
			this.DoClick({x:x, y:y}) ;~ select
			this.DoClick({x:685, y:542}) ;~ exchange
			if this.FindImage({area:"89|288|856|420", name:"confirm1", pnt:{x:461, y:387}}) 
			or this.FindImage({area:"89|288|856|420", name:"confirm2", pnt:{x:445, y:398}})
			{
				TBExchange++
				if (TBExchange = 4)
				{
					if this.FindImage({area:"89|288|856|420", name:"thoatTB", pnt:{x:783, y:543}})
						TBExchange:=0
				}
			}
			return
		}
		else 
		{
			for s in ImgSeq 
			{
				clicked := this.FindImage(ImgSeq[s])
				if (clicked) {
					name := ImgSeq[s].name
					if( name = "hetluot" or name = "tiencong") {
						;~ this.DoClick(646,216) ;~ close
						CurMouse++
					}
					break
				}
			}
		}
			
		if( MouseSeq && CurMouse > MouseSeq.length()) {
			GoPrev:=true
			;~ OutputDebug % "FnExec Delta: " (A_TickCount-dt)
			return
		}

		if(!clicked && MouseSeq) {
			if(FarmDQT) {
				loop % MouseSeq.length()
					this.DoClick(MouseSeq[A_Index])
			} else {
				this.DoClick(MouseSeq[CurMouse])
			}
		}
		;~ OutputDebug % "FnExec Delta: " (A_TickCount-dt)
	}
	
	;~ call function
	Stop() {
		if(timer)
			SetTimer % timer, Delete
		Mouses:=[]
		VKTState:=-1, FarmDQT:=false, CurMap:=0
		Menu, Tray, Icon, IconReady.ico
	}
	Start(FnName, period:=175, ImgSeq:=0, MouseSeq:=0) {
		if(timer)
			SetTimer % timer, Delete
		timer := ObjBindMethod(this, FnName, ImgSeq, MouseSeq) 
		SetTimer % timer, % period
		TBExchange:=0, NDCurStep:=2, NDLastMove:=0, CurMouse:=1, VKTState:=0, TTLState:=0
		IsVKT:=(this.FindImage({area:"212|455|48|58", name:"vkt"})) 
		isTB:=(this.FindImage({area:"89|288|856|420", name:"canquet"}))
		;~ MsgBox % "ThamBao dectect? " isTB
		Menu, Tray, Icon, IconExecuting.ico
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
		static count:=0
		if this.FindImage2("ducthatbai", false)
		or this.FindImage2("kodubac", false)
		{
			if this.FindImage2("tab_kho")
			{
				DucTBState:=1
				return
			}
		}
		if DucTBState=1
		{
			if this.FindImage2("silverchest")
				if this.FindImage2("moruong")
					return
			;~ if this.FindImage2("nhanhover")
			if this.FindImage2("nhan")	
			{
				count++, DucTBState:=2
				FileAppend % "Open chest at " A_Hour ":" A_Min ":" A_Sec ", total: " count " times`n", Statistic.txt
				return
			}
		}
		if DucTBState=2
		{
			if this.FindImage2("tab_cuonghoa")
				return
			else
				OutputDebug % "not find tab_cuonghoa"
			if this.FindImage2("duc")
			{
				DucTBState:=0
				return
			}
		}
		if DucTBState=0
		{
			this.DoClick({x:584, y:465})
		}
	}
	
	TimTriKy(prm*) {
		if this.FindImage2("noichuyen") 
		or this.FindImage2("caotu") 
		;~ danh pham
		or this.FindImage2("thuongnhan") 
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
		if this.FindImage({area:"461|553|70|19", name:"ndstart", pnt:{x:531, y:454}})
		or this.FindImage({area:"509|304|38|39", name:"eor"})
		{
			this.Stop()
			return
		}
		diff := A_TickCount - NDLastMove
		if(diff >= 5050) {
			if this.FindImage2("cuongche")
				return
			if this.FindImage2("xucxac" NDSteps[NDCurStep])
				if (++NDCurStep > NDSteps.length())
					NDCurStep:=1 ; restart
			NDLastMove := A_TickCount
		}
	}
	
	ThapTL(prm*)
	{
		if TTLState=0 
		{
			
			if this.FindImage2("vuot_disable", false)
			{
				OutputDebug % "do click!! at input " TTLState
				this.DoClick({x:707, y:283})
				TTLState++
			}
			else
			{
				this.DoClick({x:547, y:502})
			}
		}
		else if TTLState=1
		{
			SendRaw, 999
			if this.FindImage2("vuotthap")
				TTLState++
		}
		else if TTLState=2
		{
			OutputDebug % "do click!! at input " TTLState
			if this.FindImage2("dongy")
				TTLState:=0
		}
	}
	FarmQDExec(prm*) {
		dt:=A_TickCount
		if(GoPrev) {
			GoPrev:=false
			if( CurMap < Maps.length() ) {
				if CurMap = 1 
				{ ;~ pvevent
					;~ this.FindImage2("closetoppanle", false)
					this.DoClick({x:907, y:584})
				} 
				else if CurMap = 3 ;~ ma nguc
					this.DoClick({x:623, y:148})
				else	
					this.DoClick({x:427, y:624}) 
				CurMap:=0
			} else {
				this.Stop()
			}
			CurMouse:=1
			return
		}
		
		if(!CurMap) {
			if(!this.GetMapPosClick()) {
				;~ this.Stop()
				;~ return
			}
			;~ OutputDebug % "Update CurMap:" CurMap ", DQT: " FarmDQT
		}
		;~ if CurMap=1
			;~ this.FindImage2("closetoppanle", false)
				
		this.FnExec(Images, Maps[CurMap].pnt)
		;~ OutputDebug % "FarmQDExec Delta: " (A_TickCount-dt)
	}
	
	HostExec(prm*) {
		dt:=A_TickCount
		if(VKTState = 3) { ;~ fighting
			
			if(this.FindImage({area:"472|555|42|18", name:"thoatvkt"})) {
				loop % GameHWND.length() 
				{
					if(!this.FindImage({area:"472|555|42|18", name:"thoatvkt"}, GameHWND[A_Index]))
						return
				}
				this.MemberClick({x:505, y:460})
				this.DoClick({x:505, y:460})
				VKTState:=0
				return
			}
			if(IsVKT) {
				diff := A_TickCount - VKTLastJoin
				if(diff > 2750) { 
					VKTLastMem++
					if(VKTLastMem > GameHWND.length())
						VKTLastMem := 0
					x:=257+(VKTLastMem)*76, y:=381+(VKTLastMem)*54
					this.DoClick({x:x, y:y}, GameHWND[VKTLastMem]) ;~ join lane
					this.DoClick({x:467, y:387},  GameHWND[VKTLastMem]) ;~ accept buy
					VKTLastJoin := A_TickCount
				}
			} else {
				if(VKTLastJoin < GameHWND.length()) {
					loop % GameHWND.length() 
					{
						win:=GameHWND[A_Index]
						if(this.FindImage({area:"784|699|226|32", name:"ketqua"}, win)) {
							this.DoClick({x:820, y:613}, win)
						} else if(this.FindImage({area:"784|699|226|32", name:"thoat"}, win)) {
							this.DoClick({x:965, y:613}, win)
							VKTLastJoin++
						}
					}
					return
				}
				if(this.FindImage({area:"784|699|226|32", name:"ketqua"})) {
					this.DoClick({x:820, y:613})
				} else if(this.FindImage({area:"784|699|226|32", name:"thoat"})) {
					this.DoClick({x:965, y:613})
					VKTState:=0
				} 
			}
		} else if(VKTState=1) {  ;~ teaming up
			joined:=0
			loop % GameHWND.length() 
			{
				win:=GameHWND[A_Index]
				if(this.FindImage({area:"549|431|75|45", name:"attack"}, win)) {
					this.DoClick({x:585, y:343}, win)
				} else { 
					loop % Searches.length() 
					{
						if(this.FindImage({area:"680|345|73|23", name:"inteam"}, win)
						|| this.FindImage({area:"725|373|73|23", name:"inteam"}, win)) { ;~ ok, joined
							joined++
							break
						} else if(this.FindImage({area:Searches[A_Index].area, name:"host"}, win)) {
							x:=Searches[A_Index].p.x, y:=Searches[A_Index].p.y
							this.DoClick({x:x, y:y}, win)
							break
						}
					}
				}
			}
			if(joined = GameHWND.length()) ;~ ok all in >> start
				VKTState++
		} else if(VKTState=2) {
			if (IsVKT)
			{
				;~ Sleep 250
				if(!(this.FindImage({area:"680|345|73|23", name:"inteam"})
				  || this.FindImage({area:"725|373|73|23", name:"inteam"}))) { ;~ ok go
					VKTState++
					VKTLastJoin:=0
				} else {
					this.DoClick({x:810, y:541})
				}
			}
			else if this.FindImage({area:"629|594|178|38", name:"khaichien", pnt:{x:765, y:513}})
			{
				VKTState++
				VKTLastJoin:=0
			}
		} else if(VKTState=0) {
			if(IsVKT) {
				if(this.FindImage({area:"212|455|48|58", name:"vkt"})) {
					this.DoClick({x:245, y:378})
				} else if(this.FindImage({area:"469|626|70|25", name:"tcvkt"})) {
					this.DoClick({x:504, y:533})
				} else if(this.FindImage({area:"738|632|67|21", name:"ldvkt"})) {
					this.DoClick({x:775, y:538})
					;~ ok, wait for team up
					VKTState++
					this.MemberClick({x:257, y:381}) ;~ go in
					this.MemberClick({x:510, y:533}) ;~ attk
				}
			} else {
				if(this.FindImage({area:"549|431|75|45", name:"attack"})) {
					this.DoClick({x:585, y:343})
				} else if(this.FindImage({area:"629|594|178|38", name:"lapdoi"})) {
					this.DoClick({x:695, y:513})
					;~ ok, wait for team up
					VKTState++
					this.SequencesClick(Mouses) ;~ go in
				} else {
					this.SequencesClick(Mouses)
				}
			}
		}
		;~ OutputDebug % "FarmQDExec Delta: " (A_TickCount-dt)
	}
	
	
	;~ internal function
	IsEmpty(Arr) {
		return !Arr._NewEnum()[k, v]
	}
	
	DoClick(point, win:=0) {
		x:=point.x, y:=point.y+MouseOffset
		if !win 
			win:=HostHWND
		ControlClick x%x% y%y%, ahk_id %win%,,,, NA
	}
	
	MemberClick(point) {
		loop % GameHWND.length() 
		{
			this.DoClick(point, GameHWND[A_Index])
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
		bmpArea := GDIP_BitmapFromScreen("hwnd:" HostHWND "|" x "|" y "|" w "|" h) 
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
			win:=HostHWND
		area:=screen.area
		StringSplit, s, area, |
		x:=s1+OffsetX, y:=s2+OffsetY, w:=s3, h:=s4
		bmpArea := GDIP_BitmapFromScreen("hwnd:" win "|" x "|" y "|" w "|" h) 
		res := Gdip_ImageSearch(bmpArea, Bitmaps[screen.name])
		if res > 0 
		{
			OutputDebug % "[FindImage] image " screen.name "!!"
			if screen.pnt <> ""
				this.DoClick(screen.pnt)
		} 
		Gdip_DisposeImage(bmpArea)
		return (res > 0)
	}
	FindImage2(name, click:=true, win:=0) {
		if !win
			win:=HostHWND
		;~ x:=0, y:=85, w:=700, h:=600
		bmpArea := GDIP_BitmapFromScreen("hwnd:" win "|0|73|1010|600") 
		;~ Gdip_SaveBitmapToFile(bmpArea, "screen2.png", 100)
		;~ Gdip_SaveBitmapToFile(Bitmaps[name], name "2.png", 100)
		;~ bmpFind := Gdip_CreateBitmapFromFile("res\" screen.name ".png")
		;~ res := Gdip_ImageSearch(bmpArea, bmpFind)
		res := Gdip_ImageSearch(bmpArea, Bitmaps[name], list)
		if res > 0 
		{
			StringSplit, C, list, `,
			OutputDebug % "found " name " at x: " C1 ", y: " C2
			if click
			{
				x:=C1, y:=85+C2-MouseOffset
				this.DoClick({x:x,y:y})
			}
		} 
		else
			OutputDebug % "" name " not found!"
		
		Gdip_DisposeImage(bmpArea)
		return (res > 0)
	}
	GetMapPosClick()
	{
		FarmDQT:=false
		loop % Maps.length()
		{
			name:=Maps[A_Index].name
			if(this.FindImage({area:"440|705|120|22", name:name})) {
				if (name = "gcd2" or name = "hhuy" or name = "duongco") {
					GoPrev:=true
					return false
				}
				CurMap:=A_Index
				IfEqual, name, mapdqt
					FarmDQT:=true
				return true
			}
		}
		CurMap:=2
		return false
	}
}