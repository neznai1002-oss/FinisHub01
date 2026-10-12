-- language: Lua, file: finis_hub.lua, target: Roblox executor (delta/synapse/fluxus)
print("[Finis] load v10 START")

local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local R=game:GetService("RunService")
local W=game:GetService("Workspace")
local SG=game:GetService("StarterGui")
local CP=game:GetService("ContentProvider")
local SS=game:GetService("SoundService")
local Debris=game:GetService("Debris")
local HS=game:GetService("HttpService")
local LP=P.LocalPlayer

local DECAL_ID="rbxassetid://108600815593933"
local TEXTURE_ID="rbxassetid://134327784464327"
local GUN_SOUND_ID="rbxassetid://73952326343388"
local LOGO_ID=DECAL_ID

local G

local CB={
	esp=false, espWall=true, espText=true, espCol="Pink", espStyle="Chams",
	espHP=true, enemy="Auto",
	arrows=true, arrowRad=165,
	tb=false, tbFov=140, tbDel=0.35, tbAim=false,
	tracer=false, gunSound=false,
	killMsg=true, dmgMsg=false,
	spin=false, spinSpd=180,
	maxSpd=false, msVal=20,
	noclip=false, air=false,
	fly=false, flySpd=30, flyMode="Camera",
	fastSwitch=false, fsDelay=0.05,
	carHack=false, carSpd=300,
	ammo=false, noreload=false,
	showFov=true, uiScale=1,
}
local AB={enabled=false, fov=180, smooth=0.45, bone="Head", wall=false, pred=0.1, lock=true}
local SA={enabled=false, fov=200, bone="Head", wall=false, chance=100, pred=0.1, mode="Smart"}
local HB={enabled=false, size=8, part="HumanoidRootPart", show=false}
local AMMO={value=9999, swap=true, threshold=2}
local WS={enabled=false, npc=true}
local BR={rate=30, busy=false}
local AK={enabled=true}
local AL={enabled=false, name="default"}

local getTeamClass=function(plr)
	if not plr.Team then return "none" end
	local n=string.lower(plr.Team.Name)
	for _,k in ipairs({"guard","police","cop","swat","officer","captain","sheriff"}) do
		if string.find(n,k,1,true) then return "guard" end
	end
	for _,k in ipairs({"inmate","criminal","prisoner","convict","thief"}) do
		if string.find(n,k,1,true) then return "inmate" end
	end
	return "none"
end
local isEnemy=function(p)
	if p==LP then return false end
	if CB.enemy=="All" then return true end
	if CB.enemy=="Team" then
		if not p.Team or not LP.Team then return true end
		return p.Team~=LP.Team
	end
	local mc=getTeamClass(LP)
	local tc=getTeamClass(p)
	if mc~="none" and tc~="none" then return mc~=tc end
	if mc~="none" and tc=="none" then
		if p.Team and LP.Team and p.Team==LP.Team then return false end
		return true
	end
	if p.Team and LP.Team then return p.Team~=LP.Team end
	return true
end

local PG
pcall(function() if gethui then PG=gethui() end end)
if not PG then PG=LP:WaitForChild("PlayerGui") end

local function mk(c,p,par) local o=Instance.new(c) if p then for k,v in pairs(p) do o[k]=v end end if par then o.Parent=par end return o end
local function uc(o,r) return mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function sk(o,c,t,tr) return mk("UIStroke",{Color=c or Color3.fromRGB(60,60,70),Thickness=t or 1,Transparency=tr or 0},o) end
local function tw(o,tm,p)
	if not o or not o.Parent then return end
	if type(tm)=="number" then tm=TweenInfo.new(tm) end
	local ok,tt=pcall(T.Create,T,o,tm,p)
	if ok and tt then pcall(function() tt:Play() end) end
end
local function cam() return W.CurrentCamera end
local function safe(name,f)
	local ok,err=pcall(f)
	if not ok then warn("[Finis] "..name.." FAIL: "..tostring(err)) end
end

task.spawn(function() pcall(function() CP:PreloadAsync({DECAL_ID,TEXTURE_ID,GUN_SOUND_ID}) end) end)

local logoImgs={}
local function regLogo(im) im.Image=LOGO_ID table.insert(logoImgs,im) end

task.spawn(function()
	task.wait(0.8)
	local d=Instance.new("ImageLabel") d.Image=DECAL_ID
	local tx=Instance.new("ImageLabel") tx.Image=TEXTURE_ID
	local t0=os.clock()
	while os.clock()-t0<4 do if d.IsLoaded or tx.IsLoaded then break end task.wait(0.1) end
	if d.IsLoaded then print("[Finis] decal OK")
	elseif tx.IsLoaded then LOGO_ID=TEXTURE_ID
	else LOGO_ID=TEXTURE_ID end
	if not d.IsLoaded then
		for _,im in ipairs(logoImgs) do pcall(function() im.Image=LOGO_ID end) end
	end
	d:Destroy() tx:Destroy()
end)

-- GUN SOUND
local soundPool={}
local soundPoolIdx=1
local SOUND_POOL_SIZE=10
local gunSoundTemplate=Instance.new("Sound")
gunSoundTemplate.Name="FinisGunSound"
gunSoundTemplate.SoundId=GUN_SOUND_ID
gunSoundTemplate.Volume=3
gunSoundTemplate.Looped=false
gunSoundTemplate.Parent=W

task.spawn(function()
	local t0=os.clock()
	while not gunSoundTemplate.IsLoaded and os.clock()-t0<10 do task.wait(0.2) end
	if gunSoundTemplate.IsLoaded then
		print("[Finis] gun sound READY, length="..string.format("%.3f",gunSoundTemplate.TimeLength).."s")
		for i=1,SOUND_POOL_SIZE do
			local c=gunSoundTemplate:Clone() c.Volume=3 c.Parent=W soundPool[i]=c
		end
	else
		warn("[Finis] gun sound NOT LOADED — приватный/удалённый asset, нужен публичный audio ID")
	end
end)

local lastSoundPlay=0
local function playGunSound(force)
	if not CB.gunSound and not force then return end
	if os.clock()-lastSoundPlay<0.03 then return end
	lastSoundPlay=os.clock()
	local s=soundPool[soundPoolIdx]
	if not s or not s.Parent then
		s=gunSoundTemplate:Clone() s.Volume=3 s.Parent=W soundPool[soundPoolIdx]=s
	end
	soundPoolIdx=soundPoolIdx+1
	if soundPoolIdx>SOUND_POOL_SIZE then soundPoolIdx=1 end
	local played=pcall(function()
		s.TimePosition=0
		s.PlaybackSpeed=0.95+math.random()*0.1
		s:Play()
	end)
	if not played then pcall(function() SS:PlayLocalSound(s) end) end
end

-- палитра
local BG=Color3.fromRGB(10,10,13) local CD=Color3.fromRGB(21,21,25)
local BD=Color3.fromRGB(34,34,40) local TX=Color3.fromRGB(232,232,238)
local TD=Color3.fromRGB(140,140,150) local TM=Color3.fromRGB(90,90,100)
local AC=Color3.fromRGB(0,180,220) local ACH=Color3.fromRGB(0,230,255)
local TO=Color3.fromRGB(0,180,220) local TF=Color3.fromRGB(55,55,65)
local TK=Color3.fromRGB(42,42,50) local WT=Color3.fromRGB(255,255,255)
local PL=Color3.fromRGB(15,15,20) local IBT=Color3.fromRGB(4,4,6)
local OL=Color3.fromRGB(240,250,255)
local RED=Color3.fromRGB(255,90,90) local GRN=Color3.fromRGB(90,220,130)
local ORG=Color3.fromRGB(255,180,80)

-- LANG
local Lang="en"
local LS={
	en={sub="INTERNAL",tab_aim="AimBot",tab_vis="Visuals",tab_bl="Blatant",tab_gn="Guns",tab_ms="Misc",
		sec_trigger="Triggerbot",sec_spin="Spin",sec_esp="Player ESP",sec_tracer="Tracer",sec_kill="Notifications",sec_sound="Sound",
		sec_char="Character",sec_flight="Flight",sec_vehicle="Vehicle",sec_ammo="Ammo",sec_fswitch="Fast Switch",
		sec_ui="Interface",sec_lang="Language",sec_aimbot="Aimbot",sec_silent="Silent Aim",sec_hitbox="Hitbox",
		sec_burst="Burst Fire",sec_wall="Wall Shot",sec_prot="Protection",sec_cfg="Configs",
		cfg_name="name",cfg_save="SAVE",cfg_load="LOAD",cfg_delete="DELETE",cfg_auto="Auto-load on start",
		cfg_none="No file API on this executor",
		t_on="Enabled",
		tg_en="Auto-shoot",tg_fov="FOV",tg_delay="Delay",tg_aim="Lock camera",
		sp_en="Spin",sp_speed="Speed",
		esp_en="Enable ESP",esp_wall="Wallhack",esp_txt="Distance text",esp_col="Color",
		esp_style="Style",esp_enemy="Target mode",esp_arrows="Arrows",esp_hp="HP bar",esp_arad="Arrow radius",
		tr_en="Tracer",
		kf_kill="Kill messages",kf_dmg="Damage messages",
		snd_en="Custom shot sound",snd_test="Test sound",
		ms_en="Speed hack",ms_val="Value",nc_en="Noclip",aj_en="Air jump",
		fl_en="Fly",fl_spd="Speed",fl_mode="Mode",fl_cam="Camera",fl_vert="Vertical",
		ch_en="Car hack",ch_spd="Max speed",
		am_en="Infinite ammo",nr_en="No reload",am_val="Freeze value",am_swap="Swap bypass",
		am_thresh="Swap at",
		fs_en="Auto switch",fs_delay="Delay",
		ab_en="Camera aimbot",ab_fov="FOV",ab_smooth="Smoothness",ab_bone="Target bone",
		ab_wall="Wall check",ab_pred="Prediction",ab_lock="Target lock",
		sa_en="Silent aim",sa_fov="FOV",sa_bone="Target bone",sa_wall="Wall check",
		sa_chance="Hit chance",sa_pred="Prediction",sa_mode="Remote filter",sa_smart="Smart",sa_all="All",
		hb_en="Hitbox expander",hb_size="Size",hb_part="Part",hb_hrp="Root",hb_head="Head",hb_all="All parts",
		hb_show="Show hitboxes",
		bone_head="Head",bone_torso="Torso",bone_root="Root",bone_random="Random",
		burst_fire="FIRE ALL  (G)",burst_rate="Shots per second",
		ws_en="Shoot through walls",ws_npc="Include NPCs",
		ak_en="Anti-kick (267)",
		ui_scale="Menu scale",fov_circle="FOV circle",
		lang_choose="Language"},
	ru={sub="ИНТЕРНАЛ",tab_aim="Аим",tab_vis="Визуалы",tab_bl="Блат",tab_gn="Оружие",tab_ms="Разное",
		sec_trigger="Триггербот",sec_spin="Спин",sec_esp="ESP Игроков",sec_tracer="Трассер",sec_kill="Уведомления",sec_sound="Звук",
		sec_char="Персонаж",sec_flight="Полёт",sec_vehicle="Машина",sec_ammo="Патроны",sec_fswitch="Автосмена",
		sec_ui="Интерфейс",sec_lang="Язык",sec_aimbot="Аимбот",sec_silent="Сайлент аим",sec_hitbox="Хитбокс",
		sec_burst="Очередь",sec_wall="Валлшот",sec_prot="Защита",sec_cfg="Конфиги",
		cfg_name="имя",cfg_save="СОХРАНИТЬ",cfg_load="ЗАГРУЗИТЬ",cfg_delete="УДАЛИТЬ",cfg_auto="Автозагрузка при старте",
		cfg_none="Нет файлового API в этом экзекуторе",
		t_on="Включено",
		tg_en="Авто-выстрел",tg_fov="FOV",tg_delay="Задержка",tg_aim="Крутить камеру",
		sp_en="Спин",sp_speed="Скорость",
		esp_en="Включить ESP",esp_wall="Сквозь стены",esp_txt="Дистанция",esp_col="Цвет",
		esp_style="Стиль",esp_enemy="Режим",esp_arrows="Стрелки",esp_hp="HP полоска",esp_arad="Радиус стрелок",
		tr_en="Трассер",
		kf_kill="Убийства",kf_dmg="Урон",
		snd_en="Свой звук выстрела",snd_test="Тест звука",
		ms_en="Скорость",ms_val="Значение",nc_en="Сквозь стены",aj_en="Прыжок",
		fl_en="Полёт",fl_spd="Скорость",fl_mode="Режим",fl_cam="Камера",fl_vert="Вертикальный",
		ch_en="Ускорение",ch_spd="Скорость машины",
		am_en="Бесконечные патроны",nr_en="Без перезарядки",am_val="Значение",am_swap="Свап-байпас",
		am_thresh="Свап на",
		fs_en="Автосмена",fs_delay="Задержка",
		ab_en="Аимбот (камера)",ab_fov="FOV",ab_smooth="Плавность",ab_bone="Точка прицела",
		ab_wall="Проверка стен",ab_pred="Предикт",ab_lock="Фикс цели",
		sa_en="Сайлент аим",sa_fov="FOV",sa_bone="Точка прицела",sa_wall="Проверка стен",
		sa_chance="Шанс попадания",sa_pred="Предикт",sa_mode="Фильтр ремоутов",sa_smart="Умный",sa_all="Все",
		hb_en="Хитбоксы",hb_size="Размер",hb_part="Часть",hb_hrp="Корень",hb_head="Голова",hb_all="Все части",
		hb_show="Показывать хитбоксы",
		bone_head="Голова",bone_torso="Торс",bone_root="Корень",bone_random="Рандом",
		burst_fire="ВЫСТРЕЛИТЬ ВСЁ  (G)",burst_rate="Выстрелов в секунду",
		ws_en="Стрельба сквозь стены",ws_npc="Включая NPC",
		ak_en="Анти-кик (267)",
		ui_scale="Размер меню",fov_circle="FOV круг",
		lang_choose="Язык"}
}
local function TR(k) local p=LS[Lang] or LS.en return p[k] or k end
local textReg={}
local function regText(lbl,key) table.insert(textReg,{lbl=lbl,key=key}) lbl.Text=TR(key) end
local function dTxt(k) local p=LS[Lang] return (p and p[k]) or k end

G=mk("ScreenGui",{Name="FinisHub",ResetOnSpawn=false,IgnoreGuiInset=true,
	DisplayOrder=9999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PG)

-- FORWARD — модули присвоят позже
local getAny=nil
local findAmmoValue=nil
local ammoDiag=function() end
local burstFire=function() end
local silentTarget=nil
local aimLockPlr=nil
local alToggle=nil

-- =========================================================
-- INTRO — короткое, пуленепробиваемое
-- =========================================================
local introDone=false
local OV=nil
local introEls={}

local function killIntro()
	if introDone then return end
	introDone=true
	if OV and OV.Parent then
		local ov=OV
		pcall(function()
			for _,e in ipairs(introEls) do
				if e and e.Parent then
					if e:IsA("TextLabel") then tw(e,0.25,{TextTransparency=1})
					elseif e:IsA("ImageLabel") then tw(e,0.25,{ImageTransparency=1})
					else tw(e,0.25,{BackgroundTransparency=1}) end
				end
			end
			tw(ov,0.25,{BackgroundTransparency=1})
		end)
		task.delay(0.35,function()
			if ov and ov.Parent then pcall(function() ov:Destroy() end) end
		end)
	end
end
task.delay(5.5,killIntro)

pcall(function()
	OV=mk("Frame",{Name="Intro",Size=UDim2.fromScale(1,1),BackgroundColor3=IBT,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=5000},G)
	table.insert(introEls,OV)

	local CX=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(340,220),BackgroundTransparency=1,ZIndex=5005},OV)
	local IntroLogo=mk("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.12,0),Size=UDim2.fromOffset(95,95),BackgroundTransparency=1,
		ImageColor3=WT,ScaleType=Enum.ScaleType.Fit,ZIndex=5010},CX)
	regLogo(IntroLogo)
	table.insert(introEls,IntroLogo)
	local IntroLogoScale=mk("UIScale",{Scale=0.4},IntroLogo)

	local lblTitle=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.58,0),Size=UDim2.fromOffset(300,32),
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Finis Hub",TextColor3=WT,TextSize=22,
		TextTransparency=1,ZIndex=5008},CX)
	table.insert(introEls,lblTitle)

	local Status=mk("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.75,0),Size=UDim2.fromOffset(300,16),
		BackgroundTransparency=1,Font=Enum.Font.Code,Text="",TextColor3=TD,TextSize=11,TextTransparency=1,ZIndex=5008},CX)
	table.insert(introEls,Status)

	local PBar=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.88,0),Size=UDim2.fromOffset(200,2),
		BackgroundColor3=Color3.fromRGB(30,30,38),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5008},CX)
	uc(PBar,100)
	table.insert(introEls,PBar)
	local PFill=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=WT,BorderSizePixel=0,ZIndex=5009},PBar)
	uc(PFill,100)
	table.insert(introEls,PFill)

	local SKIP=mk("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-20,0,20),Size=UDim2.fromOffset(80,28),
		BackgroundColor3=Color3.fromRGB(20,20,26),BackgroundTransparency=0.4,BorderSizePixel=0,
		Text="SKIP",Font=Enum.Font.GothamBold,TextColor3=TD,TextSize=11,AutoButtonColor=false,ZIndex=5100},OV)
	uc(SKIP,12) sk(SKIP,Color3.fromRGB(50,50,60),1,0.4)
	table.insert(introEls,SKIP)
	SKIP.MouseButton1Click:Connect(killIntro)

	local fakeLines={"init renderer","loading modules","esp.chams","silentaim.hook",
		"aimbot.predict","wallshot.rayhook","ammo.freeze","config.system","ready."}

	task.spawn(function()
		local ok,err=pcall(function()
			task.wait(0.2)
			if introDone then return end
			tw(IntroLogoScale,TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1})
			tw(lblTitle,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0})
			task.wait(0.8)
			if introDone then return end
			tw(Status,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0})
			tw(PBar,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0})
			local total=2.8 local st=os.clock()
			while not introDone do
				local e=os.clock()-st
				if e>=total then break end
				local pct=e/total
				PFill.Size=UDim2.new(pct,0,1,0)
				local li=math.floor(pct*#fakeLines)+1
				if li>#fakeLines then li=#fakeLines end
				Status.Text=fakeLines[li].."  ["..math.floor(pct*100).."%]"
				Status.TextColor3=(li==#fakeLines) and ACH or TD
				task.wait(0.1)
			end
			if introDone then return end
			PFill.Size=UDim2.new(1,0,1,0)
			Status.Text="ready."
			task.wait(0.3)
			killIntro()
		end)
		if not ok then warn("[Finis] intro err:",err) killIntro() end
	end)
end)

-- =========================================================
-- MENU — каркас (UI поднимается гарантированно)
-- =========================================================
local MENU=mk("Frame",{Name="Main",Size=UDim2.fromScale(0.95,0.9),Position=UDim2.new(0.5,0,0.5,0),
	AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=BG,BorderSizePixel=0,Visible=false,BackgroundTransparency=1,ZIndex=900},G)
uc(MENU,12) sk(MENU,BD,1,0.2)
mk("UISizeConstraint",{MinSize=Vector2.new(300,320),MaxSize=Vector2.new(720,520)},MENU)
local MSC=mk("UIScale",{Scale=0.85},MENU)

local TOP=mk("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,ZIndex=901},MENU)
local HeaderLogo=mk("ImageLabel",{Name="HeaderLogo",Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(14,9),
	BackgroundTransparency=1,ImageColor3=WT,ScaleType=Enum.ScaleType.Fit,ZIndex=902},TOP)
regLogo(HeaderLogo)
mk("TextLabel",{Size=UDim2.fromOffset(60,18),Position=UDim2.fromOffset(52,16),BackgroundTransparency=1,
	Font=Enum.Font.GothamBold,Text="Finis",TextColor3=TX,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=902},TOP)
local lblInt=mk("TextLabel",{Size=UDim2.fromOffset(90,18),Position=UDim2.fromOffset(90,16),BackgroundTransparency=1,
	Font=Enum.Font.GothamMedium,Text="",TextColor3=TD,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=902},TOP)
regText(lblInt,"sub")
local CLB=mk("TextButton",{Size=UDim2.fromOffset(36,36),Position=UDim2.new(1,-44,0,7),BackgroundTransparency=1,
	Font=Enum.Font.GothamBold,Text="x",TextColor3=TD,TextSize=18,AutoButtonColor=false,ZIndex=905},TOP)
local CLS=mk("UIScale",{Scale=1},CLB)
CLB.MouseEnter:Connect(function() tw(CLS,0.3,{Scale=1.2}) tw(CLB,0.3,{TextColor3=TX,Rotation=90}) end)
CLB.MouseLeave:Connect(function() tw(CLS,0.3,{Scale=1}) tw(CLB,0.3,{TextColor3=TD,Rotation=0}) end)

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
	local tl=mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
		Font=sel and Enum.Font.GothamBold or Enum.Font.GothamMedium,Text="",
		TextColor3=sel and TX or TD,TextSize=13,ZIndex=903},wr)
	regText(tl,navKeyMap[n])
	local un=mk("Frame",{Size=UDim2.new(sel and 0.45 or 0,0,0,3),Position=UDim2.new(0.5,0,1,-4),
		AnchorPoint=Vector2.new(0.5,1),BackgroundColor3=AC,BorderSizePixel=0,ZIndex=904},wr)
	uc(un,2)
	NB[n]={btn=wr,lbl=tl,ul=un}
end

local allCards={}
local function addSec(p,o,key)
	local h=mk("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=o,ZIndex=903},p)
	local dot=mk("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.fromOffset(0,10),
		BackgroundColor3=AC,BorderSizePixel=0,Rotation=45,ZIndex=904},h)
	uc(dot,1)
	local lbl=mk("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,
		Font=Enum.Font.GothamSemibold,Text="",TextColor3=TX,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=904},h)
	regText(lbl,key)
end
local function addCard(p,o)
	local cd=mk("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=CD,BorderSizePixel=0,LayoutOrder=o,
		AutomaticSize=Enum.AutomaticSize.Y,ZIndex=903},p)
	uc(cd,10)
	sk(cd,BD,1,0.2)
	mk("UIListLayout",{Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder},cd)
	mk("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},cd)
	table.insert(allCards,cd)
	return cd
end

local SYNC={}
local function bind(key,save,load)
	SYNC[#SYNC+1]={key=key,save=save,load=load}
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
	local ts=sk(trk,TO,1,0.5)
	local kn=mk("Frame",{Size=UDim2.fromOffset(18,18),
		Position=def and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
		BackgroundColor3=WT,BorderSizePixel=0,ZIndex=906},trk)
	uc(kn,100)
	local st={en=def or false}
	local function ap(e)
		tw(trk,0.4,{BackgroundColor3=e and TO or TF})
		tw(ts,0.4,{Transparency=e and 0.2 or 0.5})
		tw(kn,TweenInfo.new(0.5,Enum.EasingStyle.Back),{Position=e and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
	end
	st.set=function(v)
		if st.en==v then return end
		st.en=v
		ap(v)
		if cb then cb(v) end
	end
	r.MouseEnter:Connect(function() if not st.en then tw(trk,0.35,{BackgroundColor3=Color3.fromRGB(65,65,75)}) end end)
	r.MouseLeave:Connect(function() if not st.en then tw(trk,0.35,{BackgroundColor3=TF}) end end)
	r.MouseButton1Click:Connect(function()
		st.set(not st.en)
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
	local function sv(v)
		val=math.clamp(v,mn,mx)
		local a=(val-mn)/(mx-mn)
		fl.Size=UDim2.new(a,0,1,0)
		kb.Position=UDim2.new(a,0,0.5,0)
		if isFloat then vL.Text=string.format("%.2f",val)..(sfx or "") else vL.Text=tostring(math.floor(val+.5))..(sfx or "") end
		if cb then cb(val) end
	end
	local function fa(x)
		local rl=(x-hit.AbsolutePosition.X)/hit.AbsoluteSize.X
		rl=math.clamp(rl,0,1)
		sv(mn+rl*(mx-mn))
	end
	hit.InputBegan:Connect(function(x)
		if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
			drg=true fa(x.Position.X)
		end
	end)
	U.InputChanged:Connect(function(x)
		if drg and (x.UserInputType==Enum.UserInputType.MouseMovement or x.UserInputType==Enum.UserInputType.Touch) then fa(x.Position.X) end
	end)
	U.InputEnded:Connect(function(x)
		if x.UserInputType==Enum.UserInputType.MouseButton1 or x.UserInputType==Enum.UserInputType.Touch then
			drg=false
		end
	end)
	sv(df)
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
		Font=Enum.Font.Gotham,Text=dTxt(disp[di] or disp[1]),TextColor3=TX,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,ZIndex=906},bx)
	local i=di or 1
	local function ap(n)
		i=((n-1)%#opts)+1
		vL.Text=dTxt(disp[i])
		if cb then cb(opts[i],i) end
	end
	r.MouseButton1Click:Connect(function() ap(i+1) end)
	return{get=function() return opts[i] end,
		set=function(val)
			for n=1,#opts do
				if opts[n]==val then
					if n~=i then ap(n) end
					return
				end
			end
		end}
end

local function addBtn(p,o,tkey,cb)
	local r=mk("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(28,28,34),
		BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=o,ZIndex=904},p)
	uc(r,8) sk(r,BD,1,0.2)
	local l=mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,
		Text="",TextColor3=TX,TextSize=13,ZIndex=905},r)
	regText(l,tkey)
	r.MouseEnter:Connect(function() tw(r,0.25,{BackgroundColor3=Color3.fromRGB(36,36,44)}) end)
	r.MouseLeave:Connect(function() tw(r,0.25,{BackgroundColor3=Color3.fromRGB(28,28,34)}) end)
	r.MouseButton1Click:Connect(function()
		tw(r,0.15,{BackgroundColor3=Color3.fromRGB(0,130,165)})
		task.delay(0.15,function() tw(r,0.45,{BackgroundColor3=Color3.fromRGB(28,28,34)}) end)
		if cb then cb() end
	end)
end

local menuOpen=false
local function openMenu()
	if menuOpen then return end
	menuOpen=true
	MENU.Visible=true
	MENU.BackgroundTransparency=1
	MSC.Scale=0.85*CB.uiScale
	tw(MENU,0.5,{BackgroundTransparency=0})
	tw(MSC,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1*CB.uiScale})
end
local function closeMenu()
	if not menuOpen then return end
	menuOpen=false
	tw(MENU,0.45,{BackgroundTransparency=1})
	tw(MSC,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Scale=0.9*CB.uiScale})
	task.delay(0.5,function() if not menuOpen then MENU.Visible=false end end)
end
CLB.MouseButton1Click:Connect(closeMenu)

local function refreshLang()
	for _,e in ipairs(textReg) do
		if e.lbl and e.lbl.Parent then e.lbl.Text=TR(e.key) end
	end
end

-- FOV круг (UI)
local FOV=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.fromOffset(280,280),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=2},G)
uc(FOV,5000)
sk(FOV,WT,1.5,0.4)

-- PILL
local PH=mk("Frame",{Name="PillHUD",Size=UDim2.fromOffset(250,40),Position=UDim2.new(0,-260,0,12),BackgroundTransparency=1,ZIndex=1000},G)
local PB=mk("TextButton",{Size=UDim2.fromScale(1,1),BackgroundColor3=PL,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=1000},PH)
uc(PB,10) sk(PB,Color3.fromRGB(35,35,45),1,0.1)
local PILogo=mk("ImageLabel",{Size=UDim2.fromOffset(28,28),Position=UDim2.fromOffset(10,6),
	BackgroundTransparency=1,ImageColor3=WT,ScaleType=Enum.ScaleType.Fit,ZIndex=1002},PB)
regLogo(PILogo)
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
PB.MouseEnter:Connect(function() tw(PB,0.4,{BackgroundColor3=Color3.fromRGB(24,24,30)}) end)
PB.MouseLeave:Connect(function() tw(PB,0.4,{BackgroundColor3=PL}) end)
task.spawn(function()
	local t0=os.clock()
	while not introDone and os.clock()-t0<12 do task.wait(0.15) end
	introDone=true
	PH.Position=UDim2.new(0,-260,0,12)
	tw(PH,TweenInfo.new(1.0,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,12,0,12)})
	task.wait(1.0)
	openMenu()
end)

-- KILL FEED (top-level: нужен модулям)
local KF=mk("Frame",{Name="KillFeed",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,140),
	Size=UDim2.fromOffset(340,340),BackgroundTransparency=1,ZIndex=1050},G)
mk("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder,
	HorizontalAlignment=Enum.HorizontalAlignment.Right},KF)

local kfOrder=0
local function addKill(title, sub, col)
	kfOrder=kfOrder+1
	local row=mk("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=Color3.fromRGB(20,20,26),
		BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-kfOrder,ZIndex=1051},KF)
	uc(row,12)
	local rowS=sk(row,col,1,0.4)
	local accent=mk("Frame",{Size=UDim2.fromOffset(3,40),Position=UDim2.fromOffset(8,9),
		BackgroundColor3=col,BorderSizePixel=0,ZIndex=1052},row)
	uc(accent,2)
	mk("TextLabel",{Size=UDim2.new(1,-30,0,22),Position=UDim2.fromOffset(18,6),
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=title,
		TextColor3=col,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1052},row)
	mk("TextLabel",{Size=UDim2.new(1,-30,0,18),Position=UDim2.fromOffset(18,30),
		BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=sub,
		TextColor3=TD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1052},row)
	tw(row,0.5,{BackgroundTransparency=0})
	task.delay(4,function()
		tw(row,0.6,{BackgroundTransparency=1})
		tw(rowS,0.6,{Transparency=1})
		tw(accent,0.6,{BackgroundTransparency=1})
		task.wait(0.7)
		if row.Parent then row:Destroy() end
	end)
end

local recentShots={}
local myKills=0
local lastHp={}
P.PlayerRemoving:Connect(function(p) lastHp[p]=nil end)

local function rememberShot(victim, weaponName, distance)
	table.insert(recentShots, 1, {t=os.clock(), victim=victim, weapon=weaponName, distance=distance, dmg=0})
	if #recentShots>8 then table.remove(recentShots) end
end

safe("killfeed loop", function()
	task.spawn(function()
		while G and G.Parent do
			for _,p in ipairs(P:GetPlayers()) do
				if p~=LP then
					local ch=p.Character
					if ch then
						local hum=ch:FindFirstChildOfClass("Humanoid")
						if hum then
							local prev=lastHp[p]
							local cur=hum.Health
							if prev and cur<prev then
								local dmg=math.floor(prev-cur)
								if dmg>0 then
									local now=os.clock()
									local shot=nil
									for _,s in ipairs(recentShots) do
										if s.victim==p and now-s.t<0.8 then shot=s break end
									end
									if shot then
										shot.dmg=shot.dmg+dmg
										if CB.dmgMsg and cur>0 and dmg>=5 then
											addKill("-"..dmg.."  "..p.Name, shot.weapon.."  •  "..math.floor(shot.distance).." studs", RED)
										end
										if cur<=0 and CB.killMsg and shot.dmg>=10 then
											myKills=myKills+1
											addKill("KILL  "..p.Name, shot.weapon.."  •  "..math.floor(shot.distance).." studs  •  #"..myKills, GRN)
											for i=#recentShots,1,-1 do
												if recentShots[i].victim==p then table.remove(recentShots,i) end
											end
										end
									end
								end
							end
							lastHp[p]=cur
						end
					end
				end
			end
			task.wait(0.08)
		end
	end)
end)

-- =========================================================
-- МОДУЛИ — каждый в своей капсуле
-- =========================================================

safe("ESP", function()
	local ESP_STYLES={"Chams","Outline","Both","Skeleton","Corners","Box","All"}
	local ESP_COLORS={
		Pink=Color3.fromRGB(255,150,230),Red=Color3.fromRGB(255,80,80),Blue=Color3.fromRGB(100,170,255),
		Green=Color3.fromRGB(90,220,130),Purple=Color3.fromRGB(180,120,255),Yellow=Color3.fromRGB(255,220,90),
		Cyan=Color3.fromRGB(0,220,240),White=Color3.fromRGB(255,255,255),Black=Color3.fromRGB(15,15,18)}
	local function ec() return ESP_COLORS[CB.espCol] or ESP_COLORS.Pink end

	local espCache={}
	local function cleanupE(e)
		if not e then return end
		for _,k in ipairs({"hlInner","hlOuter","corners","skeleton","text","box","hpBar"}) do
			if e[k] then pcall(function() e[k]:Destroy() end) e[k]=nil end
		end
	end
	local function ensureHL(ch)
		local e=espCache[ch]
		if e and e.hlInner and e.hlInner.Parent==ch then return e end
		local inner=Instance.new("Highlight")
		inner.Name="FinisHLInner" inner.Adornee=ch inner.Parent=ch
		local outer=Instance.new("Highlight")
		outer.Name="FinisHLOuter" outer.Adornee=ch outer.Parent=ch
		if not e then e={} espCache[ch]=e end
		e.hlInner=inner e.hlOuter=outer
		return e
	end
	local SKELETON_CONN={
		{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
		{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},
		{"LowerTorso","RightUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"}}
	local LEGACY_CONN={
		{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

	local function updateTarget(plr,ch)
		local e=espCache[ch]
		if not e then e={} espCache[ch]=e end
		local col=ec() local style=CB.espStyle
		local hrp=ch:FindFirstChild("HumanoidRootPart")
		local hum=ch:FindFirstChildOfClass("Humanoid")
		local vis=CB.esp and hrp and hum and hum.Health>0

		if vis and (style=="Chams" or style=="Outline" or style=="Both" or style=="All") then
			local en=ensureHL(ch)
			if en and en.hlInner and en.hlOuter then
				en.hlInner.Enabled=true en.hlInner.Adornee=ch
				en.hlOuter.Enabled=true en.hlOuter.Adornee=ch
				local depth=CB.espWall and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
				en.hlInner.DepthMode=depth en.hlOuter.DepthMode=depth
				if style=="Chams" then
					en.hlInner.FillTransparency=0.35 en.hlInner.FillColor=col en.hlInner.OutlineTransparency=1
					en.hlOuter.FillTransparency=1 en.hlOuter.OutlineTransparency=0.3
					en.hlOuter.OutlineColor=col:Lerp(OL,0.6)
				elseif style=="Outline" then
					en.hlInner.FillTransparency=1 en.hlInner.OutlineTransparency=0.1
					en.hlInner.OutlineColor=col:Lerp(OL,0.3)
					en.hlOuter.FillTransparency=1 en.hlOuter.OutlineTransparency=1
				else
					en.hlInner.FillTransparency=0.5 en.hlInner.FillColor=col en.hlInner.OutlineTransparency=1
					en.hlOuter.FillTransparency=1 en.hlOuter.OutlineTransparency=0.15
					en.hlOuter.OutlineColor=col:Lerp(OL,0.55)
				end
			end
		elseif e.hlInner then
			e.hlInner.Enabled=false
			if e.hlOuter then e.hlOuter.Enabled=false end
		end

		if vis and CB.espHP and hrp then
			if not e.hpBar or not e.hpBar.Parent then
				if e.hpBar then pcall(function() e.hpBar:Destroy() end) end
				local bg=Instance.new("BillboardGui")
				bg.Name="FinisHP" bg.Size=UDim2.new(0,4,0,50)
				bg.Adornee=hrp bg.AlwaysOnTop=true bg.LightInfluence=0
				bg.Offset=Vector2.new(-46,0)
				bg.ResetOnSpawn=false bg.Parent=ch
				local back=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(20,20,22),
					BackgroundTransparency=0.2,BorderSizePixel=0,Parent=bg})
				uc(back,2)
				local fill=mk("Frame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,1,0),
					AnchorPoint=Vector2.new(0,1),BackgroundColor3=GRN,BorderSizePixel=0,Parent=back})
				uc(fill,2)
				e.hpBar=bg e.hpFill=fill
			end
			e.hpBar.Enabled=true
			if e.hpFill then
				local ratio=math.clamp(hum.Health/math.max(hum.MaxHealth,100),0,1)
				e.hpFill.Size=UDim2.new(1,0,ratio,0)
				local hpCol=GRN
				if ratio<0.3 then hpCol=RED
				elseif ratio<0.6 then hpCol=ORG
				elseif ratio<0.85 then hpCol=Color3.fromRGB(255,220,90) end
				e.hpFill.BackgroundColor3=hpCol
			end
		elseif e.hpBar then e.hpBar.Enabled=false end

		if CB.espText and vis then
			local head=ch:FindFirstChild("Head")
			if head then
				if not e.text or e.text.Parent~=head then
					if e.text then pcall(function() e.text:Destroy() end) end
					local bg=Instance.new("BillboardGui")
					bg.Name="FinisTxt" bg.Size=UDim2.new(0,220,0,34)
					bg.StudsOffset=Vector3.new(0,3.1,0) bg.AlwaysOnTop=true bg.LightInfluence=0 bg.Parent=head
					local n=Instance.new("TextLabel")
					n.Size=UDim2.new(1,0,0,18) n.BackgroundTransparency=1
					n.Font=Enum.Font.GothamBold n.TextSize=13 n.TextColor3=WT
					n.TextStrokeTransparency=0.2 n.Text=plr.Name n.Parent=bg
					local d=Instance.new("TextLabel")
					d.Size=UDim2.new(1,0,0,14) d.Position=UDim2.new(0,0,0,18) d.BackgroundTransparency=1
					d.Font=Enum.Font.GothamMedium d.TextSize=11 d.TextColor3=Color3.fromRGB(220,220,220)
					d.TextStrokeTransparency=0.3 d.Text="" d.Parent=bg
					e.text=bg
				end
				e.text.Enabled=true
				local n=e.text:FindFirstChild("TextLabel")
				local d=n and n.Parent:FindFirstChild("TextLabel",true)
				local myH=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
				local dist=0
				if myH and hrp then dist=math.floor((myH.Position-hrp.Position).Magnitude) end
				local labels={}
				for _,x in ipairs(e.text:GetDescendants()) do
					if x:IsA("TextLabel") then table.insert(labels,x) end
				end
				if #labels>=2 then
					labels[1].TextColor3=col:Lerp(OL,0.3)
					labels[2].Text=dist.." studs"
				end
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
end)

safe("Movement", function()
	local function forceNoclip()
		local ch=LP.Character
		if not ch or not ch.Parent then return end
		for _,d in ipairs(ch:GetDescendants()) do
			if d:IsA("BasePart") and d.CanCollide then d.CanCollide=false end
		end
	end
	R.Stepped:Connect(function() if CB.noclip then pcall(forceNoclip) end end)
	R.Heartbeat:Connect(function() if CB.noclip then pcall(forceNoclip) end end)

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
	end)

	local FS={bv=nil,bg=nil}
	local function stopFly()
		if FS.bv then FS.bv:Destroy() FS.bv=nil end
		if FS.bg then FS.bg:Destroy() FS.bg=nil end
		local ch=LP.Character
		local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if h then h.PlatformStand=false end
	end
	R.Heartbeat:Connect(function()
		if not CB.fly then
			if FS.bv then stopFly() end
			return
		end
		local ch=LP.Character
		local hr=ch and ch:FindFirstChild("HumanoidRootPart")
		local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if not hr or not h then return end
		if not FS.bv then
			local bv=Instance.new("BodyVelocity")
			bv.MaxForce=Vector3.new(5e4,5e4,5e4) bv.P=1e4 bv.Velocity=Vector3.new(0,0,0) bv.Parent=hr
			local bg=Instance.new("BodyGyro")
			bg.MaxTorque=Vector3.new(5e5,5e5,5e5) bg.P=5e3 bg.D=500 bg.CFrame=hr.CFrame bg.Parent=hr
			h.PlatformStand=true
			FS.bv=bv FS.bg=bg
		end
		local mx,mz=0,0
		if Controls then
			local ok,res=pcall(function() return Controls:GetMoveVector() end)
			if ok and res then mx=res.X mz=res.Z end
		end
		if mx==0 and mz==0 then
			for _,k in ipairs(U:GetKeysPressed()) do
				if k.KeyCode==Enum.KeyCode.W then mz=-1 end
				if k.KeyCode==Enum.KeyCode.S then mz=1 end
				if k.KeyCode==Enum.KeyCode.A then mx=-1 end
				if k.KeyCode==Enum.KeyCode.D then mx=1 end
			end
		end
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
		else
			dir=fwd*(-mz)+rst*mx
		end
		if dir.Magnitude>0.01 then dir=dir.Unit*CB.flySpd end
		FS.bv.Velocity=FS.bv.Velocity:Lerp(dir,0.35)
		FS.bg.CFrame=CFrame.new(hr.Position,hr.Position+look)
	end)

	U.JumpRequest:Connect(function()
		if not CB.air then return end
		local ch=LP.Character
		local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if not h then return end
		local s=h:GetState()
		if s==Enum.HumanoidStateType.Jumping or s==Enum.HumanoidStateType.Freefall then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	task.spawn(function()
		while G and G.Parent do
			if CB.carHack then
				local ch=LP.Character
				local hm=ch and ch:FindFirstChildOfClass("Humanoid")
				local seat=hm and hm.SeatPart
				if seat and seat:IsA("VehicleSeat") then
					pcall(function()
						seat.MaxSpeed=CB.carSpd
						seat.Torque=CB.carSpd*10
					end)
				end
			end
			task.wait(0.2)
		end
	end)

	R.Heartbeat:Connect(function()
		if not CB.maxSpd then return end
		local ch=LP.Character
		local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if not h then return end
		local t=CB.msVal
		local cr=h.WalkSpeed
		if math.abs(cr-t)>0.5 then
			h.WalkSpeed=cr+math.clamp(t-cr,-0.5,0.5)
		end
	end)
end)

safe("Aim core + hooks", function()
	local Mouse=LP:GetMouse()
	local wsBypass=false

	local function getBonePart(ch,bone)
		if bone=="Head" then
			return ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
		elseif bone=="Torso" then
			return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or ch:FindFirstChild("HumanoidRootPart")
		elseif bone=="Random" then
			local opts={}
			local hh=ch:FindFirstChild("Head") if hh then table.insert(opts,hh) end
			local tt=ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") if tt then table.insert(opts,tt) end
			local rr=ch:FindFirstChild("HumanoidRootPart") if rr then table.insert(opts,rr) end
			if #opts>0 then return opts[math.random(1,#opts)] end
			return ch:FindFirstChild("HumanoidRootPart")
		end
		return ch:FindFirstChild("HumanoidRootPart")
	end

	local function partVisible(part,char)
		local c=cam()
		if not c then return true end
		local o=c.CFrame.Position
		local dir=part.Position-o
		local dist=dir.Magnitude
		if dist<0.5 then return true end
		local rp=RaycastParams.new()
		rp.FilterType=Enum.RaycastFilterType.Exclude
		local ex={}
		if LP.Character then table.insert(ex,LP.Character) end
		table.insert(ex,char)
		rp.FilterDescendantsInstances=ex
		rp.RespectCanCollide=false
		wsBypass=true
		local hit=W:Raycast(o,dir,rp)
		wsBypass=false
		if not hit then return true end
		if hit.Instance:IsDescendantOf(char) then return true end
		return (hit.Position-o).Magnitude >= dist-1
	end

	local function predictPart(part,pred)
		local ok,v=pcall(function() return part.AssemblyLinearVelocity end)
		if ok and v and v.Magnitude>0.5 then
			return part.Position + v*pred
		end
		return part.Position
	end

	getAny=function(fv)
		local c=cam()
		if not c then return nil end
		local cn=Vector2.new(c.ViewportSize.X*0.5,c.ViewportSize.Y*0.5)
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
							if d<bd then bd=d bs={h=hd,r=rt,ch=ch,plr=p} end
						end
					end
				end
			end
		end
		return bs
	end

	local function acquireTarget(fovPx,useMouse,wallcheck,bone)
		local c=cam()
		if not c then return nil end
		local center
		if useMouse then
			local mp=U:GetMouseLocation()
			center=Vector2.new(mp.X,mp.Y)
		else
			center=Vector2.new(c.ViewportSize.X*0.5,c.ViewportSize.Y*0.5)
		end
		local best=nil local bd=fovPx
		for _,p in ipairs(P:GetPlayers()) do
			if p~=LP and isEnemy(p) then
				local ch=p.Character
				local hum=ch and ch:FindFirstChildOfClass("Humanoid")
				if ch and hum and hum.Health>0 then
					local part=getBonePart(ch,bone)
					if part then
						local sp,on=c:WorldToViewportPoint(part.Position)
						if on and sp.Z>0 then
							local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
							if d<bd and (not wallcheck or partVisible(part,ch)) then
								bd=d best={plr=p,char=ch,part=part}
							end
						end
					end
				end
			end
		end
		return best
	end

	local function wallshotOriginNear(origin)
		local ch=LP.Character
		if not ch then return false end
		local refs={}
		local hrp=ch:FindFirstChild("HumanoidRootPart") if hrp then table.insert(refs,hrp.Position) end
		local hd=ch:FindFirstChild("Head") if hd then table.insert(refs,hd.Position) end
		local tool=ch:FindFirstChildOfClass("Tool")
		if tool then local h=tool:FindFirstChild("Handle") if h then table.insert(refs,h.Position) end end
		local c=cam() if c then table.insert(refs,c.CFrame.Position) end
		for _,r in ipairs(refs) do
			if (origin-r).Magnitude<15 then return true end
		end
		return false
	end

	local incCache=nil
	local incCacheT=0
	local function buildCharInclude()
		if incCache and os.clock()-incCacheT<0.5 then return incCache end
		local inc={}
		local myCh=LP.Character
		for _,p in ipairs(P:GetPlayers()) do
			if p~=LP and p.Character then table.insert(inc,p.Character) end
		end
		if WS.npc then
			for _,m in ipairs(W:GetChildren()) do
				if m:IsA("Model") and m~=myCh and m:FindFirstChildOfClass("Humanoid") then
					table.insert(inc,m)
				end
			end
		end
		incCache=inc incCacheT=os.clock()
		return inc
	end

	local function holdingWeapon()
		local ch=LP.Character
		return ch~=nil and ch:FindFirstChildOfClass("Tool")~=nil
	end

	local REMOTE_PATS={"fire","shoot","shot","hit","bullet","gun","weapon","damage","attack","swing","knife","projectile"}
	local function remoteAllowed(self)
		if SA.mode=="All" then return true end
		local ok,n=pcall(function() return string.lower(self.Name) end)
		if ok and n then
			for _,pat in ipairs(REMOTE_PATS) do
				if n:find(pat,1,true) then return true end
			end
		end
		local ch=LP.Character
		if ch and self:IsDescendantOf(ch) then return true end
		local bp=LP:FindFirstChild("Backpack")
		if bp and self:IsDescendantOf(bp) then return true end
		return false
	end

	local function closure(f)
		if newcclosure then return newcclosure(f) end
		return f
	end

	if hookmetamethod and getnamecallmethod then
		local ok=pcall(function()
			local old=hookmetamethod(game,"__namecall",closure(function(self,...)
				local m=getnamecallmethod()
				if AK.enabled and m=="Kick" and self==LP then
					return nil
				end
				if WS.enabled and not wsBypass then
					if m=="Raycast" then
						local origin,direction=...
						if typeof(origin)=="Vector3" and typeof(direction)=="Vector3"
							and direction.Magnitude>15 and wallshotOriginNear(origin) then
							local inc=buildCharInclude()
							if #inc>0 then
								local rp=RaycastParams.new()
								rp.FilterType=Enum.RaycastFilterType.Include
								rp.RespectCanCollide=false
								rp.FilterDescendantsInstances=inc
								wsBypass=true
								local okc,hit=pcall(W.Raycast,W,origin,direction,rp)
								wsBypass=false
								if okc and hit then return hit end
							end
						end
					elseif m=="FindPartOnRay" or m=="FindPartOnRayWithIgnoreList" then
						local ray=...
						if typeof(ray)=="Ray" and ray.Direction.Magnitude>15 and wallshotOriginNear(ray.Origin) then
							local inc=buildCharInclude()
							if #inc>0 then
								local rp=RaycastParams.new()
								rp.FilterType=Enum.RaycastFilterType.Include
								rp.RespectCanCollide=false
								rp.FilterDescendantsInstances=inc
								wsBypass=true
								local okc,hit=pcall(W.Raycast,W,ray.Origin,ray.Direction,rp)
								wsBypass=false
								if okc and hit then
									return hit.Instance,hit.Position,hit.Normal,hit.Material
								end
							end
						end
					end
				end
				if silentTarget and SA.enabled then
					if (m=="FireServer" or m=="InvokeServer") and holdingWeapon()
						and math.random(1,100)<=SA.chance and remoteAllowed(self) then
						local args={...}
						local mod=false
						for i=1,#args do
							local v=args[i]
							if typeof(v)=="Vector3" then
								args[i]=silentTarget.pos mod=true
							elseif typeof(v)=="CFrame" and (silentTarget.pos-v.Position).Magnitude>0.01 then
								args[i]=CFrame.lookAt(v.Position,silentTarget.pos) mod=true
							end
						end
						if mod then
							return old(self,table.unpack(args))
						end
					end
				end
				return old(self,...)
			end))
		end)
		if ok then print("[Finis] namecall hook OK — antikick+wallshot+silentaim")
		else warn("[Finis] namecall hook FAILED — executor блокирует hookmetamethod") end
	else
		warn("[Finis] hookmetamethod недоступен — анти-кик/валлшот/сайлент аим неактивны")
	end

	if hookmetamethod then
		pcall(function()
			local old=hookmetamethod(game,"__index",closure(function(self,k)
				if silentTarget and SA.enabled and (k=="Hit" or k=="Target" or k=="UnitRay") and self==Mouse then
					if k=="Hit" then
						local c=cam()
						local o=c and c.CFrame.Position or Vector3.new(0,0,0)
						local d=silentTarget.pos-o
						if d.Magnitude<0.001 then d=Vector3.new(0,0,-1) end
						return CFrame.lookAt(silentTarget.pos,silentTarget.pos+d.Unit)
					elseif k=="Target" then
						return silentTarget.part
					else
						local c=cam()
						local o=c and c.CFrame.Position or Vector3.new(0,0,0)
						local d=silentTarget.pos-o
						if d.Magnitude<0.001 then d=Vector3.new(0,0,-1) end
						return Ray.new(o,d.Unit)
					end
				end
				return old(self,k)
			end))
		end)
	end

	R.RenderStepped:Connect(function()
		if SA.enabled then
			local t=acquireTarget(SA.fov,true,SA.wall,SA.bone)
			if t then
				local ping=LP:GetNetworkPing()
				silentTarget={plr=t.plr,char=t.char,part=t.part,pos=predictPart(t.part,SA.pred+ping)}
			else
				silentTarget=nil
			end
		else
			silentTarget=nil
		end

		if AB.enabled then
			local t=nil
			if AB.lock and aimLockPlr then
				local ch=aimLockPlr.Character
				local hum=ch and ch:FindFirstChildOfClass("Humanoid")
				if ch and hum and hum.Health>0 then
					local part=getBonePart(ch,AB.bone)
					local c=cam()
					if part and c then
						local sp,on=c:WorldToViewportPoint(part.Position)
						if on and sp.Z>0 then
							local d=(Vector2.new(sp.X,sp.Y)-Vector2.new(c.ViewportSize.X*0.5,c.ViewportSize.Y*0.5)).Magnitude
							if d<AB.fov*1.8 and (not AB.wall or partVisible(part,ch)) then
								t={plr=aimLockPlr,char=ch,part=part}
							end
						end
					end
				else
					aimLockPlr=nil
				end
			end
			if not t then t=acquireTarget(AB.fov,false,AB.wall,AB.bone) end
			if t then
				aimLockPlr=t.plr
				local c=cam()
				if c then
					local ping=LP:GetNetworkPing()
					local pos=predictPart(t.part,AB.pred+ping)
					local goal=CFrame.lookAt(c.CFrame.Position,pos)
					local a=math.clamp(AB.smooth,0.05,1)
					if a>=0.99 then c.CFrame=goal else c.CFrame=c.CFrame:Lerp(goal,a) end
				end
			end
		end

		local r=0
		if CB.tb then r=math.max(r,CB.tbFov) end
		if AB.enabled then r=math.max(r,AB.fov) end
		if SA.enabled then r=math.max(r,SA.fov) end
		FOV.Visible=r>0 and CB.showFov
		if r>0 then FOV.Size=UDim2.fromOffset(r*2,r*2) end
	end)

	-- HITBOX
	local hbOrig={}
	task.spawn(function()
		while G and G.Parent do
			if HB.enabled then
				for _,p in ipairs(P:GetPlayers()) do
					if p~=LP and isEnemy(p) then
						local ch=p.Character
						if ch then
							local targets={}
							if HB.part=="All" then
								for _,d in ipairs(ch:GetChildren()) do
									if d:IsA("BasePart") then table.insert(targets,d) end
								end
							else
								local prt=ch:FindFirstChild(HB.part)
								if prt and prt:IsA("BasePart") then table.insert(targets,prt) end
							end
							for _,prt in ipairs(targets) do
								if not hbOrig[prt] then
									hbOrig[prt]={size=prt.Size,tr=prt.Transparency,color=prt.Color,mat=prt.Material,vis=false}
								end
								local o=hbOrig[prt]
								pcall(function() prt.Size=Vector3.new(HB.size,HB.size,HB.size) end)
								if HB.show and not o.vis then
									o.vis=true
									pcall(function()
										prt.Transparency=0.65
										prt.Color=Color3.fromRGB(255,60,60)
										prt.Material=Enum.Material.Neon
									end)
								elseif not HB.show and o.vis then
									o.vis=false
									pcall(function()
										prt.Transparency=o.tr
										prt.Color=o.color
										prt.Material=o.mat
									end)
								end
							end
						end
					end
				end
			end
			for prt,orig in pairs(hbOrig) do
				if not prt.Parent then
					hbOrig[prt]=nil
				elseif not HB.enabled then
					pcall(function()
						prt.Size=orig.size
						prt.Transparency=orig.tr
						prt.Color=orig.color
						prt.Material=orig.mat
					end)
					hbOrig[prt]=nil
				end
			end
			task.wait(0.3)
		end
	end)

	-- TRIGGERBOT
	local lastF=0
	R.Heartbeat:Connect(function()
		local ch=LP.Character
		if not ch then return end
		local h=ch:FindFirstChildOfClass("Humanoid")
		if not h or h.Health<=0 then return end
		if CB.tb then
			local t=getAny and getAny(CB.tbFov)
			if t and t.h then
				if CB.tbAim then
					local c=cam()
					if c then
						c.CFrame=c.CFrame:Lerp(CFrame.lookAt(c.CFrame.Position,t.h.Position),0.4)
					end
				end
				local tool=ch:FindFirstChildOfClass("Tool")
				local n=os.clock()
				if tool and n-lastF>=CB.tbDel then
					lastF=n
					local myH=ch:FindFirstChild("HumanoidRootPart")
					local dist=0
					if myH and t.r then dist=(myH.Position-t.r.Position).Magnitude end
					rememberShot(t.plr, tool.Name or "unknown", dist)
					pcall(function() tool:Activate() end)
				end
			end
		end
	end)
end)

safe("Tracer + tools", function()
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
		tw(part,0.7,{Transparency=1})
		task.delay(0.75,function() if part and part.Parent then part:Destroy() end end)
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
			playGunSound()
			if not CB.tb then
				local myCh=LP.Character
				local myH=myCh and myCh:FindFirstChild("HumanoidRootPart")
				if myH and getAny then
					local tgt=getAny(5000)
					if tgt and tgt.plr then
						rememberShot(tgt.plr,t.Name or "unknown",(myH.Position-tgt.r.Position).Magnitude)
					end
				end
			end
			if CB.tracer then
				local f=getMuzzle()
				if f then task.spawn(function() drawTracer(f,LP:GetMouse().Hit.Position) end) end
			end
			if CB.fastSwitch then task.delay(CB.fsDelay,function() pcall(fastSwitchWeapon) end) end
		end)
	end
	local function installTools(ch)
		if not ch then return end
		for _,c in ipairs(ch:GetDescendants()) do if c:IsA("Tool") then hookT(c) end end
		ch.ChildAdded:Connect(function(c) if c:IsA("Tool") then task.wait(0.05) hookT(c) end end)
	end
	if LP.Character then installTools(LP.Character) end
	LP.CharacterAdded:Connect(function(ch) task.wait(0.3) installTools(ch) end)
	local function hookBP(bp)
		if not bp then return end
		for _,c in ipairs(bp:GetChildren()) do if c:IsA("Tool") then hookT(c) end end
		bp.ChildAdded:Connect(function(c) if c:IsA("Tool") then task.wait(0.05) hookT(c) end end)
	end
	hookBP(LP:FindFirstChild("Backpack"))
	LP.ChildAdded:Connect(function(c) if c.Name=="Backpack" then hookBP(c) end end)
end)

safe("Ammo + burst", function()
	local function isAmmoName(n)
		n=string.lower(n)
		return n:find("ammo",1,true)~=nil or n:find("magazine",1,true)~=nil or n:find("clip",1,true)~=nil
			or n:find("bullet",1,true)~=nil or n:find("shell",1,true)~=nil or n:find("shot",1,true)~=nil
	end
	local function isReloadName(n)
		return string.lower(n):find("reload",1,true)~=nil
	end

	findAmmoValue=function(tool)
		if not tool then return nil end
		for _,d in ipairs(tool:GetDescendants()) do
			if (d:IsA("IntValue") or d:IsA("NumberValue")) and isAmmoName(d.Name) then return d end
		end
		return nil
	end

	ammoDiag=function()
		local found=0
		local ch=LP.Character
		local bp=LP:FindFirstChild("Backpack")
		for _,root in ipairs({ch,bp}) do
			if root then
				for _,d in ipairs(root:GetDescendants()) do
					if (d:IsA("IntValue") or d:IsA("NumberValue")) and isAmmoName(d.Name) then
						found=found+1
						print("  -> "..d:GetFullName())
					end
				end
			end
		end
		if found>0 then print("[Finis] ammo detected: "..found.." values")
		else warn("[Finis] ammo NOT FOUND — игра считает патроны на сервере, клиентский фриз не применится") end
	end

	local lastSwap=0
	local function swapBypass(tool)
		if os.clock()-lastSwap<0.6 then return end
		lastSwap=os.clock()
		local ch=LP.Character
		local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if not h or not tool or not tool.Parent then return end
		pcall(function()
			h:UnequipTools()
			task.wait(0.06)
			h:EquipTool(tool)
		end)
	end

	task.spawn(function()
		while G and G.Parent do
			if CB.ammo or CB.noreload then
				local ch=LP.Character
				local bp=LP:FindFirstChild("Backpack")
				local roots={}
				if ch then table.insert(roots,ch) end
				if bp then table.insert(roots,bp) end
				for _,root in ipairs(roots) do
					for _,d in ipairs(root:GetDescendants()) do
						if d:IsA("Tool") then
							if CB.ammo then
								for k,v in pairs(d:GetAttributes()) do
									if typeof(v)=="number" and isAmmoName(k) and v<AMMO.value then
										pcall(function() d:SetAttribute(k,AMMO.value) end)
									end
								end
							end
							if CB.noreload then
								for k,v in pairs(d:GetAttributes()) do
									if isReloadName(k) then
										if typeof(v)=="boolean" and v then
											pcall(function() d:SetAttribute(k,false) end)
										elseif typeof(v)=="number" and v>0 then
											pcall(function() d:SetAttribute(k,0) end)
										end
									end
								end
							end
						elseif d:IsA("IntValue") or d:IsA("NumberValue") then
							if CB.ammo and isAmmoName(d.Name) and d.Value<AMMO.value then
								pcall(function() d.Value=AMMO.value end)
							end
							if CB.noreload and isReloadName(d.Name) and d.Value>0 then
								pcall(function() d.Value=0 end)
							end
						elseif d:IsA("BoolValue") then
							if CB.noreload and isReloadName(d.Name) and d.Value then
								pcall(function() d.Value=false end)
							end
						end
					end
				end
				if CB.noreload and AMMO.swap and ch then
					local tool=ch:FindFirstChildOfClass("Tool")
					if tool then
						local av=findAmmoValue(tool)
						if av and av.Value<=AMMO.threshold then
							task.spawn(swapBypass,tool)
						end
					end
				end
			end
			task.wait(0.2)
		end
	end)

	burstFire=function()
		if BR.busy then return end
		local ch=LP.Character
		local tool=ch and ch:FindFirstChildOfClass("Tool")
		if not tool then return end
		BR.busy=true
		task.spawn(function()
			local av=findAmmoValue(tool)
			local count=av and av.Value or 35
			count=math.clamp(count,1,60)
			local delay=1/math.clamp(BR.rate,5,50)
			local fired=0
			for i=1,count do
				local c2=LP.Character
				if not c2 then break end
				if c2:FindFirstChildOfClass("Tool")~=tool then break end
				local av2=findAmmoValue(tool)
				if av2 and av2.Value<=0 and fired>0 then break end
				pcall(function() tool:Activate() end)
				fired=fired+1
				task.wait(delay)
			end
			BR.busy=false
			pcall(function() SG:SetCore("SendNotification",{Title="Finis",Text="burst: "..fired.." shots",Duration=1.5}) end)
		end)
	end
end)

-- =========================================================
-- PAGES — каждая в своей капсуле
-- =========================================================
safe("page Visuals", function()
	local p=NP.Visuals
	addSec(p,1,"sec_esp")
	local c=addCard(p,2)
	local w1=addToggle(c,1,"esp_en","",false,function(o) CB.esp=o end)
	bind("esp",function() return CB.esp end,function(v) w1.set(v) end)
	local w2=addToggle(c,2,"esp_wall","",true,function(o) CB.espWall=o end)
	bind("esp_wall",function() return CB.espWall end,function(v) w2.set(v) end)
	local w3=addToggle(c,3,"esp_txt","",true,function(o) CB.espText=o end)
	bind("esp_text",function() return CB.espText end,function(v) w3.set(v) end)
	local w4=addToggle(c,4,"esp_hp","",true,function(o) CB.espHP=o end)
	bind("esp_hp",function() return CB.espHP end,function(v) w4.set(v) end)
	local w6=addSlider(c,5,"esp_arad",60,300,165," px",function(v) CB.arrowRad=math.floor(v+.5) end)
	bind("arrow_rad",function() return CB.arrowRad end,function(v) w6.set(v) end)
	local w7=addSelector(c,6,"esp_col",{"Pink","Red","Blue","Green","Purple","Yellow","Cyan","White"},
		{"Pink","Red","Blue","Green","Purple","Yellow","Cyan","White"},1,function(v) CB.espCol=v end)
	bind("esp_col",function() return CB.espCol end,function(v) w7.set(v) end)
	local w8=addSelector(c,7,"esp_style",{"Chams","Outline","Both","Skeleton","Corners","Box","All"},
		{"Chams","Outline","Both","Skeleton","Corners","Box","All"},1,function(v) CB.espStyle=v end)
	bind("esp_style",function() return CB.espStyle end,function(v) w8.set(v) end)
	local w9=addSelector(c,8,"esp_enemy",{"Auto","Team","All"},{"Auto","Team","All"},1,function(v) CB.enemy=v end)
	bind("enemy",function() return CB.enemy end,function(v) w9.set(v) end)

	addSec(p,3,"sec_tracer")
	local c2=addCard(p,4)
	local wt1=addToggle(c2,1,"tr_en","",false,function(o) CB.tracer=o end)
	bind("tracer",function() return CB.tracer end,function(v) wt1.set(v) end)

	addSec(p,5,"sec_kill")
	local c3=addCard(p,6)
	local wk1=addToggle(c3,1,"kf_kill","",true,function(o) CB.killMsg=o end)
	bind("kill_msg",function() return CB.killMsg end,function(v) wk1.set(v) end)
	local wk2=addToggle(c3,2,"kf_dmg","",false,function(o) CB.dmgMsg=o end)
	bind("dmg_msg",function() return CB.dmgMsg end,function(v) wk2.set(v) end)
end)

safe("page AimBot", function()
	local p=NP.AimBot
	addSec(p,1,"sec_aimbot")
	local c0=addCard(p,2)
	local a1=addToggle(c0,1,"ab_en","",false,function(o) AB.enabled=o if not o then aimLockPlr=nil end end)
	bind("ab_enabled",function() return AB.enabled end,function(v) a1.set(v) end)
	local a2=addSlider(c0,2,"ab_fov",30,600,180," px",function(v) AB.fov=math.floor(v+.5) end)
	bind("ab_fov",function() return AB.fov end,function(v) a2.set(v) end)
	local a3=addSlider(c0,3,"ab_smooth",5,100,45,"%",function(v) AB.smooth=math.floor(v+.5)/100 end)
	bind("ab_smooth",function() return AB.smooth*100 end,function(v) a3.set(v) end)
	local a4=addSelector(c0,4,"ab_bone",{"Head","Torso","HumanoidRootPart","Random"},
		{"bone_head","bone_torso","bone_root","bone_random"},1,function(v) AB.bone=v end)
	bind("ab_bone",function() return AB.bone end,function(v) a4.set(v) end)
	local a5=addToggle(c0,5,"ab_wall","",false,function(o) AB.wall=o end)
	bind("ab_wall",function() return AB.wall end,function(v) a5.set(v) end)
	local a7=addToggle(c0,6,"ab_lock","",true,function(o) AB.lock=o end)
	bind("ab_lock",function() return AB.lock end,function(v) a7.set(v) end)

	addSec(p,3,"sec_silent")
	local c1=addCard(p,4)
	local s1=addToggle(c1,1,"sa_en","",false,function(o) SA.enabled=o if not o then silentTarget=nil end end)
	bind("sa_enabled",function() return SA.enabled end,function(v) s1.set(v) end)
	local s2=addSlider(c1,2,"sa_fov",30,800,200," px",function(v) SA.fov=math.floor(v+.5) end)
	bind("sa_fov",function() return SA.fov end,function(v) s2.set(v) end)
	local s3=addSelector(c1,3,"sa_bone",{"Head","Torso","HumanoidRootPart","Random"},
		{"bone_head","bone_torso","bone_root","bone_random"},1,function(v) SA.bone=v end)
	bind("sa_bone",function() return SA.bone end,function(v) s3.set(v) end)
	local s4=addToggle(c1,4,"sa_wall","",false,function(o) SA.wall=o end)
	bind("sa_wall",function() return SA.wall end,function(v) s4.set(v) end)
	local s5=addSlider(c1,5,"sa_chance",1,100,100,"%",function(v) SA.chance=math.floor(v+.5) end)
	bind("sa_chance",function() return SA.chance end,function(v) s5.set(v) end)
	local s7=addSelector(c1,6,"sa_mode",{"Smart","All"},{"sa_smart","sa_all"},1,function(v) SA.mode=v end)
	bind("sa_mode",function() return SA.mode end,function(v) s7.set(v) end)

	addSec(p,5,"sec_trigger")
	local c=addCard(p,6)
	local t1=addToggle(c,1,"t_on","tg_en",false,function(o) CB.tb=o end)
	bind("trigger",function() return CB.tb end,function(v) t1.set(v) end)
	local t2=addToggle(c,2,"t_on","tg_aim",false,function(o) CB.tbAim=o end)
	bind("trigger_aim",function() return CB.tbAim end,function(v) t2.set(v) end)
	local t3=addSlider(c,3,"tg_fov",40,500,140," px",function(v) CB.tbFov=v end)
	bind("tg_fov",function() return CB.tbFov end,function(v) t3.set(v) end)
	local t4=addSlider(c,4,"tg_delay",200,900,350," ms",function(v) CB.tbDel=v/1000 end)
	bind("tg_delay",function() return CB.tbDel*1000 end,function(v) t4.set(v) end)

	addSec(p,7,"sec_spin")
	local c2=addCard(p,8)
	local sp1=addToggle(c2,1,"t_on","sp_en",false,function(o)
		CB.spin=o
		local ch=LP.Character local h=ch and ch:FindFirstChildOfClass("Humanoid")
		if h then h.AutoRotate=not o end
	end)
	bind("spin",function() return CB.spin end,function(v) sp1.set(v) end)
	local sp2=addSlider(c2,2,"sp_speed",60,900,180," deg",function(v) CB.spinSpd=v end)
	bind("spin_speed",function() return CB.spinSpd end,function(v) sp2.set(v) end)
end)

safe("page Blatant", function()
	local p=NP.Blatant
	addSec(p,1,"sec_char")
	local c1=addCard(p,2)
	local b1=addToggle(c1,1,"ms_en","",false,function(o)
		CB.maxSpd=o
		if not o then
			local ch=LP.Character local h=ch and ch:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed=16 end
		end
	end)
	bind("speed_hack",function() return CB.maxSpd end,function(v) b1.set(v) end)
	local b2=addSlider(c1,2,"ms_val",16,30,20,"",function(v) CB.msVal=math.floor(v+.5) end)
	bind("speed_val",function() return CB.msVal end,function(v) b2.set(v) end)
	local b3=addToggle(c1,3,"nc_en","",false,function(o) CB.noclip=o end)
	bind("noclip",function() return CB.noclip end,function(v) b3.set(v) end)
	local b4=addToggle(c1,4,"aj_en","",false,function(o) CB.air=o end)
	bind("air_jump",function() return CB.air end,function(v) b4.set(v) end)

	addSec(p,3,"sec_flight")
	local c2=addCard(p,4)
	local f1=addToggle(c2,1,"fl_en","",false,function(o) CB.fly=o end)
	bind("fly",function() return CB.fly end,function(v) f1.set(v) end)
	local f2=addSlider(c2,2,"fl_spd",10,60,30,"",function(v) CB.flySpd=math.floor(v+.5) end)
	bind("fly_speed",function() return CB.flySpd end,function(v) f2.set(v) end)
	local f3=addSelector(c2,3,"fl_mode",{"Camera","Vertical"},{"fl_cam","fl_vert"},1,function(v) CB.flyMode=v end)
	bind("fly_mode",function() return CB.flyMode end,function(v) f3.set(v) end)

	addSec(p,5,"sec_vehicle")
	local c3=addCard(p,6)
	local v1=addToggle(c3,1,"ch_en","",false,function(o) CB.carHack=o end)
	bind("car_hack",function() return CB.carHack end,function(v) v1.set(v) end)
	local v2=addSlider(c3,2,"ch_spd",50,1000,300,"",function(v) CB.carSpd=math.floor(v+.5) end)
	bind("car_speed",function() return CB.carSpd end,function(v) v2.set(v) end)

	addSec(p,7,"sec_hitbox")
	local c4=addCard(p,8)
	local h1=addToggle(c4,1,"hb_en","",false,function(o) HB.enabled=o end)
	bind("hb_enabled",function() return HB.enabled end,function(v) h1.set(v) end)
	local h2=addSlider(c4,2,"hb_size",2,50,8,"",function(v) HB.size=math.floor(v+.5) end)
	bind("hb_size",function() return HB.size end,function(v) h2.set(v) end)
	local h3=addSelector(c4,3,"hb_part",{"HumanoidRootPart","Head","All"},{"hb_hrp","hb_head","hb_all"},1,function(v) HB.part=v end)
	bind("hb_part",function() return HB.part end,function(v) h3.set(v) end)
	local h4=addToggle(c4,4,"hb_show","",false,function(o) HB.show=o end)
	bind("hb_show",function() return HB.show end,function(v) h4.set(v) end)
end)

safe("page Guns", function()
	local p=NP.Guns
	addSec(p,1,"sec_ammo")
	local c1=addCard(p,2)
	local m1=addToggle(c1,1,"am_en","",false,function(o) CB.ammo=o if o then task.spawn(ammoDiag) end end)
	bind("ammo",function() return CB.ammo end,function(v) m1.set(v) end)
	local m2=addToggle(c1,2,"nr_en","",false,function(o) CB.noreload=o if o then task.spawn(ammoDiag) end end)
	bind("noreload",function() return CB.noreload end,function(v) m2.set(v) end)
	local m3=addSlider(c1,3,"am_val",10,99999,9999,"",function(v) AMMO.value=math.floor(v+.5) end)
	bind("ammo_value",function() return AMMO.value end,function(v) m3.set(v) end)
	local m4=addToggle(c1,4,"am_swap","",true,function(o) AMMO.swap=o end)
	bind("ammo_swap",function() return AMMO.swap end,function(v) m4.set(v) end)
	local m5=addSlider(c1,5,"am_thresh",0,20,2,"",function(v) AMMO.threshold=math.floor(v+.5) end)
	bind("ammo_thresh",function() return AMMO.threshold end,function(v) m5.set(v) end)

	addSec(p,3,"sec_burst")
	local cb_=addCard(p,4)
	addBtn(cb_,1,"burst_fire",function() task.spawn(burstFire) end)
	local br1=addSlider(cb_,2,"burst_rate",10,40,30,"",function(v) BR.rate=math.floor(v+.5) end)
	bind("burst_rate",function() return BR.rate end,function(v) br1.set(v) end)

	addSec(p,5,"sec_wall")
	local cw=addCard(p,6)
	local ws1=addToggle(cw,1,"ws_en","",false,function(o) WS.enabled=o end)
	bind("wallshot",function() return WS.enabled end,function(v) ws1.set(v) end)
	local ws2=addToggle(cw,2,"ws_npc","",true,function(o) WS.npc=o end)
	bind("wallshot_npc",function() return WS.npc end,function(v) ws2.set(v) end)

	addSec(p,7,"sec_fswitch")
	local c2=addCard(p,8)
	local fs1=addToggle(c2,1,"fs_en","",false,function(o) CB.fastSwitch=o end)
	bind("fast_switch",function() return CB.fastSwitch end,function(v) fs1.set(v) end)
	local fs2=addSlider(c2,2,"fs_delay",0,500,50," ms",function(v) CB.fsDelay=v/1000 end)
	bind("fs_delay",function() return CB.fsDelay*1000 end,function(v) fs2.set(v) end)

	addSec(p,9,"sec_sound")
	local c3=addCard(p,10)
	local sn1=addToggle(c3,1,"snd_en","",false,function(o) CB.gunSound=o end)
	bind("gun_sound",function() return CB.gunSound end,function(v) sn1.set(v) end)
	addBtn(c3,2,"snd_test",function() playGunSound(true) end)
end)

-- CONFIG SYSTEM
local CFG_DIR="FinisHub"
local cfgOK=false
pcall(function()
	if writefile and readfile and isfolder and makefolder then
		if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
		cfgOK=true
	end
end)
if not cfgOK then
	pcall(function()
		if writefile and readfile and isfile then cfgOK=true end
	end)
end

local function cfgPath(name) return CFG_DIR.."/"..name..".json" end

local function listConfigs()
	local names={}
	if not cfgOK then return names end
	local ok,res=pcall(function() return listfiles(CFG_DIR) end)
	if ok and type(res)=="table" then
		for _,f in ipairs(res) do
			local n=string.match(f,"([^/\\]+)%.json$")
			if n and string.sub(n,1,1)~="_" then table.insert(names,n) end
		end
	end
	table.sort(names)
	return names
end

local function applyConfig(data)
	if type(data)~="table" then return false end
	for _,b in ipairs(SYNC) do
		if b.load then pcall(b.load,false) end
	end
	for _,b in ipairs(SYNC) do
		local v=data[b.key]
		if v~=nil then pcall(b.load,v) end
	end
	refreshLang()
	return true
end

local function saveConfig(name)
	if not cfgOK then return false end
	local data={}
	for _,b in ipairs(SYNC) do
		local ok,v=pcall(b.save)
		if ok and v~=nil then data[b.key]=v end
	end
	local ok=pcall(writefile,cfgPath(name),HS:JSONEncode(data))
	return ok
end

local function loadConfig(name)
	if not cfgOK then return false end
	local ok,c=pcall(readfile,cfgPath(name))
	if not ok or not c then return false end
	local okd,d=pcall(function() return HS:JSONDecode(c) end)
	if not okd or type(d)~="table" then return false end
	return applyConfig(d)
end

local function deleteConfig(name)
	if not cfgOK then return false end
	return pcall(function() delfile(cfgPath(name)) end)
end

local function persistAutoload()
	if not cfgOK then return end
	pcall(writefile,CFG_DIR.."/_autoload.json",HS:JSONEncode({enabled=AL.enabled,name=AL.name}))
end

safe("page Misc + cfg UI", function()
	local p=NP.Misc
	addSec(p,1,"sec_ui")
	local c1=addCard(p,2)
	local u1=addSlider(c1,1,"ui_scale",60,150,100,"%",function(v) CB.uiScale=v/100 MSC.Scale=CB.uiScale end)
	bind("ui_scale",function() return CB.uiScale*100 end,function(v) u1.set(v) end)
	local u2=addToggle(c1,2,"fov_circle","",true,function(o) CB.showFov=o end)
	bind("show_fov",function() return CB.showFov end,function(v) u2.set(v) end)

	addSec(p,3,"sec_cfg")
	local cc=addCard(p,4)

	if cfgOK then
		local nameBox=mk("TextBox",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(28,28,34),
			BorderSizePixel=0,Text="",PlaceholderText=TR("cfg_name"),Font=Enum.Font.Gotham,TextSize=13,
			TextColor3=TX,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,ZIndex=905},cc)
		uc(nameBox,8) sk(nameBox,BD,1,0.2)
		mk("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},nameBox)

		local listScroll=mk("ScrollingFrame",{Size=UDim2.new(1,0,0,120),BackgroundTransparency=1,BorderSizePixel=0,
			ScrollBarThickness=2,CanvasSize=UDim2.new(0,0,0,0),LayoutOrder=2,ZIndex=904},cc)
		local lls=mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},listScroll)

		local cfgSel=nil
		local listBtns={}
		local function refreshCfgList()
			for _,b in ipairs(listBtns) do
				if b.Parent then b:Destroy() end
			end
			listBtns={}
			local names=listConfigs()
			for i,n in ipairs(names) do
				local isSel=(n==cfgSel)
				local btn=mk("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=isSel and Color3.fromRGB(0,120,150) or Color3.fromRGB(28,28,34),
					BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,ZIndex=905},listScroll)
				uc(btn,8)
				sk(btn,isSel and AC or BD,1,0.2)
				mk("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
					Font=Enum.Font.GothamMedium,Text=n,TextColor3=isSel and WT or TX,TextSize=12,
					TextXAlignment=Enum.TextXAlignment.Left,ZIndex=906},btn)
				btn.MouseButton1Click:Connect(function()
					cfgSel=n
					nameBox.Text=n
					refreshCfgList()
				end)
				table.insert(listBtns,btn)
			end
			listScroll.CanvasSize=UDim2.new(0,0,0,lls.AbsoluteContentSize.Y+4)
		end

		addBtn(cc,3,"cfg_save",function()
			local n=nameBox.Text
			if n=="" or string.match(n,"[^%w_%- ]") then return end
			if saveConfig(n) then
				cfgSel=n
				refreshCfgList()
				pcall(function() SG:SetCore("SendNotification",{Title="Finis",Text=n.." saved",Duration=2}) end)
			end
		end)
		addBtn(cc,4,"cfg_load",function()
			local n=nameBox.Text
			if n=="" then return end
			if loadConfig(n) then
				cfgSel=n
				AL.name=n
				persistAutoload()
				refreshCfgList()
				pcall(function() SG:SetCore("SendNotification",{Title="Finis",Text=n.." loaded",Duration=2}) end)
			end
		end)
		addBtn(cc,5,"cfg_delete",function()
			local n=nameBox.Text
			if n=="" then return end
			if deleteConfig(n) then
				if cfgSel==n then cfgSel=nil end
				refreshCfgList()
			end
		end)

		alToggle=addToggle(cc,6,"cfg_auto","",false,function(o)
			AL.enabled=o
			if nameBox.Text~="" then AL.name=nameBox.Text end
			persistAutoload()
		end)

		refreshCfgList()
	else
		local nl=mk("TextLabel",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Font=Enum.Font.Gotham,
			Text=TR("cfg_none"),TextColor3=TD,TextSize=12,TextWrapped=true,LayoutOrder=1,ZIndex=905},cc)
	end

	addSec(p,5,"sec_prot")
	local cp=addCard(p,6)
	local ak1=addToggle(cp,1,"ak_en","",true,function(o) AK.enabled=o end)
	bind("anti_kick",function() return AK.enabled end,function(v) ak1.set(v) end)

	addSec(p,7,"sec_lang")
	local c2=addCard(p,8)
	local lg1=addSelector(c2,1,"lang_choose",{"en","ru"},{"English","Русский"},1,function(v)
		Lang=v
		refreshLang()
	end)
	bind("lang",function() return Lang end,function(v) lg1.set(v) end)
end)

safe("hotkeys + nav", function()
	local function switchPage(n)
		if n==SEL and CURR and CURR.Visible then return end
		SEL=n
		for pn,pg in pairs(NP) do
			if pg and pn~=n and pg.Visible then pg.Visible=false end
		end
		for nm,o in pairs(NB) do
			local s=(nm==n)
			tw(o.lbl,0.45,{TextColor3=s and TX or TD})
			o.lbl.Font=s and Enum.Font.GothamBold or Enum.Font.GothamMedium
			tw(o.ul,TweenInfo.new(0.55,Enum.EasingStyle.Back),{Size=UDim2.new(s and 0.45 or 0,0,0,3)})
		end
		local np=NP[n]
		if np then
			np.Position=UDim2.fromOffset(0,22)
			np.Visible=true
			tw(np,TweenInfo.new(0.55,Enum.EasingStyle.Quart),{Position=UDim2.fromOffset(0,0)})
			CURR=np
		end
	end
	for nm,d in pairs(NB) do
		d.btn.MouseButton1Click:Connect(function() switchPage(nm) end)
	end

	U.InputBegan:Connect(function(input,gp)
		if not introDone then
			killIntro()
			return
		end
		if gp then return end
		if input.KeyCode==Enum.KeyCode.RightShift then
			if menuOpen then closeMenu() else openMenu() end
		end
		if input.KeyCode==Enum.KeyCode.F then
			CB.fly=not CB.fly
			pcall(function() SG:SetCore("SendNotification",{Title="Fly",Text=CB.fly and "ON" or "OFF",Duration=2}) end)
		end
		if input.KeyCode==Enum.KeyCode.G then
			task.spawn(burstFire)
		end
	end)
end)

-- AUTOLOAD
if cfgOK then
	pcall(function()
		local c=readfile(CFG_DIR.."/_autoload.json")
		local d=HS:JSONDecode(c)
		if d.enabled and d.name then
			if loadConfig(d.name) then
				AL.enabled=true AL.name=d.name
				if alToggle then alToggle.set(true) end
				print("[Finis] autoload: "..d.name)
			end
		end
	end)
end

if getgenv then
	getgenv().FinisHub={Combat=CB,Aimbot=AB,SilentAim=SA,Hitbox=HB,Ammo=AMMO,Wallshot=WS,Burst=BR,AntiKick=AK,
		GUI=G,Main=MENU,
		OpenMenu=openMenu,CloseMenu=closeMenu,
		TestSound=function() playGunSound(true) end,
		BurstFire=burstFire,
		SaveConfig=saveConfig,LoadConfig=loadConfig,DeleteConfig=deleteConfig,ListConfigs=listConfigs}
	getgenv().FinisToggleMenu=function()
		if menuOpen then closeMenu() else openMenu() end
	end
end

print("[Finis] v10 FULLY LOADED — RSHIFT=menu, F=fly, G=burst")
print("[Finis] если этой строки нет в консоли — файл скопировался не целиком, копируй заново")
