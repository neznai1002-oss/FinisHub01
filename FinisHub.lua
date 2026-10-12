-- Подпишитесь на канал Tg: @Finis_Paralich4
print("[Finis] load")

local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local R=game:GetService("RunService")
local W=game:GetService("Workspace")
local SG=game:GetService("StarterGui")
local CP=game:GetService("ContentProvider")
local LP=P.LocalPlayer

local CB={
	esp=false, espWall=true, espText=true, espCol="Pink", espStyle="Chams",
	teamCheck=true,
	tb=false, tbFov=140, tbDel=0.35,
	tracer=false, killMsg=true, dmgMsg=true,
	spin=false, spinSpd=180,
	maxSpd=false, msVal=20,
	noclip=false, air=false,
	fly=false, flySpd=35, flyMode="Camera",
	fastSwitch=false, fsDelay=0.05,
	carHack=false, carSpd=300,
	ammo=false, noreload=false,
	showFov=true,
}

function isEnemy(p)
	if p==LP then return false end
	if CB.teamCheck and p.Team and LP.Team and p.Team==LP.Team then return false end
	return true
end

local DECAL_ID="rbxassetid://108600815593933"
local TEXTURE_ID="rbxassetid://134327784464327"
local LOGO_ID=DECAL_ID

local PG
pcall(function() if gethui then PG=gethui() end end)
if not PG then PG=LP:WaitForChild("PlayerGui") end

local function mk(c,p,par) local o=Instance.new(c) if p then for k,v in pairs(p) do o[k]=v end end if par then o.Parent=par end return o end
local function uc(o,r) return mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function sk(o,c,t,tr) return mk("UIStroke",{Color=c or Color3.fromRGB(60,60,70),Thickness=t or 1,Transparency=tr or 0},o) end
local function tw(o,tm,p) if not o or not o.Parent then return end if type(tm)=="number" then tm=TweenInfo.new(tm) end local ok,tt=pcall(T.Create,T,o,tm,p) if ok and tt then pcall(function() tt:Play() end) end end
local function cam() return W.CurrentCamera end

-- Preload лого ДО старта интро
task.spawn(function()
	pcall(function()
		CP:PreloadAsync({DECAL_ID, TEXTURE_ID})
	end)
end)

print("[Finis] preloading logo...")

-- проверка decal
task.spawn(function()
	task.wait(0.8)
	local d=Instance.new("ImageLabel") d.Image=DECAL_ID
	local tx=Instance.new("ImageLabel") tx.Image=TEXTURE_ID
	local t0=os.clock()
	while os.clock()-t0<4 do if d.IsLoaded or tx.IsLoaded then break end task.wait(0.1) end
	local useTx=false
	if d.IsLoaded then print("[Finis] decal OK")
	elseif tx.IsLoaded then useTx=true LOGO_ID=TEXTURE_ID print("[Finis] texture")
	else useTx=true LOGO_ID=TEXTURE_ID print("[Finis] none") end
	d:Destroy() tx:Destroy()
	if useTx then
		for _,o in ipairs(PG:GetDescendants()) do
			pcall(function()
				if o:IsA("ImageLabel") and (o.Name=="IntroLogo" or o.Name=="PILogo" or o.Name=="HeaderLogo") then
					o.Image=TEXTURE_ID
				end
			end)
		end
	end
end)

local BG=Color3.fromRGB(10,10,13) local CD=Color3.fromRGB(21,21,25)
local BD=Color3.fromRGB(34,34,40) local TX=Color3.fromRGB(232,232,238)
local TD=Color3.fromRGB(140,140,150) local TM=Color3.fromRGB(90,90,100)
local AC=Color3.fromRGB(0,180,220) local ACH=Color3.fromRGB(0,230,255)
local TO=Color3.fromRGB(0,180,220) local TF=Color3.fromRGB(55,55,65)
local TK=Color3.fromRGB(42,42,50) local WT=Color3.fromRGB(255,255,255)
local PL=Color3.fromRGB(15,15,20) local IBT=Color3.fromRGB(4,4,6)
local OL=Color3.fromRGB(240,250,255)
local RED=Color3.fromRGB(255,80,80) local GRN=Color3.fromRGB(90,220,130)

-- LANG
local Lang="en"
local LS={
	en={sub="INTERNAL",tab_aim="AimBot",tab_vis="Visuals",tab_bl="Blatant",tab_gn="Guns",tab_ms="Misc",
		sec_trigger="Triggerbot",sec_spin="Spin",sec_esp="Player ESP",sec_tracer="Tracer",sec_kill="Kill Feed",
		sec_char="Character",sec_flight="Flight",sec_vehicle="Vehicle",sec_ammo="Ammo",sec_fswitch="Fast Switch",
		sec_ui="Interface",sec_lang="Language",t_on="Enabled",
		tg_en="Auto-shoot",tg_fov="FOV",tg_delay="Delay",
		sp_en="Spin",sp_speed="Speed",
		esp_en="Enable ESP",esp_wall="Wallhack",esp_txt="Distance text",esp_col="Color",esp_style="Style",
		tr_en="On shot",kf_kill="Show kills",kf_dmg="Show damage",
		ms_en="Speed hack",ms_val="Value",nc_en="Noclip",aj_en="Air jump",
		fl_en="Fly",fl_spd="Speed",fl_mode="Mode",
		ch_en="Car hack",ch_spd="Max speed",
		am_en="Ammo",nr_en="No reload",fs_en="Auto switch",fs_delay="Delay",
		ui_scale="Menu scale",fov_circle="FOV circle",
		lang_choose="Language"},
	ru={sub="ИНТЕРНАЛ",tab_aim="Аим",tab_vis="Визуалы",tab_bl="Блат",tab_gn="Оружие",tab_ms="Разное",
		sec_trigger="Триггербот",sec_spin="Спин",sec_esp="ESP Игроков",sec_tracer="Трассер",sec_kill="Kill Feed",
		sec_char="Персонаж",sec_flight="Полёт",sec_vehicle="Машина",sec_ammo="Патроны",sec_fswitch="Автосмена",
		sec_ui="Интерфейс",sec_lang="Язык",t_on="Включено",
		tg_en="Авто-выстрел",tg_fov="FOV",tg_delay="Задержка",
		sp_en="Спин",sp_speed="Скорость",
		esp_en="Включить ESP",esp_wall="Сквозь стены",esp_txt="Дистанция",esp_col="Цвет",esp_style="Стиль",
		tr_en="При выстреле",kf_kill="Показ убийств",kf_dmg="Показ урона",
		ms_en="Скорость",ms_val="Значение",nc_en="Сквозь стены",aj_en="Прыжок",
		fl_en="Полёт",fl_spd="Скорость",fl_mode="Режим",
		ch_en="Ускорение",ch_spd="Скорость машины",
		am_en="Патроны",nr_en="Без перезарядки",fs_en="Автосмена",fs_delay="Задержка",
		ui_scale="Размер меню",fov_circle="FOV круг",
		lang_choose="Язык"}
}
local function TR(k) local p=LS[Lang] or LS.en return p[k] or k end
local textReg={}
local function regText(lbl,key) table.insert(textReg,{lbl=lbl,key=key}) lbl.Text=TR(key) end

local G=mk("ScreenGui",{Name="FinisHub",ResetOnSpawn=false,IgnoreGuiInset=true,
	DisplayOrder=9999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)

-- =========================================================
-- INTRO (плавные анимации, палочки, текст)
-- =========================================================
local introDone=false
local function endIntro()
	if introDone then return end
	introDone=true
	task.spawn(function()
		local ov=G and G:FindFirstChild("Intro")
		if ov then tw(ov,0.8,{BackgroundTransparency=1}) task.wait(0.9)
			pcall(function() if ov and ov.Parent then ov:Destroy() end end) end
	end)
end
task.delay(12,function() if not introDone then pcall(endIntro) end end)

pcall(function()
	local OV=mk("Frame",{Name="Intro",Size=UDim2.fromScale(1,1),BackgroundColor3=IBT,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=5000},G)

	-- фон-частицы
	for i=1,20 do
		local sz=math.random(2,5)
		local p=mk("Frame",{Size=UDim2.fromOffset(sz,sz),Position=UDim2.new(math.random()*0.9+0.05,0,1.1,0),
			BackgroundColor3=(i%2==0) and ACH or AC,BackgroundTransparency=0.75,BorderSizePixel=0,Rotation=45,ZIndex=5001},OV)
		uc(p,1)
		tw(p,TweenInfo.new(5+math.random()*3,Enum.EasingStyle.Linear),{Position=UDim2.new(0.05+math.random()*0.85,0,-0.15,0),BackgroundTransparency=1})
	end

	local CX=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(360,280),BackgroundTransparency=1,ZIndex=5005},OV)

	-- лого (появится сразу с fade-in)
	local IntroLogo=mk("ImageLabel",{Name="IntroLogo",AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.08,0),Size=UDim2.fromOffset(110,110),BackgroundTransparency=1,
		Image=LOGO_ID,ImageColor3=WT,ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,ZIndex=5010},CX)
	local IntroLogoScale=mk("UIScale",{Scale=0.3},IntroLogo)

	-- палочки heartbeat — поэтапные анимации
	local HB=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.38,0),Size=UDim2.fromOffset(240,60),BackgroundTransparency=1,ZIndex=5006},CX)
	local PTS={{10,30},{75,30},{88,42},{102,6},{118,30},{230,30}}
	local hbSegs={}
	for i=1,#PTS-1 do
		local p1,p2=PTS[i],PTS[i+1]
		local dx,dy=p2[1]-p1[1],p2[2]-p1[2]
		local len=math.sqrt(dx*dx+dy*dy)
		local ang=math.deg(math.atan2(dy,dx))
		local cx=(p1[1]+p2[1])*0.5
		local cy=(p1[2]+p2[2])*0.5
		local s=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(cx,cy),Size=UDim2.fromOffset(0,2),
			BackgroundColor3=WT,BackgroundTransparency=1,BorderSizePixel=0,Rotation=ang,ZIndex=5007},HB)
		uc(s,1)
		table.insert(hbSegs,{f=s,len=len})
	end

	local lblTitle=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.62,0),Size=UDim2.fromOffset(300,34),
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Finis Hub",TextColor3=WT,TextSize=22,
		TextTransparency=1,ZIndex=5008},CX)
	local lblTitleScale=mk("UIScale",{Scale=1},lblTitle)

	local Status=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.76,0),Size=UDim2.fromOffset(300,16),
		BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="loading",TextColor3=TD,TextSize=11,TextTransparency=1,ZIndex=5008},CX)
	local PBar=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.86,0),Size=UDim2.fromOffset(200,2),
		BackgroundColor3=Color3.fromRGB(30,30,38),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5008},CX)
	uc(PBar,100)
	local PFill=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=WT,BorderSizePixel=0,ZIndex=5009},PBar)
	uc(PFill,100)

	local FL=mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,28,1,-28),Size=UDim2.fromOffset(400,140),BackgroundTransparency=1,ZIndex=5006},OV)
	local fn={"init renderer.dll","injecting payload.sys","loading config.finis","init memory.engine",
		"setup modules.lua","esp.visuals","esp.chams","esp.arrows","esp.smooth","killfeed.module",
		"traffic.hud","triggerbot.auto","noclip.bypass","fly.engine","carhack.turbo","fastswitch.auto","ready."}
	local fL={}
	for i=1,8 do
		local l=mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.fromOffset(0,(i-1)*16),
			BackgroundTransparency=1,Font=Enum.Font.Code,Text="",TextColor3=TD,TextSize=11,
			TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,ZIndex=5007},FL)
		table.insert(fL,l)
	end

	local SKIP=mk("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-20,0,20),Size=UDim2.fromOffset(80,28),
		BackgroundColor3=Color3.fromRGB(20,20,26),BackgroundTransparency=0.4,BorderSizePixel=0,
		Text="SKIP",Font=Enum.Font.GothamBold,TextColor3=TD,TextSize=11,AutoButtonColor=false,ZIndex=5100},OV)
	uc(SKIP,12) sk(SKIP,Color3.fromRGB(50,50,60),1,0.4)
	SKIP.MouseButton1Click:Connect(endIntro)

	-- ============================================================
	-- Timeline (всё плавно)
	-- ============================================================
	task.spawn(function()
		local ok,err=pcall(function()
			-- ШАГ 1 (t=0.2) — лого сразу
			task.wait(0.2)
			if introDone then return end
			tw(IntroLogoScale,TweenInfo.new(1.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1})

			-- пульс лого
			task.spawn(function()
				while not introDone and IntroLogo and IntroLogo.Parent do
					tw(IntroLogo,2,{ImageColor3=Color3.fromRGB(210,250,255)})
					task.wait(2)
					if introDone then break end
					if IntroLogo and IntroLogo.Parent then tw(IntroLogo,2,{ImageColor3=WT}) else break end
					task.wait(2)
				end
			end)

			-- ШАГ 2 (t=1.0) — палочки растут по одной плавно
			task.wait(0.8)
			for i,seg in ipairs(hbSegs) do
				if introDone then return end
				tw(seg.f,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{Size=UDim2.fromOffset(seg.len,2),BackgroundTransparency=0})
				task.wait(0.11)
			end

			-- ШАГ 3 (t=~1.7) — название с bounce
			task.wait(0.4)
			if introDone then return end
			lblTitleScale.Scale=0.6
			tw(lblTitleScale,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1})
			tw(lblTitle,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0})

			task.wait(0.6)
			if introDone then return end
			tw(Status,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0})
			task.wait(0.3)
			if introDone then return end
			tw(PBar,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})

			-- ШАГ 4 — загрузка файлов
			local total=8 local st=os.clock() local fi=1
			while not introDone do
				local e=os.clock()-st
				if e>=total then break end
				local pct=e/total
				PFill.Size=UDim2.new(pct,0,1,0)
				local ti=math.floor(pct*#fn)+1
				if ti>#fn then ti=#fn end
				if ti~=fi then
					-- сдвиг списка с плавностью
					for i=1,#fL-1 do
						fL[i].Text=fL[i+1].Text
						fL[i].TextColor3=Color3.fromRGB(100,100,110)
					end
					fL[#fL].Text="> "..fn[ti].."  [ok]"
					fL[#fL].TextColor3=ACH
					fL[#fL].Position=UDim2.fromOffset(8,7*16)
					tw(fL[#fL],0.4,{Position=UDim2.fromOffset(0,7*16)})
					for i=1,#fL do fL[i].TextTransparency=0 end
					fi=ti
					-- палочки вспыхивают
					for _,seg in ipairs(hbSegs) do
						tw(seg.f,0.15,{BackgroundColor3=ACH})
						task.delay(0.15,function()
							tw(seg.f,0.35,{BackgroundColor3=WT})
						end)
					end
				end
				Status.Text=string.format("loading  %d/%d  [%d%%]",ti,#fn,math.floor(pct*100))
				task.wait(0.08)
			end

			if introDone then return end
			Status.Text="ready" Status.TextColor3=ACH
			PFill.Size=UDim2.new(1,0,1,0)
			tw(PFill,0.4,{BackgroundColor3=ACH})
			task.wait(0.5) if introDone then return end
			for _,seg in ipairs(hbSegs) do tw(seg.f,0.3,{BackgroundColor3=ACH}) end
			task.wait(0.4) if introDone then return end
			for _,seg in ipairs(hbSegs) do tw(seg.f,0.35,{BackgroundColor3=WT}) end
			task.wait(0.6) if introDone then return end

			-- ШАГ 5 — fadeout
			tw(CX,TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,0,0.4,0)})
			tw(IntroLogo,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{ImageTransparency=1})
			tw(IntroLogoScale,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=1.2})
			tw(lblTitle,0.65,{TextTransparency=1})
			tw(lblTitleScale,TweenInfo.new(0.65,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=1.15})
			tw(Status,0.65,{TextTransparency=1})
			tw(PBar,0.65,{BackgroundTransparency=1})
			tw(FL,TweenInfo.new(0.65,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0,28,1,-10)})
			for _,l in ipairs(fL) do tw(l,0.65,{TextTransparency=1}) end
			task.wait(0.9) if introDone then return end
			endIntro()
		end)
		if not ok then warn("[Finis] intro err:",err) endIntro() end
	end)
end)

-- =========================================================
-- MENU (плавные анимации)
-- =========================================================
local MENU=mk("Frame",{Name="Main",Size=UDim2.fromScale(0.95,0.9),Position=UDim2.new(0.5,0,0.5,0),
	AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=BG,BorderSizePixel=0,Visible=false,BackgroundTransparency=1,ZIndex=900},G)
uc(MENU,12) sk(MENU,BD,1,0.2)
mk("UISizeConstraint",{MinSize=Vector2.new(300,320),MaxSize=Vector2.new(720,520)},MENU)
local MSC=mk("UIScale",{Scale=0.85},MENU)

local AccLine=mk("Frame",{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),
	BackgroundColor3=AC,BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=950},MENU)
uc(AccLine,1)
task.spawn(function()
	while G and G.Parent and AccLine and AccLine.Parent do
		tw(AccLine,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.new(0.75,0,0,2),BackgroundTransparency=0.55})
		task.wait(1.8)
		if not (G and G.Parent and AccLine and AccLine.Parent) then break end
		tw(AccLine,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.new(0.42,0,0,2),BackgroundTransparency=0.2})
		task.wait(1.8)
	end
end)

local TOP=mk("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,ZIndex=901},MENU)
mk("ImageLabel",{Name="HeaderLogo",Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(14,9),
	BackgroundTransparency=1,Image=LOGO_ID,ImageColor3=WT,ScaleType=Enum.ScaleType.Fit,ZIndex=902},TOP)
mk("TextLabel",{Size=UDim2.fromOffset(60,18),Position=UDim2.fromOffset(52,16),BackgroundTransparency=1,
	Font=Enum.Font.GothamBold,Text="Finis",TextColor3=TX,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=902},TOP)
local lblInt=mk("TextLabel",{Size=UDim2.fromOffset(90,18),Position=UDim2.fromOffset(90,16),BackgroundTransparency=1,
	Font=Enum.Font.GothamMedium,Text="",TextColor3=TD,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=902},TOP)
regText(lblInt,"sub")
local CLB=mk("TextButton",{Size=UDim2.fromOffset(36,36),Position=UDim2.new(1,-44,0,7),BackgroundTransparency=1,
	Font=Enum.Font.GothamBold,Text="x",TextColor3=TD,TextSize=18,AutoButtonColor=false,ZIndex=905},TOP)
local CLS=mk("UIScale",{Scale=1},CLB)
CLB.MouseEnter:Connect(function() tw(CLS,0.2,{Scale=1.2}) tw(CLB,0.2,{TextColor3=TX,Rotation=90}) end)
CLB.MouseLeave:Connect(function() tw(CLS,0.2,{Scale=1}) tw(CLB,0.2,{TextColor3=TD,Rotation=0}) end)

local CON=mk("Frame",{Size=UDim2.new(1,0,1,-108),Position=UDim2.fromOffset(0,50),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=901},MENU)
mk("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},CON)
local BOT=mk("Frame",{Size=UDim2.new(1,0,0,58),Position=UDim2.new(0,0,1,-58),BackgroundTransparency=1,ZIndex=901},MENU)

local NAV={"AimBot","Visuals","Blatant","Guns","Misc"}
local navKeyMap={AimBot="tab_aim",Visuals="tab_vis",Blatant="tab_bl",Guns="tab_gn",Misc="tab_ms"}
local SEL="Visuals"
local NB,NP={},{}
local CURR
for _,n in ipairs(NAV) do
	local pg=mk("ScrollingFrame",{Name=n,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,
		CanvasSize=UDim2.new(0,0,0,0),ElasticBehavior=Enum.ElasticBehavior.Never,Visible=(n==SEL),ZIndex=901},CON)
	local ls=mk("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},pg)
	local function rf() pg.CanvasSize=UDim2.new(0,0,0,ls.AbsoluteContentSize.Y+20) end
	ls:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(rf)
	task.defer(rf)
	NP[n]=pg
	if n==SEL then CURR=pg end
end
for i,n in ipairs(NAV) do
	local sel=(n==SEL)
	local wr=mk("TextButton",{Size=UDim2.new(1/#NAV,0,1,0),Position=UDim2.fromScale((i-1)/#NAV,0),
		BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=902},BOT)
	local wrS=mk("UIScale",{Scale=1},wr)
	local tl=mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
		Font=sel and Enum.Font.GothamBold or Enum.Font.GothamMedium,Text="",
		TextColor3=sel and TX or TD,TextSize=13,ZIndex=903},wr)
	regText(tl,navKeyMap[n])
	local un=mk("Frame",{Size=UDim2.new(sel and 0.45 or 0,0,0,3),Position=UDim2.new(0.5,0,1,-4),
		AnchorPoint=Vector2.new(0.5,1),BackgroundColor3=AC,BorderSizePixel=0,ZIndex=904},wr)
	uc(un,2)
	NB[n]={btn=wr,scale=wrS,lbl=tl,ul=un}
	wr.MouseEnter:Connect(function()
		if n~=SEL then tw(tl,0.2,{TextColor3=TX}) tw(wrS,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Scale=1.05}) end
	end)
	wr.MouseLeave:Connect(function()
		if n~=SEL then tw(tl,0.2,{TextColor3=TD}) tw(wrS,0.25,{Scale=1}) end
	end)
end

local function addSec(p,o,key)
	local h=mk("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=o,ZIndex=903},p)
	local dot=mk("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.fromOffset(0,10),
		BackgroundColor3=AC,BorderSizePixel=0,Rotation=45,ZIndex=904},h)
	uc(dot,1)
	local lbl=mk("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,
		Font=Enum.Font.GothamSemibold,Text="",TextColor3=TX,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=904},h)
	regText(lbl,key)
	task.spawn(function()
		while G and G.Parent and dot and dot.Parent do
			tw(dot,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=ACH,Rotation=dot.Rotation+180})
			task.wait(2)
			if not (G and G.Parent and dot and dot.Parent) then break end
			tw(dot,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundColor3=AC,Rotation=dot.Rotation+180})
			task.wait(2)
		end
	end)
end

local allCards={}
local function addCard(p,o)
	local cd=mk("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=CD,BorderSizePixel=0,LayoutOrder=o,
		AutomaticSize=Enum.AutomaticSize.Y,ZIndex=903},p)
	uc(cd,10)
	local cs=sk(cd,BD,1,0.2)
	local cdS=mk("UIScale",{Scale=1},cd)
	mk("UIListLayout",{Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder},cd)
	mk("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},cd)
	cd.MouseEnter:Connect(function()
		tw(cd,0.25,{BackgroundColor3=Color3.fromRGB(27,27,33)})
		tw(cs,0.25,{Color=AC,Transparency=0.55})
		tw(cdS,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Scale=1.008})
	end)
	cd.MouseLeave:Connect(function()
		tw(cd,0.25,{BackgroundColor3=CD})
		tw(cs,0.25,{Color=BD,Transparency=0.2})
		tw(cdS,0.28,{Scale=1})
	end)
	table.insert(allCards,cd)
	return cd
end

local function addToggle(p,o,tkey,subkey,def,cb)
	local r=mk("TextButton",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=o,ZIndex=904},p)
	local tLbl=mk("TextLabel",{Size=UDim2.new(1,-90,0,20),Position=UDim2.fromOffset(14,subkey and 8 or 16),
		BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text="",TextColor3=TX,TextSize=14,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=905},r)
	regText(tLbl,tkey)
	if subkey then
		local sLbl=mk("TextLabel",{Size=UDim2.new(1,-90,0,14),Position=UDim2.fromOffset(14,27),BackgroundTransparency=1,
			Font=Enum.Font.Gotham,Text="",TextColor3=TD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=905},r)
		regText(sLbl,subkey)
	end
	local trk=mk("Frame",{Size=UDim2.fromOffset(38,22),Position=UDim2.new(1,-50,0.5,0),AnchorPoint=Vector2.new(0,0.5),
		BackgroundColor3=def and TO or TF,BorderSizePixel=0,ZIndex=905},r)
	uc(trk,100)
	local trkS=mk("UIScale",{Scale=1},trk)
	local ts=sk(trk,TO,1,0.5)
	local kn=mk("Frame",{Size=UDim2.fromOffset(18,18),
		Position=def and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
		BackgroundColor3=WT,BorderSizePixel=0,ZIndex=906},trk)
	uc(kn,100)
	local st={en=def or false}
	local function ap(e,sil)
		tw(trk,0.28,{BackgroundColor3=e and TO or TF})
		tw(ts,0.28,{Transparency=e and 0.2 or 0.5})
		tw(kn,TweenInfo.new(0.35,Enum.EasingStyle.Back),{Position=e and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
		if not sil and cb then cb(e) end
	end
	r.MouseEnter:Connect(function() if not st.en then tw(trk,0.25,{BackgroundColor3=Color3.fromRGB(65,65,75)}) end end)
	r.MouseLeave:Connect(function() if not st.en then tw(trk,0.25,{BackgroundColor3=TF}) end end)
	r.MouseButton1Click:Connect(function()
		st.en=not st.en ap(st.en)
		tw(trkS,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Scale=1.15})
		task.delay(0.2,function() tw(trkS,0.3,{Scale=1}) end)
	end)
	if def and cb then cb(true) end
	return st
end

local function addSlider(p,o,tkey,mn,mx,df,sfx,cb,isFloat)
	local r=mk("Frame",{Size=UDim2.new(1,0,0,66),BackgroundTransparency=1,LayoutOrder=o,ZIndex=904},p)
	local tLbl=mk("TextLabel",{Size=UDim2.new(1,-90,0,18),Position=UDim2.fromOffset(14,12),BackgroundTransparency=1,
		Font=Enum.Font.GothamSemibold,Text="",TextColor3=TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=905},r)
	regText(tLbl,tkey)
	local vL=mk("TextLabel",{Size=UDim2.new(0,90,0,18),Position=UDim2.new(1,-104,0,12),BackgroundTransparency=1,
		Font=Enum.Font.Gotham,Text=tostring(df)..(sfx or ""),TextColor3=TD,TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Right,ZIndex=905},r)
	local hd=mk("Frame",{Size=UDim2.new(1,-28,0,18),Position=UDim2.fromOffset(14,38),BackgroundTransparency=1,ZIndex=905},r)
	local tb=mk("Frame",{Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0.5,-2),BackgroundColor3=TK,BorderSizePixel=0,ZIndex=905},hd)
	uc(tb,100)
	local fl=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=AC,BorderSizePixel=0,ZIndex=906},tb)
	uc(fl,100)
	local kb=mk("Frame",{Size=UDim2.fromOffset(14,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),
		BackgroundColor3=WT,BorderSizePixel=0,ZIndex=907},tb)
	uc(kb,100)
	local hit=mk("TextButton",{Size=UDim2.new(1,20,1,20),Position=UDim2.fromOffset(-10,-10),
		BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=908},hd)
	local val=df local drg=false
	local function sv(v,sil)
		val=math.clamp(v,mn,mx)
		local a=(val-mn)/(mx-mn)
		tw(fl,0.1,{Size=UDim2.new(a,0,1,0)})
		tw(kb,0.15,{Position=UDim2.new(a,0,0.5,0)})
		if isFloat then vL.Text=string.format("%.2f",val)..(sfx or "") else vL.Text=tostring(math.floor(val+.5))..(sfx or "") end
		if not sil and cb then cb(val) end
	end
	local function fa(x)
		local rl=(x-hit.AbsolutePosition.X)/hit.AbsoluteSize.X rl=math.clamp(rl,0,1) sv(mn+rl*(mx-mn))
	end
	hit.InputBegan:Connect(function(x)
		if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
			drg=true fa(x.Position.X)
			tw(kb,0.2,{Size=UDim2.fromOffset(18,18)}) tw(fl,0.2,{BackgroundColor3=ACH})
		end
	end)
	U.InputChanged:Connect(function(x)
		if drg and (x.UserInputType==Enum.UserInputType.MouseMovement or x.UserInputType==Enum.UserInputType.Touch) then fa(x.Position.X) end
	end)
	U.InputEnded:Connect(function(x)
		if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
			if drg then drg=false tw(kb,0.25,{Size=UDim2.fromOffset(14,14)}) tw(fl,0.28,{BackgroundColor3=AC}) end
		end
	end)
	sv(df,true) if cb then cb(df) end
	return{set=sv,get=function() return val end}
end

local function addSelector(p,o,tkey,opts,disp,di,cb)
	local r=mk("TextButton",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=o,ZIndex=904},p)
	local tLbl=mk("TextLabel",{Size=UDim2.new(1,-140,0,20),Position=UDim2.fromOffset(14,16),BackgroundTransparency=1,
		Font=Enum.Font.GothamSemibold,Text="",TextColor3=TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=905},r)
	regText(tLbl,tkey)
	local bx=mk("Frame",{Size=UDim2.fromOffset(120,32),Position=UDim2.new(1,-134,0.5,0),AnchorPoint=Vector2.new(0,0.5),
		BackgroundColor3=Color3.fromRGB(30,30,36),BorderSizePixel=0,ZIndex=905},r)
	uc(bx,6) sk(bx,BD,1,0.2)
	local vL=mk("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,
		Font=Enum.Font.Gotham,Text=tostring(disp[di] or disp[1]),TextColor3=TX,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=906},bx)
	local ar=mk("TextLabel",{Size=UDim2.fromOffset(20,20),Position=UDim2.new(1,-22,0.5,-10),BackgroundTransparency=1,
		Font=Enum.Font.GothamBold,Text="v",TextColor3=TD,TextSize=12,ZIndex=906},bx)
	local i=di or 1
	local function ap(n,sil)
		i=((n-1)%#opts)+1
		vL.Text=tostring(disp[i])
		if not sil and cb then cb(opts[i],i) end
	end
	ap(i,true)
	r.MouseEnter:Connect(function() tw(bx,0.25,{BackgroundColor3=Color3.fromRGB(38,38,45)}) tw(ar,0.25,{TextColor3=AC}) end)
	r.MouseLeave:Connect(function() tw(bx,0.25,{BackgroundColor3=Color3.fromRGB(30,30,36)}) tw(ar,0.25,{TextColor3=TD}) end)
	r.MouseButton1Click:Connect(function()
		ap(i+1)
		tw(bx,0.12,{BackgroundColor3=Color3.fromRGB(0,130,165)})
		task.delay(0.12,function() tw(bx,0.28,{BackgroundColor3=Color3.fromRGB(30,30,36)}) end)
		tw(ar,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Rotation=180})
		task.delay(0.3,function() if ar.Parent then ar.Rotation=0 end end)
	end)
	return{get=function() return opts[i] end,set=function(n) ap(n) end}
end

local menuOpen=false
local function openMenu()
	if menuOpen then return end
	menuOpen=true
	MENU.Visible=true MENU.BackgroundTransparency=1 MSC.Scale=0.85
	tw(MENU,0.35,{BackgroundTransparency=0})
	tw(MSC,TweenInfo.new(0.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1})
	for i,cd in ipairs(allCards) do
		local s=cd:FindFirstChildOfClass("UIScale")
		cd.BackgroundTransparency=1 if s then s.Scale=0.94 end
		task.delay((i-1)*0.05,function()
			if cd and cd.Parent then
				tw(cd,0.5,{BackgroundTransparency=0})
				if s then tw(s,TweenInfo.new(0.55,Enum.EasingStyle.Back),{Scale=1}) end
			end
		end)
	end
end
local function closeMenu()
	if not menuOpen then return end
	menuOpen=false
	tw(MENU,0.3,{BackgroundTransparency=1})
	tw(MSC,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=0.9})
	task.delay(0.35,function() if not menuOpen then MENU.Visible=false end end)
end
CLB.MouseButton1Click:Connect(closeMenu)

local function refreshLang()
	for _,e in ipairs(textReg) do
		if e.lbl and e.lbl.Parent then e.lbl.Text=TR(e.key) end
	end
end

-- =========================================================
-- PILL
-- =========================================================
local PH=mk("Frame",{Name="PillHUD",Size=UDim2.fromOffset(250,40),Position=UDim2.new(0,-260,0,12),BackgroundTransparency=1,ZIndex=1000},G)
local PB=mk("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=PL,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=1000},PH)
uc(PB,10) sk(PB,Color3.fromRGB(35,35,45),1,0.1)
local PILogo=mk("ImageLabel",{Name="PILogo",Size=UDim2.fromOffset(28,28),Position=UDim2.fromOffset(10,6),
	BackgroundTransparency=1,Image=LOGO_ID,ImageColor3=WT,ScaleType=Enum.ScaleType.Fit,ZIndex=1002},PB)
local PILogoScale=mk("UIScale",{Scale=1},PILogo)
task.spawn(function()
	while G and G.Parent and PILogo and PILogo.Parent do
		tw(PILogo,2,{ImageColor3=Color3.fromRGB(210,250,255)})
		task.wait(2)
		if not (G and G.Parent and PILogo and PILogo.Parent) then break end
		tw(PILogo,2,{ImageColor3=WT})
		task.wait(2)
	end
end)
task.spawn(function()
	while G and G.Parent and PILogoScale and PILogoScale.Parent do
		tw(PILogoScale,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1.08})
		task.wait(2.2)
		if not (G and G.Parent and PILogoScale and PILogoScale.Parent) then break end
		tw(PILogoScale,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1})
		task.wait(2.2)
	end
end)
mk("TextLabel",{Size=UDim2.fromOffset(60,20),Position=UDim2.fromOffset(46,10),BackgroundTransparency=1,
	Font=Enum.Font.GothamBold,Text="finis",TextColor3=TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1002},PB)
mk("TextLabel",{Size=UDim2.fromOffset(10,20),Position=UDim2.fromOffset(90,10),BackgroundTransparency=1,
	Font=Enum.Font.Gotham,Text="|",TextColor3=TM,TextSize=13,ZIndex=1002},PB)
mk("TextLabel",{Size=UDim2.fromOffset(90,20),Position=UDim2.fromOffset(100,10),BackgroundTransparency=1,
	Font=Enum.Font.GothamMedium,Text="finishub.cc",TextColor3=TD,TextSize=13,
	TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1002},PB)
mk("TextLabel",{Size=UDim2.fromOffset(10,20),Position=UDim2.fromOffset(186,10),BackgroundTransparency=1,
	Font=Enum.Font.Gotham,Text="|",TextColor3=TM,TextSize=13,ZIndex=1002},PB)
mk("TextLabel",{Size=UDim2.fromOffset(60,20),Position=UDim2.fromOffset(196,10),BackgroundTransparency=1,
	Font=Enum.Font.GothamMedium,Text="internal",TextColor3=TD,TextSize=13,
	TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1002},PB)

local pDrag,pMoved=nil,false
PB.InputBegan:Connect(function(x)
	if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
		pDrag={sp=x.Position,st=PH.Position} pMoved=false
	end
end)
U.InputChanged:Connect(function(x)
	if not pDrag then return end
	if x.UserInputType==Enum.UserInputType.MouseMovement or x.UserInputType==Enum.UserInputType.Touch then
		local d=x.Position-pDrag.sp
		if math.abs(d.X)+math.abs(d.Y)>12 then pMoved=true end
		if pMoved then PH.Position=UDim2.new(pDrag.st.X.Scale,pDrag.st.X.Offset+d.X,pDrag.st.Y.Scale,pDrag.st.Y.Offset+d.Y) end
	end
end)
U.InputEnded:Connect(function(x)
	if not pDrag then return end
	if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
		local tap=not pMoved pDrag=nil
		if tap and introDone then
			if menuOpen then closeMenu() else openMenu() end
		end
	end
end)
PB.MouseEnter:Connect(function() tw(PB,0.25,{BackgroundColor3=Color3.fromRGB(24,24,30)}) end)
PB.MouseLeave:Connect(function() tw(PB,0.25,{BackgroundColor3=PL}) end)
task.spawn(function()
	while not introDone do task.wait(0.2) end
	PH.Position=UDim2.new(0,-260,0,12) PB.BackgroundTransparency=1
	tw(PH,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,12,0,12)})
	tw(PB,0.6,{BackgroundTransparency=0})
	task.wait(0.85)
	openMenu()
end)

-- =========================================================
-- ESP v3 — с правильным масштабированием (fixed)
-- =========================================================
local ESP_STYLES={"Chams","Outline","Both","Skeleton","Corners","Box","All"}
local ESP_COLORS={
	Pink=Color3.fromRGB(255,150,230),Red=Color3.fromRGB(255,80,80),Blue=Color3.fromRGB(100,170,255),
	Green=Color3.fromRGB(90,220,130),Purple=Color3.fromRGB(180,120,255),Yellow=Color3.fromRGB(255,220,90),
	Cyan=Color3.fromRGB(0,220,240),White=Color3.fromRGB(255,255,255),Black=Color3.fromRGB(15,15,18)}
local function ec() return ESP_COLORS[CB.espCol] or ESP_COLORS.Pink end

local espCache={}
local function cleanupE(e)
	if not e then return end
	for _,k in ipairs({"hlInner","hlOuter","corners","skeleton","text","box"}) do
		if e[k] then pcall(function() e[k]:Destroy() end) e[k]=nil end
	end
end

-- Двойной Highlight для премиум cham'а (тело + тонкая обводка)
local function ensureHL(ch)
	local e=espCache[ch]
	if e and e.hlInner and e.hlInner.Parent==ch then return e end
	if e and e.hlInner then pcall(function() e.hlInner:Destroy() end) end
	if e and e.hlOuter then pcall(function() e.hlOuter:Destroy() end) end
	local inner=Instance.new("Highlight")
	inner.Name="FinisHLInner" inner.Adornee=ch inner.Parent=ch
	local outer=Instance.new("Highlight")
	outer.Name="FinisHLOuter" outer.Adornee=ch outer.Parent=ch
	if not e then e={} espCache[ch]=e end
	e.hlInner=inner e.hlOuter=outer
	return e
end

-- УГЛОВЫЕ СКОБКИ (правильный размер через StudsOffsetWorldSpace + AlwaysOnTop)
-- Важно: используем Adornee=HRP и фиксированный Offset, а не WorldSpace (иначе тянется при отдалении)
local function makeCorner(par,name,h,w)
	local f=mk("Frame",{Name=name,Size=UDim2.fromOffset(w,h),BackgroundColor3=WT,BorderSizePixel=0,Parent=par})
	return f
end

local function ensureCorners(ch)
	local e=espCache[ch]
	if e and e.corners and e.corners.Parent then return e.corners end
	if e and e.corners then pcall(function() e.corners:Destroy() end) end
	local hrp=ch:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local bg=Instance.new("BillboardGui")
	bg.Name="FinisCorners"
	bg.Size=UDim2.new(0,80,0,110)
	bg.StudsOffsetWorldSpace=Vector3.new(0,0,0)
	bg.Adornee=hrp
	bg.AlwaysOnTop=true
	bg.LightInfluence=0
	bg.ResetOnSpawn=false
	-- важно: не тянется при отдалении
	bg.SizeOffset=Vector2.new(0,0)
	bg.Parent=ch
	local t=2 local l=12
	local tlh=makeCorner(bg,"TLh",t,l) tlh.AnchorPoint=Vector2.new(0,0) tlh.Position=UDim2.new(0,0,0,0)
	local tlv=makeCorner(bg,"TLv",l,t) tlv.AnchorPoint=Vector2.new(0,0) tlv.Position=UDim2.new(0,0,0,0)
	local trh=makeCorner(bg,"TRh",t,l) trh.AnchorPoint=Vector2.new(1,0) trh.Position=UDim2.new(1,0,0,0)
	local trv=makeCorner(bg,"TRv",l,t) trv.AnchorPoint=Vector2.new(1,0) trv.Position=UDim2.new(1,0,0,0)
	local blh=makeCorner(bg,"BLh",t,l) blh.AnchorPoint=Vector2.new(0,1) blh.Position=UDim2.new(0,0,1,0)
	local blv=makeCorner(bg,"BLv",l,t) blv.AnchorPoint=Vector2.new(0,1) blv.Position=UDim2.new(0,0,1,0)
	local brh=makeCorner(bg,"BRh",t,l) brh.AnchorPoint=Vector2.new(1,1) brh.Position=UDim2.new(1,0,1,0)
	local brv=makeCorner(bg,"BRv",l,t) brv.AnchorPoint=Vector2.new(1,1) brv.Position=UDim2.new(1,0,1,0)
	if not e then e={} espCache[ch]=e end
	e.corners=bg return bg
end

local SKELETON_CONN={
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
	{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},
	{"LowerTorso","RightUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"}}
local LEGACY_CONN={
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function ensureSkel(ch)
	local e=espCache[ch]
	if e and e.skeleton and e.skeleton.Parent then return e.skeleton end
	if e and e.skeleton then pcall(function() e.skeleton:Destroy() end) end
	local ad=ch:FindFirstChild("HumanoidRootPart")
	if not ad then return nil end
	local gui=Instance.new("BillboardGui")
	gui.Name="FinisSkeleton" gui.Size=UDim2.new(0,200,0,200) gui.AlwaysOnTop=true
	gui.LightInfluence=0 gui.Adornee=ad gui.StudsOffsetWorldSpace=Vector3.new(0,0,0)
	gui.ResetOnSpawn=false gui.Parent=ch
	local fr={}
	for i=1,10 do
		local f=Instance.new("Frame")
		f.Name="Bone"..i f.BackgroundColor3=OL f.BorderSizePixel=0
		f.AnchorPoint=Vector2.new(0.5,0.5) f.Parent=gui
		table.insert(fr,f)
	end
	if not e then e={} espCache[ch]=e end
	e.skeleton=gui e.skeletonBones=fr return gui
end

local function ensureBox(ch)
	local e=espCache[ch]
	if e and e.box and e.box.Parent then return e.box end
	if e and e.box then pcall(function() e.box:Destroy() end) end
	local hrp=ch:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local gui=Instance.new("BillboardGui")
	gui.Name="FinisBox" gui.Size=UDim2.new(0,70,0,100) gui.AlwaysOnTop=true
	gui.LightInfluence=0 gui.Adornee=hrp gui.StudsOffsetWorldSpace=Vector3.new(0,0,0)
	gui.ResetOnSpawn=false gui.Parent=ch
	local function ln(n,sz,pos)
		local f=Instance.new("Frame")
		f.Name=n f.Size=sz f.Position=pos f.BackgroundColor3=OL f.BorderSizePixel=0 f.Parent=gui
		return f
	end
	local t=ln("T",UDim2.new(1,0,0,1.5),UDim2.new(0,0,0,0))
	local b=ln("B",UDim2.new(1,0,0,1.5),UDim2.new(0,0,1,-1.5))
	local l=ln("L",UDim2.new(0,1.5,1,0),UDim2.new(0,0,0,0))
	local r=ln("R",UDim2.new(0,1.5,1,0),UDim2.new(1,-1.5,0,0))
	if not e then e={} espCache[ch]=e end
	e.box=gui e.boxLines={t,b,l,r} return gui
end

local function ensureText(ch,plr)
	local e=espCache[ch]
	local head=ch:FindFirstChild("Head")
	if not head then return nil end
	if e and e.text and e.text.Parent==head then return e.text end
	if e and e.text then pcall(function() e.text:Destroy() end) end
	local bg=Instance.new("BillboardGui")
	bg.Name="FinisTxt" bg.Size=UDim2.new(0,220,0,34)
	bg.StudsOffset=Vector3.new(0,3.1,0) bg.AlwaysOnTop=true bg.LightInfluence=0 bg.Parent=head
	local n=Instance.new("TextLabel")
	n.Name="N" n.Size=UDim2.new(1,0,0,18) n.BackgroundTransparency=1
	n.Font=Enum.Font.GothamBold n.TextSize=13 n.TextColor3=WT
	n.TextStrokeTransparency=0.2 n.TextStrokeColor3=Color3.fromRGB(0,0,0) n.Text=plr.Name n.Parent=bg
	local d=Instance.new("TextLabel")
	d.Name="D" d.Size=UDim2.new(1,0,0,14) d.Position=UDim2.new(0,0,0,18) d.BackgroundTransparency=1
	d.Font=Enum.Font.GothamMedium d.TextSize=11 d.TextColor3=Color3.fromRGB(220,220,220)
	d.TextStrokeTransparency=0.3 d.TextStrokeColor3=Color3.fromRGB(0,0,0) d.Text="" d.Parent=bg
	if not e then e={} espCache[ch]=e end
	e.text=bg return bg
end

local function renderBone(frame,p1,p2,gui,camera,col)
	local s1,on1=camera:WorldToViewportPoint(p1)
	local s2,on2=camera:WorldToViewportPoint(p2)
	if not (on1 and on2) or s1.Z<=0 or s2.Z<=0 then frame.Visible=false return end
	local abs=gui.AbsolutePosition
	local v1=Vector2.new(s1.X-abs.X,s1.Y-abs.Y)
	local v2=Vector2.new(s2.X-abs.X,s2.Y-abs.Y)
	local diff=v2-v1
	local len=diff.Magnitude
	if len<1 then frame.Visible=false return end
	local ang=math.deg(math.atan2(diff.Y,diff.X))
	local cen=(v1+v2)*0.5
	frame.Visible=true frame.Size=UDim2.fromOffset(len,2)
	frame.Position=UDim2.fromOffset(cen.X,cen.Y) frame.Rotation=ang
	frame.BackgroundColor3=col
end

local function updateTarget(plr,ch)
	local e=espCache[ch]
	if not e then e={} espCache[ch]=e end
	local col=ec() local style=CB.espStyle
	local hrp=ch:FindFirstChild("HumanoidRootPart")
	local hum=ch:FindFirstChildOfClass("Humanoid")
	local vis=CB.esp and hrp and hum and hum.Health>0

	-- Highlight (Chams / Outline / Both / All)
	if vis and (style=="Chams" or style=="Outline" or style=="Both" or style=="All") then
		local en=ensureHL(ch)
		if en then
			local inner=en.hlInner
			local outer=en.hlOuter
			if inner and outer then
				inner.Enabled=true inner.Adornee=ch
				outer.Enabled=true outer.Adornee=ch
				local depth=CB.espWall and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
				inner.DepthMode=depth outer.DepthMode=depth
				if style=="Chams" then
					inner.FillTransparency=0.25 inner.FillColor=col
					inner.OutlineTransparency=1
					outer.FillTransparency=1 outer.OutlineTransparency=0
					outer.OutlineColor=col:Lerp(OL,0.4)
				elseif style=="Outline" then
					inner.FillTransparency=1 inner.OutlineTransparency=0
					inner.OutlineColor=col:Lerp(OL,0.3)
					outer.FillTransparency=1 outer.OutlineTransparency=1
				else
					inner.FillTransparency=0.45 inner.FillColor=col
					inner.OutlineTransparency=1
					outer.FillTransparency=1 outer.OutlineTransparency=0
					outer.OutlineColor=col:Lerp(OL,0.5)
				end
			end
		end
	elseif e.hlInner then
		e.hlInner.Enabled=false
		if e.hlOuter then e.hlOuter.Enabled=false end
	end

	-- Corners
	if vis and (style=="Corners" or style=="All") then
		local bg=ensureCorners(ch)
		if bg then
			bg.Enabled=true
			for _,f in ipairs(bg:GetDescendants()) do
				if f:IsA("Frame") then f.BackgroundColor3=col:Lerp(OL,0.5) end
			end
		end
	elseif e.corners then e.corners.Enabled=false end

	-- Skeleton
	if vis and (style=="Skeleton" or style=="All") then
		local gui=ensureSkel(ch)
		if gui then
			gui.Enabled=true
			local scol=col:Lerp(OL,0.6)
			local isR15=ch:FindFirstChild("UpperTorso")~=nil
			local conns=isR15 and SKELETON_CONN or LEGACY_CONN
			for i,f in ipairs(e.skeletonBones or {}) do
				local c=conns[i]
				if c then
					local p1=ch:FindFirstChild(c[1])
					local p2=ch:FindFirstChild(c[2])
					if p1 and p2 then renderBone(f,p1.Position,p2.Position,gui,cam(),scol)
					else f.Visible=false end
				else f.Visible=false end
			end
		end
	elseif e.skeleton then e.skeleton.Enabled=false end

	-- Box
	if vis and (style=="Box" or style=="All") then
		local bg=ensureBox(ch)
		if bg then
			bg.Enabled=true
			if e.boxLines then
				for _,l in ipairs(e.boxLines) do l.BackgroundColor3=col:Lerp(OL,0.5) end
			end
		end
	elseif e.box then e.box.Enabled=false end

	-- Text
	if CB.espText and vis then
		local bg=ensureText(ch,plr)
		if bg then
			bg.Enabled=true
			local n=bg:FindFirstChild("N")
			local d=bg:FindFirstChild("D")
			local myH=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			local dist=0
			if myH and hrp then dist=math.floor((myH.Position-hrp.Position).Magnitude) end
			if n then n.TextColor3=col:Lerp(OL,0.3) end
			if d then d.Text=dist.." studs" end
		end
	elseif e.text then e.text.Enabled=false end
end

task.spawn(function()
	while G and G.Parent do
		for _,p in ipairs(P:GetPlayers()) do
			if p~=LP and isEnemy(p) then
				local ch=p.Character
				if ch then pcall(updateTarget,p,ch) end
			end
		end
		for ch,_ in pairs(espCache) do
			if not ch.Parent then pcall(cleanupE,espCache[ch]) espCache[ch]=nil end
		end
		task.wait(0.05)
	end
end)

-- =========================================================
-- TRIANGLE ARROWS — держатся вокруг FOV радиуса
-- =========================================================
local arrHolder=nil local arrows={}
local function ensureArrHolder()
	if arrHolder and arrHolder.Parent then return arrHolder end
	arrHolder=mk("Frame",{Name="FinisArrows",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
		BorderSizePixel=0,ZIndex=3},G)
	return arrHolder
end

-- треугольник собирается из 2 линий развёрнутых под ±45° (уголок >)
local function makeTriangle(parent,size,col)
	local line1=mk("Frame",{Name="L1",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromOffset(size*0.15,size*0.5),
		Size=UDim2.fromOffset(size,2),BackgroundColor3=col,BorderSizePixel=0,Rotation=45,Parent=parent})
	uc(line1,1)
	local line2=mk("Frame",{Name="L2",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.fromOffset(size*0.15,size*0.5),
		Size=UDim2.fromOffset(size,2),BackgroundColor3=col,BorderSizePixel=0,Rotation=-45,Parent=parent})
	uc(line2,1)
	return line1,line2
end

local function getArrow(i)
	if arrows[i] and arrows[i].Parent then return arrows[i] end
	local bg=mk("Frame",{Name="Arr"..i,AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(0,0),
		BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4},ensureArrHolder())
	local holder=mk("Frame",{Name="Holder",Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,BorderSizePixel=0,Parent=bg})
	uc(holder,0)
	local l1,l2=makeTriangle(holder,10,WT)
	local sc=mk("UIScale",{Scale=0},bg)
	arrows[i]={bg=bg,holder=holder,l1=l1,l2=l2,sc=sc}
	return bg
end

-- обновление стрелок (вокруг FOV радиуса)
local function updateArrows()
	local c=cam()
	if not c then return end
	local vp=c.ViewportSize
	local center=Vector2.new(vp.X*0.5,vp.Y*0.5)
	-- радиус = FOV стрелка привязана к размеру FOV
	local baseRad=math.min(vp.X,vp.Y)*0.36
	if baseRad<100 then baseRad=100 end
	local fovRad = (CB.tb and CB.tbFov or 140) * 0.5
	local rad = fovRad + 60
	if rad > baseRad*1.4 then rad = baseRad*1.4 end

	local off={}
	if CB.esp then
		for _,p in ipairs(P:GetPlayers()) do
			if p~=LP and isEnemy(p) then
				local ch=p.Character
				if ch then
					local hd=ch:FindFirstChild("Head")
					if hd then
						local sp,on=c:WorldToViewportPoint(hd.Position)
						if not on or sp.Z<=0 then
							local wd=hd.Position-c.CFrame.Position
							local cd=c.CFrame:VectorToObjectSpace(wd)
							local dr=Vector2.new(cd.X,-cd.Y)
							if dr.Magnitude<0.001 then dr=Vector2.new(0,-1) end
							dr=dr.Unit
							table.insert(off,{p=p,dir=dr,pos=hd.Position})
						end
					end
				end
			end
		end
		table.sort(off,function(a,b)
			return (a.pos-c.CFrame.Position).Magnitude<(b.pos-c.CFrame.Position).Magnitude
		end)
	end
	for i=1,12 do
		local entry=arrows[i]
		if not entry then getArrow(i) entry=arrows[i] end
		if entry and entry.bg then
			local a=entry.bg
			local dt=off[i]
			if dt and CB.esp then
				local pos=center+dt.dir*rad
				local rot=math.deg(math.atan2(dt.dir.Y,dt.dir.X))
				tw(a,0.3,{Position=UDim2.fromOffset(pos.X,pos.Y)})
				tw(entry.holder,0.3,{Rotation=rot})
				local col=ec()
				entry.l1.BackgroundColor3=col
				entry.l2.BackgroundColor3=col
				if entry.sc.Scale<0.9 then tw(entry.sc,0.4,{Scale=1}) end
				if a.Size.X.Offset<10 then tw(a,0.4,{Size=UDim2.fromOffset(16,16)}) end
			else
				if entry.sc.Scale>0.05 then tw(entry.sc,0.35,{Scale=0}) end
			end
		end
	end
end
task.spawn(function()
	while G and G.Parent do
		pcall(updateArrows)
		task.wait(0.06)
	end
end)

-- =========================================================
-- KILL FEED / DAMAGE (уведомления)
-- =========================================================
local KF=mk("Frame",{Name="KillFeed",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,140),
	Size=UDim2.fromOffset(280,200),BackgroundTransparency=1,ZIndex=1050},G)
mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Right},KF)

local kfOrder=0
local function addKillMsg(text,col)
	if not CB.killMsg then return end
	kfOrder = kfOrder + 1
	local row=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(20,20,26),
		BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-kfOrder,ZIndex=1051},KF)
	uc(row,8)
	local rowS=sk(row,BD,1,0.4)
	local accent=mk("Frame",{Size=UDim2.fromOffset(3,18),Position=UDim2.fromOffset(6,6),
		BackgroundColor3=col,BorderSizePixel=0,ZIndex=1052},row)
	uc(accent,2)
	local lbl=mk("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(16,0),
		BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,Text=text,TextColor3=col,
		TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1052},row)
	local sc=mk("UIScale",{Scale=0.8},row)
	tw(row,0.35,{BackgroundTransparency=0}) tw(sc,TweenInfo.new(0.5,Enum.EasingStyle.Back),{Scale=1})
	task.delay(3,function()
		tw(row,0.4,{BackgroundTransparency=1}) tw(sc,0.4,{Scale=0.8})
		task.wait(0.5)
		if row.Parent then row:Destroy() end
	end)
end

-- Отслеживание урона и убийств
local lastHp={}
task.spawn(function()
	while G and G.Parent do
		for _,p in ipairs(P:GetPlayers()) do
			if p~=LP then
				local ch=p.Character
				if ch then
					local hum=ch:FindFirstChildOfClass("Humanoid")
					if hum then
						local prev=lastHp[p]
						if prev and hum.Health < prev then
							local dmg=math.floor(prev - hum.Health)
							if dmg>0 then
								-- считаем что мы нанесли урон если стреляли недавно
								if os.clock()-lastShotTime < 1.5 then
									if hum.Health<=0 and CB.killMsg then
										addKillMsg("You killed "..p.Name, GRN)
									elseif CB.dmgMsg and dmg>0 then
										addKillMsg("-"..dmg.." to "..p.Name, RED)
									end
								end
							end
						end
						lastHp[p]=hum.Health
					end
				end
			end
		end
		task.wait(0.08)
	end
end)

-- =========================================================
-- FOV CIRCLE — с анимацией
-- =========================================================
local FOV=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(400,400),
	BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=2},G)
uc(FOV,5000)
local FOVSt=sk(FOV,WT,1.5,0.4)
local FOVScale=mk("UIScale",{Scale=1},FOV)
task.spawn(function()
	while G and G.Parent and FOV and FOV.Parent do
		if FOV.Visible then
			tw(FOVSt,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.7,Thickness=1})
			tw(FOVScale,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1.01})
			task.wait(1.2)
			if not (G and G.Parent and FOV and FOV.Parent) then break end
			tw(FOVSt,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.25,Thickness=1.8})
			tw(FOVScale,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1})
			task.wait(1.2)
		else
			task.wait(0.5)
		end
	end
end)

local lastShotTime=0
local function getAny(fv)
	local c=cam()
	if not c then return nil end
	local vp=c.ViewportSize
	local cn=Vector2.new(vp.X*0.5,vp.Y*0.5)
	local bs,bd=nil,fv
	for _,p in ipairs(P:GetPlayers()) do
		if isEnemy(p) then
			local ch=p.Character
			if ch then
				local hd=ch:FindFirstChild("Head")
				local rt=ch:FindFirstChild("HumanoidRootPart")
				local h=ch:FindFirstChildOfClass("Humanoid")
				if hd and rt and h and h.Health>0 then
					local sp,on=c:WorldToViewportPoint(rt.Position)
					if on and sp.Z>0 then
						local d=(Vector2.new(sp.X,sp.Y)-cn).Magnitude
						if d<bd then bd=d bs={h=hd,r=rt,ch=ch} end
					end
				end
			end
		end
	end
	return bs
end

R.Heartbeat:Connect(function()
	local ch=LP.Character
	if not ch then return end
	local h=ch:FindFirstChildOfClass("Humanoid")
	if not h or h.Health<=0 then return end
	if CB.tb then
		local t=getAny(CB.tbFov)
		if t and t.h then
			local c=cam()
			if c then
				local lk=CFrame.lookAt(c.CFrame.Position,t.h.Position)
				c.CFrame=c.CFrame:Lerp(lk,0.5)
			end
			local tool=ch:FindFirstChildOfClass("Tool")
			local n=os.clock()
			if tool and n-lastF>=CB.tbDel then
				lastF=n
				lastShotTime=os.clock()
				pcall(function() tool:Activate() end)
			end
		end
	end
end)
R.RenderStepped:Connect(function()
	local a,r=false,0
	if CB.tb then a=true r=math.max(r,CB.tbFov) end
	local wasVisible=FOV.Visible
	FOV.Visible=a and CB.showFov
	if r>0 then FOV.Size=UDim2.fromOffset(r*2,r*2) end
end)

-- =========================================================
-- GAME FUNCTIONS
-- =========================================================
local function forceNoclip()
	local ch=LP.Character
	if not ch or not ch.Parent then return end
	for _,d in ipairs(ch:GetDescendants()) do
		if d:IsA("BasePart") and d.CanCollide then d.CanCollide=false end
	end
end
R.Stepped:Connect(function() if CB.noclip then pcall(forceNoclip) end end)
R.Heartbeat:Connect(function() if CB.noclip then pcall(forceNoclip) end end)
R.RenderStepped:Connect(function() if CB.noclip then pcall(forceNoclip) end end)
local function watchPart(p)
	if not p:IsA("BasePart") then return end
	p:GetPropertyChangedSignal("CanCollide"):Connect(function()
		if CB.noclip and p.CanCollide then p.CanCollide=false end
	end)
end
local function installWatchers(ch)
	if not ch then return end
	for _,d in ipairs(ch:GetDescendants()) do watchPart(d) end
	ch.DescendantAdded:Connect(watchPart)
end
if LP.Character then installWatchers(LP.Character) end
LP.CharacterAdded:Connect(function(ch) task.wait(0.25) installWatchers(ch) end)

local spA=0
R.RenderStepped:Connect(function(dt)
	if not CB.spin then return end
	local ch=LP.Character
	if not ch then return end
	local hr=ch:FindFirstChild("HumanoidRootPart")
	local h=ch:FindFirstChildOfClass("Humanoid")
	if not hr or not h or h.Health<=0 then return end
	if h.AutoRotate then h.AutoRotate=false end
	spA=spA+dt*math.rad(CB.spinSpd)
	if spA>math.pi*2 then spA=spA-math.pi*2 end
	hr.CFrame=CFrame.new(hr.Position)*CFrame.Angles(0,spA,0)
end)

-- FLY v4 — медленнее, безопаснее для Hyperion
local Controls=nil
task.spawn(function()
	local t0=os.clock()
	while os.clock()-t0<5 do
		local ok,res=pcall(function()
			local pm=LP:FindFirstChild("PlayerScripts")
			pm=pm and pm:FindFirstChild("PlayerModule")
			if not pm then return nil end
			return (require(pm)):GetControls()
		end)
		if ok and res then Controls=res break end
		task.wait(0.2)
	end
	if Controls then print("[Finis] controls OK") else warn("[Finis] controls FAILED") end
end)

local FS={bv=nil,bg=nil}
local function startFly()
	local ch=LP.Character
	local hr=ch and ch:FindFirstChild("HumanoidRootPart")
	local h=ch and ch:FindFirstChildOfClass("Humanoid")
	if not hr or not h or FS.bv then return end
	-- Мягкие параметры для обхода Hyperion
	local bv=Instance.new("BodyVelocity")
	bv.Name="FinisFlyBV"
	bv.MaxForce=Vector3.new(5e4,5e4,5e4)  -- НЕ 1e9
	bv.P=1e4                              -- средняя жёсткость
	bv.Velocity=Vector3.new(0,0,0)
	bv.Parent=hr
	local bg=Instance.new("BodyGyro")
	bg.Name="FinisFlyBG"
	bg.MaxTorque=Vector3.new(5e5,5e5,5e5)
	bg.P=5e3
	bg.D=500
	bg.CFrame=hr.CFrame
	bg.Parent=hr
	h.PlatformStand=true
	FS.bv=bv FS.bg=bg
end
local function stopFly()
	if FS.bv then FS.bv:Destroy() FS.bv=nil end
	if FS.bg then FS.bg:Destroy() FS.bg=nil end
	local ch=LP.Character
	local h=ch and ch:FindFirstChildOfClass("Humanoid")
	if h then h.PlatformStand=false end
end
local function getMoveInput()
	local mx,mz=0,0
	if Controls then
		local ok,res=pcall(function() return Controls:GetMoveVector() end)
		if ok and res then mx=res.X mz=res.Z end
	end
	if mx==0 and mz==0 then
		local kb=U:GetKeysPressed()
		for _,k in ipairs(kb) do
			if k.KeyCode==Enum.KeyCode.W then mz=math.min(mz-1,0) end
			if k.KeyCode==Enum.KeyCode.S then mz=math.max(mz+1,0) end
			if k.KeyCode==Enum.KeyCode.A then mx=math.min(mx-1,0) end
			if k.KeyCode==Enum.KeyCode.D then mx=math.max(mx+1,0) end
		end
	end
	return math.clamp(mx,-1,1),math.clamp(mz,-1,1)
end
R.Heartbeat:Connect(function()
	if not CB.fly then if FS.bv then stopFly() end return end
	if not FS.bv then startFly() end
	local ch=LP.Character
	local h=ch and ch:FindFirstChildOfClass("Humanoid")
	local rt=ch and ch:FindFirstChild("HumanoidRootPart")
	if not h or not rt or not FS.bv then return end
	local mx,mz=getMoveInput()
	local c=cam()
	if not c then return end
	local look=c.CFrame.LookVector
	local right=c.CFrame.RightVector
	local fwd=Vector3.new(look.X,0,look.Z)
	if fwd.Magnitude>0.001 then fwd=fwd.Unit else fwd=Vector3.new(0,0,-1) end
	local rst=Vector3.new(right.X,0,right.Z)
	if rst.Magnitude>0.001 then rst=rst.Unit else rst=Vector3.new(1,0,0) end
	local dir=Vector3.new(0,0,0)
	if CB.flyMode=="Vertical" then
		if mz<-0.1 then dir=dir+Vector3.new(0,1,0) end
		if mz>0.1 then dir=dir-Vector3.new(0,1,0) end
		if mx>0.1 then dir=dir+rst end
		if mx<-0.1 then dir=dir-rst end
	else dir=fwd*(-mz)+rst*mx end
	if dir.Magnitude>0.01 then dir=dir.Unit*CB.flySpd end
	-- Плавное изменение скорости (НЕ рывками) — чтобы не палево
	local cur=FS.bv.Velocity
	local target=dir
	FS.bv.Velocity = cur:Lerp(target, 0.3)
	FS.bg.CFrame=CFrame.new(rt.Position,rt.Position+look)
end)

U.JumpRequest:Connect(function()
	if not CB.air then return end
	local ch=LP.Character
	if not ch then return end
	local h=ch:FindFirstChildOfClass("Humanoid")
	if not h then return end
	local s=h:GetState()
	if s==Enum.HumanoidStateType.Jumping or s==Enum.HumanoidStateType.Freefall then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function getCurrentCar()
	local ch=LP.Character
	if not ch then return nil end
	local hm=ch:FindFirstChildOfClass("Humanoid")
	if not hm then return nil end
	local seat=hm.SeatPart
	if seat and seat:IsA("BasePart") then return seat end
end
task.spawn(function()
	while G and G.Parent do
		if CB.carHack then
			local seat=getCurrentCar()
			if seat and seat:IsA("VehicleSeat") then
				pcall(function()
					if seat.MaxSpeed~=CB.carSpd then seat.MaxSpeed=CB.carSpd end
					if seat.Torque~=CB.carSpd*10 then seat.Torque=CB.carSpd*10 end
				end)
			end
		end
		task.wait(0.15)
	end
end)

local TRC=Instance.new("Folder")
TRC.Name="FinisTracers" TRC.Parent=W
local lastT=0
local function getMuzzle()
	local ch=LP.Character
	if not ch then return nil end
	local t=ch:FindFirstChildOfClass("Tool")
	if t then local h=t:FindFirstChild("Handle") if h then return h.Position end end
	local hd=ch:FindFirstChild("Head")
	return hd and hd.Position or nil
end
local function drawTracer(f,to)
	if not CB.tracer or not f or not to then return end
	if os.clock()-lastT<0.05 then return end
	lastT=os.clock()
	local d=(to-f).Magnitude
	if d<1.5 then return end
	local part=Instance.new("Part")
	part.Anchored=true part.CanCollide=false part.CanQuery=false part.CastShadow=false
	part.Material=Enum.Material.Neon part.Color=Color3.fromRGB(255,245,120)
	part.Size=Vector3.new(0.12,0.12,d) part.CFrame=CFrame.new((f+to)*0.5,to) part.Transparency=0.1 part.Parent=TRC
	tw(part,0.5,{Transparency=1})
	task.delay(0.55,function() if part and part.Parent then part:Destroy() end end)
end

local lastSw=0
local function fastSwitchWeapon()
	if not CB.fastSwitch then return end
	if os.clock()-lastSw<CB.fsDelay then return end
	lastSw=os.clock()
	local ch=LP.Character
	if not ch then return end
	local current=ch:FindFirstChildOfClass("Tool")
	local bp=LP:FindFirstChild("Backpack")
	if not bp then return end
	local tools={}
	for _,t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") and (not current or t.Name~=current.Name) then table.insert(tools,t) end
	end
	if #tools==0 then return end
	local nx=tools[math.random(1,#tools)]
	pcall(function()
		if current then current.Parent=bp end
		nx.Parent=ch
	end)
end

local function hookT(t)
	if not t:IsA("Tool") then return end
	if t:GetAttribute("FH") then return end
	t:SetAttribute("FH",true)
	t.Activated:Connect(function()
		lastShotTime=os.clock()
		if CB.tracer then
			local f=getMuzzle()
			if f then task.spawn(function() drawTracer(f,LP:GetMouse().Hit.Position) end) end
		end
		if CB.fastSwitch then task.delay(CB.fsDelay,function() pcall(fastSwitchWeapon) end) end
	end)
end
local function installTools(ch)
	if not ch then return end
	for _,c in ipairs(ch:GetDescendants()) do
		if c:IsA("Tool") then hookT(c) end
	end
	ch.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then task.wait(0.05) hookT(c) end
	end)
end
if LP.Character then installTools(LP.Character) end
LP.CharacterAdded:Connect(function(ch) task.wait(0.3) installTools(ch) end)
local function hookBP(bp)
	if not bp then return end
	for _,c in ipairs(bp:GetChildren()) do
		if c:IsA("Tool") then hookT(c) end
	end
	bp.ChildAdded:Connect(function(c)
		if c:IsA("Tool") then task.wait(0.05) hookT(c) end
	end)
end
hookBP(LP:FindFirstChild("Backpack"))
LP.ChildAdded:Connect(function(c) if c.Name=="Backpack" then hookBP(c) end end)

R.Heartbeat:Connect(function()
	if not CB.maxSpd then return end
	local ch=LP.Character
	local h=ch and ch:FindFirstChildOfClass("Humanoid")
	if not h then return end
	local t=CB.msVal
	local cr=h.WalkSpeed
	if math.abs(cr-t)>0.5 then
		local s=math.clamp(t-cr,-0.5,0.5)
		h.WalkSpeed=cr+s
	end
end)

task.spawn(function()
	while G and G.Parent do
		local ch=LP.Character
		if ch then
			for _,t in ipairs(ch:GetChildren()) do
				if t:IsA("Tool") then
					if CB.ammo then
						for k,v in pairs(t:GetAttributes()) do
							if typeof(v)=="number" and v<999 then
								local l=string.lower(k)
								if l:find("ammo") or l:find("clip") or l:find("mag") then
									pcall(function() t:SetAttribute(k,999) end)
								end
							end
						end
					end
					if CB.noreload then
						for k,v in pairs(t:GetAttributes()) do
							local l=string.lower(k)
							if l:find("reload") then
								if typeof(v)=="boolean" and v then
									pcall(function() t:SetAttribute(k,false) end)
								elseif typeof(v)=="number" and v>0 then
									pcall(function() t:SetAttribute(k,0) end)
								end
							end
						end
					end
				end
			end
		end
		task.wait(0.15)
	end
end)

-- =========================================================
-- PAGES
-- =========================================================
do
	local p=NP.Visuals
	addSec(p,1,"sec_esp")
	local c=addCard(p,2)
	addToggle(c,1,"esp_en","",false,function(o) CB.esp=o end)
	addToggle(c,2,"esp_wall","",true,function(o) CB.espWall=o end)
	addToggle(c,3,"esp_txt","",true,function(o) CB.espText=o end)
	addSelector(c,4,"esp_col",{"Pink","Red","Blue","Green","Purple","Yellow","Cyan","White"},
		{"Pink","Red","Blue","Green","Purple","Yellow","Cyan","White"},1,function(v) CB.espCol=v end)
	addSelector(c,5,"esp_style",ESP_STYLES,ESP_STYLES,1,function(v) CB.espStyle=v end)

	addSec(p,3,"sec_tracer")
	local c2=addCard(p,4)
	addToggle(c2,1,"tr_en","",false,function(o) CB.tracer=o end)

	addSec(p,5,"sec_kill")
	local c3=addCard(p,6)
	addToggle(c3,1,"kf_kill","",true,function(o) CB.killMsg=o end)
	addToggle(c3,2,"kf_dmg","",true,function(o) CB.dmgMsg=o end)
end

do
	local p=NP.AimBot
	addSec(p,1,"sec_trigger")
	local c=addCard(p,2)
	addToggle(c,1,"t_on","tg_en",false,function(o) CB.tb=o end)
	addSlider(c,2,"tg_fov",40,500,140," px",function(v) CB.tbFov=v end)
	addSlider(c,3,"tg_delay",200,900,350," ms",function(v) CB.tbDel=v/1000 end)
	addSec(p,4,"sec_spin")
	local c2=addCard(p,5)
	addToggle(c2,1,"t_on","sp_en",false,function(o)
		CB.spin=o
		local ch=LP.Character local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if h then h.AutoRotate=not o end
	end)
	addSlider(c2,2,"sp_speed",60,900,180," deg",function(v) CB.spinSpd=v end)
end

do
	local p=NP.Blatant
	addSec(p,1,"sec_char")
	local c1=addCard(p,2)
	addToggle(c1,1,"ms_en","",false,function(o)
		CB.maxSpd=o
		if not o then
			local ch=LP.Character local h=ch and ch:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed=16 end
		end
	end)
	addSlider(c1,2,"ms_val",16,30,20,"",function(v) CB.msVal=math.floor(v+.5) end)
	addToggle(c1,3,"nc_en","",false,function(o) CB.noclip=o end)
	addToggle(c1,4,"aj_en","",false,function(o) CB.air=o end)
	addSec(p,3,"sec_flight")
	local c2=addCard(p,4)
	addToggle(c2,1,"fl_en","",false,function(o) CB.fly=o end)
	addSlider(c2,2,"fl_spd",10,60,35,"",function(v) CB.flySpd=math.floor(v+.5) end)
	addSelector(c2,3,"fl_mode",{"Camera","Vertical"},{"fl_cam","fl_vert"},1,function(v) CB.flyMode=v end)
	addSec(p,5,"sec_vehicle")
	local c3=addCard(p,6)
	addToggle(c3,1,"ch_en","",false,function(o) CB.carHack=o end)
	addSlider(c3,2,"ch_spd",50,1000,300,"",function(v) CB.carSpd=math.floor(v+.5) end)
end

do
	local p=NP.Guns
	addSec(p,1,"sec_ammo")
	local c1=addCard(p,2)
	addToggle(c1,1,"am_en","",false,function(o) CB.ammo=o end)
	addToggle(c1,2,"nr_en","",false,function(o) CB.noreload=o end)
	addSec(p,3,"sec_fswitch")
	local c2=addCard(p,4)
	addToggle(c2,1,"fs_en","",false,function(o) CB.fastSwitch=o end)
	addSlider(c2,2,"fs_delay",0,500,50," ms",function(v) CB.fsDelay=v/1000 end)
end

do
	local p=NP.Misc
	addSec(p,1,"sec_ui")
	local c1=addCard(p,2)
	addSlider(c1,1,"ui_scale",60,150,100,"%",function(v) MSC.Scale=v/100 end)
	addToggle(c1,2,"fov_circle","",true,function(o) CB.showFov=o end)
	addSec(p,3,"sec_lang")
	local c2=addCard(p,4)
	addSelector(c2,1,"lang_choose",{"en","ru"},{"English","Русский"},1,function(v)
		Lang=v refreshLang()
	end)
end

local function switchPage(n)
	if n==SEL and CURR and CURR.Visible then return end
	SEL=n
	for pn,pg in pairs(NP) do
		if pg and pn~=n and pg.Visible then pg.Visible=false pg.Position=UDim2.fromOffset(0,0) end
	end
	for nm,o in pairs(NB) do
		local s=(nm==n)
		tw(o.lbl,0.3,{TextColor3=s and TX or TD})
		o.lbl.Font=s and Enum.Font.GothamBold or Enum.Font.GothamMedium
		tw(o.ul,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Size=UDim2.new(s and 0.45 or 0,0,0,3)})
	end
	local np=NP[n]
	if np then
		np.Position=UDim2.fromOffset(0,22) np.Visible=true
		tw(np,TweenInfo.new(0.4,Enum.EasingStyle.Quart),{Position=UDim2.fromOffset(0,0)})
		CURR=np
	end
end
for nm,d in pairs(NB) do d.btn.MouseButton1Click:Connect(function() switchPage(nm) end) end

-- HOTKEYS
U.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode==Enum.KeyCode.RightShift and introDone then
		if menuOpen then closeMenu() else openMenu() end
	end
	if input.KeyCode==Enum.KeyCode.F then
		CB.fly=not CB.fly
		pcall(function() SG:SetCore("SendNotification",{Title="Fly",Text=CB.fly and "ON" or "OFF",Duration=2}) end)
	end
end)

for n,o in pairs(NB) do
	local s=(n==SEL)
	o.lbl.TextColor3=s and TX or TD
	o.lbl.Font=s and Enum.Font.GothamBold or Enum.Font.GothamMedium
	o.ul.Size=UDim2.new(s and 0.45 or 0,0,0,3)
end
if NP[SEL] then NP[SEL].Position=UDim2.fromOffset(0,0) end

refreshLang()

if getgenv then
	getgenv().FinisHub={Combat=CB,GUI=G,Main=MENU,
		OpenMenu=openMenu,CloseMenu=closeMenu,
		SetLang=function(l) Lang=l refreshLang() end}
	getgenv().FinisToggleMenu=function()
		if menuOpen then closeMenu() else openMenu() end
	end
end

print("[Finis] READY — RSHIFT=menu, F=fly")
