-- ============================================================
-- KIRIESHKA DLC v9.6 OPTIMIZED
-- ============================================================
local _G_FLAG_KEY = ""
do
    local uid = tostring(game:GetService("Players").LocalPlayer.UserId)
    _G_FLAG_KEY = string.reverse(uid).."_sys"
    if rawget(getgenv(),_G_FLAG_KEY) then return end
    rawset(getgenv(),_G_FLAG_KEY,os.clock())
end

local _S = setmetatable({},{__index=function(t,k)
    local ok,s=pcall(game.GetService,game,k)
    if ok then rawset(t,k,s) return s end
end})

local Players,UIS,TS,RS,HttpService = _S.Players,_S.UserInputService,_S.TweenService,_S.RunService,_S.HttpService
local LP,Cam,Mouse = Players.LocalPlayer,workspace.CurrentCamera,Players.LocalPlayer:GetMouse()

-- SafeClick
local SafeClick = {}
do
    if mouse1click then
        SafeClick.Click = function() pcall(mouse1click) end
    else
        local ok,VI = pcall(function() return game:GetService("VirtualInputManager") end)
        if ok and VI then
            SafeClick.Click = function(pos)
                pcall(function()
                    VI:SendMouseButtonEvent(math.floor(pos.X),math.floor(pos.Y),0,true,game,0)
                    task.wait(1/60)
                    VI:SendMouseButtonEvent(math.floor(pos.X),math.floor(pos.Y),0,false,game,0)
                end)
            end
        else
            SafeClick.Click = function() end
        end
    end
end

-- SA Override
local SAOverride = {enabled=false,hitPos=nil,target=nil,unitRay=nil}
local _mousePatched = false
local _origMouseIndex = nil
local function SafePatchMouse()
    if _mousePatched then return end
    pcall(function()
        local mt = getrawmetatable(Mouse)
        if not mt then return end
        local orig = rawget(mt,"__index")
        if type(orig)~="function" then return end
        _origMouseIndex = orig
        setreadonly(mt,false)
        rawset(mt,"__index",function(self,key)
            if SAOverride.enabled and SAOverride.hitPos then
                if key=="Hit" then return SAOverride.hitPos end
                if key=="UnitRay" then return SAOverride.unitRay end
                if key=="Target" then return SAOverride.target end
            end
            return _origMouseIndex(self,key)
        end)
        setreadonly(mt,true)
        _mousePatched = true
    end)
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = tostring(math.random()):sub(3,12)
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 999
local _cgOk = pcall(function() GUI.Parent = _S.CoreGui end)
if not _cgOk or not GUI.Parent then GUI.Parent = LP:WaitForChild("PlayerGui") end

-- Themes
local Themes = {
    Blue = {
        BG=Color3.fromRGB(5,10,22),Header=Color3.fromRGB(4,8,18),TabBar=Color3.fromRGB(5,9,20),
        Item=Color3.fromRGB(10,18,40),Stroke=Color3.fromRGB(40,120,255),StrokeItem=Color3.fromRGB(30,90,200),
        Text=Color3.fromRGB(220,230,255),TextDim=Color3.fromRGB(130,155,210),Divider=Color3.fromRGB(20,40,90),
        TabLine=Color3.fromRGB(80,160,255),ToggleOn=Color3.fromRGB(80,160,255),ToggleOff=Color3.fromRGB(30,60,130),
        SliderFill=Color3.fromRGB(80,160,255),SliderBG=Color3.fromRGB(15,30,70),
        Button=Color3.fromRGB(12,25,58),Sep=Color3.fromRGB(100,180,255),Glow=true,
        Snow=Color3.fromRGB(60,140,255),AimFOV=Color3.fromRGB(80,160,255),
        SAFOVColor=Color3.fromRGB(100,200,255),RageFOVColor=Color3.fromRGB(255,80,80),
        CrosshairColor=Color3.fromRGB(80,160,255),
    },
    Dark = {
        BG=Color3.fromRGB(10,10,10),Header=Color3.fromRGB(7,7,7),TabBar=Color3.fromRGB(8,8,8),
        Item=Color3.fromRGB(18,18,18),Stroke=Color3.fromRGB(55,55,55),StrokeItem=Color3.fromRGB(42,42,42),
        Text=Color3.fromRGB(210,210,210),TextDim=Color3.fromRGB(130,130,130),Divider=Color3.fromRGB(32,32,32),
        TabLine=Color3.fromRGB(200,200,200),ToggleOn=Color3.fromRGB(180,180,180),ToggleOff=Color3.fromRGB(60,60,60),
        SliderFill=Color3.fromRGB(160,160,160),SliderBG=Color3.fromRGB(30,30,30),
        Button=Color3.fromRGB(22,22,22),Sep=Color3.fromRGB(150,150,150),Glow=false,
        Snow=Color3.fromRGB(70,70,70),AimFOV=Color3.fromRGB(180,180,180),
        SAFOVColor=Color3.fromRGB(200,200,200),RageFOVColor=Color3.fromRGB(255,80,80),
        CrosshairColor=Color3.fromRGB(200,200,200),
    },
    White = {
        BG=Color3.fromRGB(245,245,245),Header=Color3.fromRGB(230,230,230),TabBar=Color3.fromRGB(235,235,235),
        Item=Color3.fromRGB(252,252,252),Stroke=Color3.fromRGB(0,120,255),StrokeItem=Color3.fromRGB(0,100,220),
        Text=Color3.fromRGB(20,20,20),TextDim=Color3.fromRGB(100,100,100),Divider=Color3.fromRGB(210,210,210),
        TabLine=Color3.fromRGB(0,120,255),ToggleOn=Color3.fromRGB(0,120,255),ToggleOff=Color3.fromRGB(180,180,180),
        SliderFill=Color3.fromRGB(0,120,255),SliderBG=Color3.fromRGB(210,210,210),
        Button=Color3.fromRGB(232,232,232),Sep=Color3.fromRGB(0,120,255),Glow=true,
        Snow=Color3.fromRGB(0,120,255),AimFOV=Color3.fromRGB(0,120,255),
        SAFOVColor=Color3.fromRGB(0,150,255),RageFOVColor=Color3.fromRGB(220,50,50),
        CrosshairColor=Color3.fromRGB(0,120,255),
    },
}
local ThemeState = {Current="Blue",T=Themes.Blue,Themed={},GlowStrokes={},Snow={}}
local T = ThemeState.T

local function Reg(obj,prop,key)
    table.insert(ThemeState.Themed,{obj=obj,prop=prop,key=key})
    return obj
end

-- Database
local DB_KEY = "KDLC96"
local WL_KEY = DB_KEY.."_wl"
local PERM_KEY = DB_KEY.."_perm"
local DB = {
    Sliders = {
        AimbotSmooth=10,HitChance=100,AimFOV=200,SAFOV=150,
        Speed=30,FlySpeed=60,AntiAFKInterval=30,ZoomFOV=70,
        RageFOV=300,RageSmooth=1,AntiAimOffset=180,
        LocalChamsTransp=30,ESPBoxThick=20,LCV2Transp=30,
        ThirdPersonDist=10,ESPBoxR=80,ESPBoxG=160,ESPBoxB=255,
        ESPAllyR=60,ESPAllyG=200,ESPAllyB=100,
        LCV2R=255,LCV2G=100,LCV2B=50,
        DesyncIntensity=50,DesyncSpeed=100,
        AimMaxDistance=500,AimReactionTime=0,AimShakeAmount=0,
    },
    Toggles = {},
    Settings = {
        AimType="Hold",SAMethod="Mouse",Theme="Blue",Language="ENG",
        CrosshairStyle="DOT",SpeedType="Hold",FlyType="Hold",
        FreeCamType="Hold",ZoomType="Hold",AimMode="Smooth",
        RageHitPart="Head",AimHitPart="Head",SABone="Head",
        LocalChamsStyle="Outline",LCV2Style="Filled",
        ThirdPersonType="Toggle",DesyncType="Toggle",
    },
}

local function DBSave() pcall(function() writefile(DB_KEY,HttpService:JSONEncode(DB)) end) end
local function DBLoad()
    pcall(function()
        if not(isfile and isfile(DB_KEY)) then return end
        local ok,r = pcall(function() return HttpService:JSONDecode(readfile(DB_KEY)) end)
        if ok and r then
            for k,v in pairs(r.Sliders or {}) do DB.Sliders[k]=v end
            for k,v in pairs(r.Toggles or {}) do DB.Toggles[k]=v end
            for k,v in pairs(r.Settings or {}) do DB.Settings[k]=v end
        end
    end)
end

-- ====== PERMANENT KEY SYSTEM ======
local function GenPermKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key = ""
    for i=1,16 do
        key = key .. chars:sub(math.random(1,#chars),math.random(1,#chars))
    end
    return key
end
local function SavePermKey(k) pcall(function() writefile(PERM_KEY,k) end) end
local function LoadPermKey()
    local k = nil
    pcall(function() if isfile and isfile(PERM_KEY) then k = readfile(PERM_KEY) end end)
    return k
end

local function WLSave(uid) pcall(function() writefile(WL_KEY,tostring(uid)) end) end
local function WLCheck()
    local ok=false
    pcall(function() if isfile and isfile(WL_KEY) then ok=(tonumber(readfile(WL_KEY))==LP.UserId) end end)
    return ok
end
local function WLDelete() pcall(function() if isfile and isfile(WL_KEY) then delfile(WL_KEY) end end) end
local function DBDelete() pcall(function() if isfile and isfile(DB_KEY) then delfile(DB_KEY) end end) end

DBLoad()
if Themes[DB.Settings.Theme] then
    ThemeState.Current=DB.Settings.Theme
    ThemeState.T=Themes[ThemeState.Current]
    T=ThemeState.T
end

-- Lang
local Lang = {
    ENG={welcome="Welcome back!",uid="UserID: ",enterKey="Enter key...",access="ACCESS",
         invalidKey="Invalid key. (",tooMany="Too many attempts.",selfDestruct="Self-destructing in 3s...",
         permKeyGen="Your permanent key:"},
    RU ={welcome="Добро пожаловать!",uid="UserID: ",enterKey="Введите ключ...",access="ВОЙТИ",
         invalidKey="Неверный ключ. (",tooMany="Слишком много попыток.",selfDestruct="Самоуничтожение через 3 сек...",
         permKeyGen="Ваш постоянный ключ:"},
}
local L = Lang.ENG
local function SetLang(n) if Lang[n] then L=Lang[n] end end
SetLang(DB.Settings.Language)

-- HP Map
local HP_MAP = {
    Head={"Head"},Torso={"Torso","UpperTorso"},HumanoidRootPart={"HumanoidRootPart"},
    ["Left Arm"]={"Left Arm","LeftLowerArm","LeftUpperArm"},
    ["Right Arm"]={"Right Arm","RightLowerArm","RightUpperArm"},
    ["Left Leg"]={"Left Leg","LeftLowerLeg","LeftUpperLeg"},
    ["Right Leg"]={"Right Leg","RightLowerLeg","RightUpperLeg"},
}
local function FindPart(char,name)
    if not char then return nil end
    local d=char:FindFirstChild(name); if d then return d end
    local al=HP_MAP[name]
    if al then for _,a in ipairs(al) do local p=char:FindFirstChild(a) if p then return p end end end
    return char:FindFirstChild("HumanoidRootPart")
end

-- State
local S = {
    V={
        ESP=false,Box=true,Dist=true,HP=true,Name=true,Skel=false,
        Head=true,Filled=true,TeamCheck=false,ShowAvatar=false,
        LocalChams=false,LocalChamsStyle="Outline",LocalChamsTransp=0.3,
        LocalChamsColor=Color3.fromRGB(0,180,255),
        LCV2=false,LCV2Transp=0.3,LCV2Style="Filled",
        LCV2Color=Color3.fromRGB(DB.Sliders.LCV2R,DB.Sliders.LCV2G,DB.Sliders.LCV2B),
        ESPBoxColor=Color3.fromRGB(DB.Sliders.ESPBoxR,DB.Sliders.ESPBoxG,DB.Sliders.ESPBoxB),
        ESPAllyColor=Color3.fromRGB(DB.Sliders.ESPAllyR,DB.Sliders.ESPAllyG,DB.Sliders.ESPAllyB),
    },
    A={
        En=false,BindKey=nil,Type=DB.Settings.AimType,Mode=DB.Settings.AimMode or "Smooth",
        Smooth=DB.Sliders.AimbotSmooth,Sticky=false,FOV=DB.Sliders.AimFOV,
        ShowFOV=false,Predict=false,HitChance=DB.Sliders.HitChance,
        HitNotify=false,TargetHUD=false,HitPart=DB.Settings.AimHitPart or "Head",
        AutoShoot=false,NoRecoil=false,NoSpread=false,ForceAuto=false,
        SAEn=false,SAMethod=DB.Settings.SAMethod,SAFOV=DB.Sliders.SAFOV,
        SAShowFOV=false,SABone=DB.Settings.SABone or "Head",BypassMode=true,
        VisibilityCheck=false,TeamCheck=false,
        MaxDistance=DB.Sliders.AimMaxDistance or 500,
        ReactionTime=0,ShakeAmount=0,
        AimManip=false,ManipStatus="Scanning...",
    },
    R={
        En=false,AutoShoot=false,AntiAim=false,Active=false,
        FOV=DB.Sliders.RageFOV,Smooth=DB.Sliders.RageSmooth,
        AntiAimOffset=DB.Sliders.AntiAimOffset,
        NoRecoil=false,NoSpread=false,ForceAuto=false,
        ForceHeadshot=false,HitPart=DB.Settings.RageHitPart or "Head",Target=nil,
    },
    F={
        SpeedEn=false,SpeedBind=nil,SpeedType=DB.Settings.SpeedType,Speed=DB.Sliders.Speed,
        FlyEn=false,FlyBind=nil,FlyType=DB.Settings.FlyType,FlySpeed=DB.Sliders.FlySpeed,FlyActive=false,
        FreeCamEn=false,FreeCamBind=nil,FreeCamType=DB.Settings.FreeCamType,FreeCamActive=false,
        AntiAFKEn=false,AntiAFKInterval=DB.Sliders.AntiAFKInterval,
        CrosshairEn=false,CrosshairStyle=DB.Settings.CrosshairStyle,
        BindsPanelVisible=false,
        ZoomEn=false,ZoomBind=nil,ZoomType=DB.Settings.ZoomType,
        ZoomFOV=DB.Sliders.ZoomFOV,ZoomActive=false,OrigFOV=70,
        ThirdPersonEn=false,ThirdPersonBind=nil,ThirdPersonType="Toggle",
        ThirdPersonActive=false,ThirdPersonDist=DB.Sliders.ThirdPersonDist,
        DesyncEn=false,DesyncBind=nil,DesyncType="Toggle",DesyncActive=false,
        DesyncDraw=false,DesyncIntensity=0.5,DesyncSpeed=1.0,
    },
    MenuKey=Enum.KeyCode.Insert,Stream=false,Unlocked=false,
}
local AimState = {Active=false,Target=nil}

-- ====== AIM MANIPULATION SYSTEM ======
local AimManip = {Active=false,BypassFound=false,Scanning=false}
local function ScanForBypass()
    if AimManip.Scanning then return end
    AimManip.Scanning = true
    S.A.ManipStatus = "Scanning..."
    task.spawn(function()
        task.wait(math.random(15,30)/10)
        local found = false
        pcall(function()
            local char = LP.Character
            if char then
                for _,tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and math.random(1,4)==1 then
                        found = true
                        break
                    end
                end
            end
            for _,obj in ipairs(Cam:GetChildren()) do
                if obj:IsA("Model") and math.random(1,3)==1 then
                    found = true
                    break
                end
            end
        end)
        AimManip.BypassFound = found
        S.A.ManipStatus = found and "Bypass Founded" or "No bypass"
        AimManip.Scanning = false
    end)
end

-- Helpers
local function RBW(o) return Color3.fromHSV((tick()*0.3+(o or 0))%1,1,1) end
local function IsTeammate(p)
    if not S.V.TeamCheck then return false end
    local ok,r = pcall(function() return LP.Team~=nil and p.Team~=nil and LP.Team==p.Team end)
    return ok and r or false
end
local function GetESPColor(p) return IsTeammate(p) and S.V.ESPAllyColor or S.V.ESPBoxColor end
local function NewD(t) local ok,d=pcall(Drawing.new,t) return ok and d or nil end

-- Apply Theme
local FOVCirc,SAFOVCirc,RageFOVCirc

local function ApplyTheme(name)
    if not Themes[name] then return end
    ThemeState.Current=name; ThemeState.T=Themes[name]; T=ThemeState.T
    ThemeState.GlowStrokes={}
    for _,e in ipairs(ThemeState.Themed) do pcall(function() e.obj[e.prop]=T[e.key] end) end
    if T.Glow then
        for _,e in ipairs(ThemeState.Themed) do
            pcall(function()
                if e.prop=="Color" and e.obj and e.obj.Parent and e.obj:IsA("UIStroke") then
                    table.insert(ThemeState.GlowStrokes,{s=e.obj,ph=math.random()*6.28})
                end
            end)
        end
    end
    for _,v in ipairs(ThemeState.Snow) do pcall(function() v.F.BackgroundColor3=T.Snow end) end
    if FOVCirc then pcall(function() FOVCirc.Color=T.AimFOV end) end
    if SAFOVCirc then pcall(function() SAFOVCirc.Color=T.SAFOVColor end) end
    if RageFOVCirc then pcall(function() RageFOVCirc.Color=T.RageFOVColor end) end
end

RS.Heartbeat:Connect(function()
    if not T.Glow then return end
    local t=tick()
    for _,g in ipairs(ThemeState.GlowStrokes) do
        pcall(function()
            if g.s and g.s.Parent then
                local w=math.sin(t*2.5+g.ph)
                g.s.Color=Color3.fromHSV(0.58+w*0.04,0.85+w*0.1,0.95+w*0.05)
                g.s.Transparency=0.05+(1-(w*0.5+0.5))*0.35
            end
        end)
    end
end)

-- UI Helpers
local function Stroke(p,thick,key)
    local s=Instance.new("UIStroke",p)
    s.Thickness=thick or 1; s.Color=T[key or "Stroke"]; s.LineJoinMode=Enum.LineJoinMode.Miter
    Reg(s,"Color",key or "Stroke")
    if T.Glow then table.insert(ThemeState.GlowStrokes,{s=s,ph=math.random()*6.28}) end
    return s
end
local function Hover(btn,key)
    btn.MouseEnter:Connect(function()
        local b=T[key]; if not b then return end
        TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(
            math.min(b.R*255+22,255),math.min(b.G*255+22,255),math.min(b.B*255+22,255))}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if T[key] then TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=T[key]}):Play() end
    end)
end
local function Drag(frame,handle)
    handle=handle or frame
    local drag,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; dp=frame.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            frame.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
end

local function EncKey(k) local e="" for i=1,#k do e=e..string.char(bit32.bxor(string.byte(k,i),0x4B)) end return e end
local RKEY=EncKey("dobrograd")
local function ValidKey(s) 
    if EncKey(s)==RKEY then return true end
    local pk = LoadPermKey()
    if pk and s == pk then return true end
    return false
end

-- AutoShoot
local AutoShootCD=0
local function SafeAutoShoot(pos)
    if tick()-AutoShootCD<0.12 then return end; AutoShootCD=tick()
    if mouse1click then pcall(mouse1click) return end
    local ok,vi=pcall(function() return game:GetService("VirtualInputManager") end)
    if ok and vi then
        pcall(function()
            vi:SendMouseButtonEvent(math.floor(pos.X),math.floor(pos.Y),0,true,game,0)
            task.wait(1/60)
            vi:SendMouseButtonEvent(math.floor(pos.X),math.floor(pos.Y),0,false,game,0)
        end)
        return
    end
    pcall(function()
        local char=LP.Character; if not char then return end
        for _,c in ipairs(char:GetChildren()) do if c:IsA("Tool") then pcall(function() c:Activate() end) break end end
    end)
end

-- Fly
local Fly={Active=false,Conn=nil,BV=nil,BG=nil}
local function EnableFly()
    if Fly.Active then return end; Fly.Active=true; S.F.FlyActive=true
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end
    local bv=Instance.new("BodyVelocity"); bv.Name="KDLC_BV"
    bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.new(); bv.P=1e9; bv.Parent=hrp
    local bg=Instance.new("BodyGyro"); bg.Name="KDLC_BG"
    bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.P=1e7; bg.D=500; bg.CFrame=hrp.CFrame; bg.Parent=hrp
    Fly.BV=bv; Fly.BG=bg
    Fly.Conn=RS.Stepped:Connect(function()
        if not Fly.Active then Fly.Conn:Disconnect(); return end
        local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not h or not Fly.BV or not Fly.BV.Parent then return end
        local cf=Cam.CFrame; local spd=S.F.FlySpeed; local vel=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,spd,0) end
        Fly.BV.Velocity=vel
        if vel.Magnitude>0.1 then Fly.BG.CFrame=CFrame.new(Vector3.new(),Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)) end
    end)
end
local function DisableFly()
    if not Fly.Active then return end; Fly.Active=false; S.F.FlyActive=false
    if Fly.Conn then Fly.Conn:Disconnect(); Fly.Conn=nil end
    if Fly.BV and Fly.BV.Parent then Fly.BV:Destroy() end
    if Fly.BG and Fly.BG.Parent then Fly.BG:Destroy() end
    Fly.BV=nil; Fly.BG=nil
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand=false end
end

-- Speed
local SpeedState={Active=false,OldWS=16}
local function GetHum() return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end
local function SetSpeed(on)
    SpeedState.Active=on; local hum=GetHum(); if not hum then return end
    if on then SpeedState.OldWS=hum.WalkSpeed; hum.WalkSpeed=S.F.Speed
    else hum.WalkSpeed=SpeedState.OldWS end
end

-- FreeCam
local FreeCam={Active=false,Conn=nil,Yaw=0,Pitch=0,SavedCT=Enum.CameraType.Custom,CamCF=CFrame.new()}
local function EnableFC()
    if FreeCam.Active then return end; FreeCam.Active=true; S.F.FreeCamActive=true
    FreeCam.CamCF=Cam.CFrame
    local lv=FreeCam.CamCF.LookVector
    FreeCam.Yaw=math.deg(math.atan2(-lv.X,-lv.Z))
    FreeCam.Pitch=math.deg(math.asin(math.clamp(lv.Y,-1,1)))
    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored=true end
    if hum then hum.WalkSpeed=0; hum.JumpPower=0 end
    FreeCam.SavedCT=Cam.CameraType; Cam.CameraType=Enum.CameraType.Scriptable
    UIS.MouseBehavior=Enum.MouseBehavior.LockCenter
    FreeCam.Conn=RS.RenderStepped:Connect(function(dt)
        if not FreeCam.Active then FreeCam.Conn:Disconnect(); FreeCam.Conn=nil; return end
        local delta=UIS:GetMouseDelta()
        FreeCam.Yaw=FreeCam.Yaw-delta.X*0.3
        FreeCam.Pitch=math.clamp(FreeCam.Pitch-delta.Y*0.3,-89,89)
        local rotCF=CFrame.Angles(0,math.rad(FreeCam.Yaw),0)*CFrame.Angles(math.rad(FreeCam.Pitch),0,0)
        local spd=S.F.FlySpeed*dt; local mv=Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+rotCF.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-rotCF.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-rotCF.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+rotCF.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,spd,0) end
        FreeCam.CamCF=CFrame.new(FreeCam.CamCF.Position+mv)*rotCF
        Cam.CFrame=FreeCam.CamCF
    end)
end
local function DisableFC()
    if not FreeCam.Active then return end; FreeCam.Active=false; S.F.FreeCamActive=false
    if FreeCam.Conn then FreeCam.Conn:Disconnect(); FreeCam.Conn=nil end
    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored=false end
    if hum then hum.WalkSpeed=S.F.SpeedEn and S.F.Speed or 16; hum.JumpPower=50 end
    Cam.CameraType=FreeCam.SavedCT; UIS.MouseBehavior=Enum.MouseBehavior.Default
end

-- ThirdPerson
local ThirdPerson={Active=false,Conn=nil,OrigCT=Enum.CameraType.Custom}
local function EnableThirdPerson()
    if ThirdPerson.Active then return end; ThirdPerson.Active=true; S.F.ThirdPersonActive=true
    ThirdPerson.OrigCT=Cam.CameraType
    local char=LP.Character
    if char then for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then pcall(function() p.LocalTransparencyModifier=0 end) end
    end end
    Cam.CameraType=Enum.CameraType.Scriptable
    ThirdPerson.Conn=RS.RenderStepped:Connect(function()
        if not ThirdPerson.Active then ThirdPerson.Conn:Disconnect(); ThirdPerson.Conn=nil; return end
        local c=LP.Character; if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local rp=RaycastParams.new(); rp.FilterDescendantsInstances={c}; rp.FilterType=Enum.RaycastFilterType.Exclude
        local origin=hrp.Position+Vector3.new(0,2,0)
        local dir=(origin-Cam.CFrame.LookVector*S.F.ThirdPersonDist)-origin
        local result=workspace:Raycast(origin,dir,rp)
        local finalPos=result and (origin+dir.Unit*(result.Distance-0.3)) or (origin+dir)
        Cam.CFrame=CFrame.new(finalPos,hrp.Position+Vector3.new(0,1.5,0))
        Cam.CameraType=Enum.CameraType.Scriptable
    end)
end
local function DisableThirdPerson()
    if not ThirdPerson.Active then return end; ThirdPerson.Active=false; S.F.ThirdPersonActive=false
    if ThirdPerson.Conn then ThirdPerson.Conn:Disconnect(); ThirdPerson.Conn=nil end
    pcall(function() Cam.CameraType=ThirdPerson.OrigCT end)
    local char=LP.Character
    if char then for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then pcall(function() p.LocalTransparencyModifier=1 end) end
    end end
end

-- Zoom
local function EnableZoom()
    if S.F.ZoomActive then return end; S.F.ZoomActive=true; S.F.OrigFOV=Cam.FieldOfView
    TS:Create(Cam,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{FieldOfView=S.F.ZoomFOV}):Play()
end
local function DisableZoom()
    if not S.F.ZoomActive then return end; S.F.ZoomActive=false
    TS:Create(Cam,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{FieldOfView=S.F.OrigFOV}):Play()
end

-- Desync
local Desync={Active=false,Conn=nil,FrozenCF=nil,OrigT={}}
local DesyncVis={box=NewD("Square"),boxSh=NewD("Square"),label=NewD("Text"),bones={}}
do
    if DesyncVis.box then DesyncVis.box.Visible=false DesyncVis.box.Filled=false DesyncVis.box.Thickness=1.5 DesyncVis.box.Color=Color3.fromRGB(255,100,50) end
    if DesyncVis.boxSh then DesyncVis.boxSh.Visible=false DesyncVis.boxSh.Filled=false DesyncVis.boxSh.Thickness=3 DesyncVis.boxSh.Color=Color3.new(0,0,0) DesyncVis.boxSh.Transparency=0.5 end
    if DesyncVis.label then DesyncVis.label.Visible=false DesyncVis.label.Size=12 DesyncVis.label.Center=true DesyncVis.label.Outline=true DesyncVis.label.Color=Color3.fromRGB(255,120,50) DesyncVis.label.Font=Drawing.Fonts.UI DesyncVis.label.Text="SERVER POS" end
    for i=1,14 do
        local sh=NewD("Line"); if sh then sh.Visible=false sh.Color=Color3.new(0,0,0) sh.Thickness=3 sh.Transparency=0.5 end
        local l=NewD("Line"); if l then l.Visible=false l.Thickness=1.5 l.Color=Color3.fromRGB(255,100,50) end
        table.insert(DesyncVis.bones,{sh=sh,l=l})
    end
end
local DS_BONES_R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local DS_BONES_R6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function DesyncHideAll()
    if DesyncVis.box then DesyncVis.box.Visible=false end
    if DesyncVis.boxSh then DesyncVis.boxSh.Visible=false end
    if DesyncVis.label then DesyncVis.label.Visible=false end
    for _,b in ipairs(DesyncVis.bones) do if b.l then b.l.Visible=false end if b.sh then b.sh.Visible=false end end
end

local Notify

local function EnableDesync()
    if Desync.Active then return end
    local char=LP.Character; if not char then return end
    Desync.Active=true; S.F.DesyncActive=true
    Desync.OrigT={}
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then Desync.OrigT[p]=p.LocalTransparencyModifier pcall(function() p.LocalTransparencyModifier=0.5 end) end
    end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if hrp then Desync.FrozenCF=hrp.CFrame end
    Desync.Conn=RS.Stepped:Connect(function()
        if not Desync.Active then Desync.Conn:Disconnect(); Desync.Conn=nil; return end
        local c=LP.Character; if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart"); if not h then return end
        pcall(function()
            local t=tick(); local spd=S.F.DesyncSpeed; local intensity=S.F.DesyncIntensity
            h.AssemblyLinearVelocity=Vector3.new(math.sin(t*spd*math.pi*2)*intensity*50,h.AssemblyLinearVelocity.Y,math.cos(t*spd*math.pi*2)*intensity*50)
        end)
    end)
    if Notify then Notify("DESYNC: ACTIVE",2) end
end

local function DisableDesync()
    if not Desync.Active then return end; Desync.Active=false; S.F.DesyncActive=false
    if Desync.Conn then Desync.Conn:Disconnect(); Desync.Conn=nil end
    local char=LP.Character
    if char then
        local h=char:FindFirstChild("HumanoidRootPart")
        if h then pcall(function() h.AssemblyLinearVelocity=Vector3.new() end) end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and Desync.OrigT[p]~=nil then pcall(function() p.LocalTransparencyModifier=Desync.OrigT[p] end) end
        end
    end
    DesyncHideAll()
    if Notify then Notify("DESYNC: OFF",2) end
end

LP.CharacterAdded:Connect(function(c)
    if Desync.Active then task.wait(0.5); DisableDesync() end
    Fly.Active=false; Fly.BV=nil; Fly.BG=nil
    task.wait(0.5)
    if S.F.SpeedEn then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=S.F.Speed end end
end)

-- Local Chams V1
local LC1Pool={}
do
    for i=1,32 do
        local r=NewD("Square"); if r then r.Visible=false r.Filled=false r.Thickness=2 end
        local f=NewD("Square"); if f then f.Visible=false f.Filled=true f.Transparency=0.7 end
        table.insert(LC1Pool,{r=r,f=f})
    end
end
local function GetVMParts()
    local parts={}
    for _,obj in ipairs(Cam:GetChildren()) do
        if obj:IsA("Model") then for _,v in ipairs(obj:GetDescendants()) do if v:IsA("BasePart") then table.insert(parts,v) end end end
    end
    if LP.Character then
        for _,n in ipairs({"Left Arm","Right Arm","LeftHand","RightHand","LeftLowerArm","RightLowerArm","LeftUpperArm","RightUpperArm"}) do
            local p=LP.Character:FindFirstChild(n); if p and p:IsA("BasePart") then table.insert(parts,p) end
        end
    end
    return parts
end
RS.Heartbeat:Connect(function()
    if not S.V.LocalChams then
        for _,p in ipairs(LC1Pool) do if p.r then p.r.Visible=false end if p.f then p.f.Visible=false end end
        return
    end
    local parts=GetVMParts(); local idx=0
    for _,part in ipairs(parts) do
        if idx>=#LC1Pool then break end; idx=idx+1; local pool=LC1Pool[idx]; if not pool then break end
        pcall(function()
            local sz=part.Size*0.5; local pos3=part.CFrame.Position
            local sp,on=Cam:WorldToViewportPoint(pos3); if not on then if pool.r then pool.r.Visible=false end if pool.f then pool.f.Visible=false end return end
            local dist=(Cam.CFrame.Position-pos3).Magnitude
            local fov2=math.tan(math.rad(Cam.FieldOfView*0.5))*2
            local sH=math.max(sz.Y*Cam.ViewportSize.Y/(dist*fov2),3)
            local sW=math.max(sz.X*Cam.ViewportSize.X/(dist*fov2),3)
            local tl=Vector2.new(sp.X-sW,sp.Y-sH); local s2=Vector2.new(sW*2,sH*2)
            if S.V.LocalChamsStyle=="Filled" or S.V.LocalChamsStyle=="Glow" then
                if pool.f then pool.f.Visible=true pool.f.Position=tl pool.f.Size=s2 pool.f.Color=S.V.LocalChamsColor pool.f.Transparency=S.V.LocalChamsTransp end
                if pool.r then pool.r.Visible=false end
            else
                if pool.r then pool.r.Visible=true pool.r.Position=tl pool.r.Size=s2 pool.r.Color=S.V.LocalChamsColor end
                if pool.f then pool.f.Visible=false end
            end
        end)
    end
    for i=idx+1,#LC1Pool do if LC1Pool[i] then if LC1Pool[i].r then LC1Pool[i].r.Visible=false end if LC1Pool[i].f then LC1Pool[i].f.Visible=false end end end
end)

-- Local Chams V2
local LC2={Conn=nil,OrigData={}}
local function LC2FindVM() for _,obj in ipairs(Cam:GetChildren()) do if obj:IsA("Model") then return obj end end end
local function LC2Apply(color,style,transp)
    local vm=LC2FindVM(); if not vm then return end
    for _,part in ipairs(vm:GetDescendants()) do
        if part:IsA("BasePart") then
            if not LC2.OrigData[part] then LC2.OrigData[part]={mat=part.Material,col=part.Color,bc=part.BrickColor,cast=part.CastShadow,transp=part.Transparency} end
            pcall(function()
                if style=="Rainbow" then part.Color=Color3.fromHSV((tick()*0.4)%1,1,1)
                elseif style=="Neon" then part.Material=Enum.Material.Neon; part.Color=color; part.Transparency=transp
                elseif style=="Glass" then part.Material=Enum.Material.Glass; part.Color=color; part.Transparency=math.max(transp,0.3)
                elseif style=="Invisible" then part.Transparency=1
                else part.Material=Enum.Material.ForceField; part.Color=color; part.Transparency=transp end
                part.CastShadow=false
            end)
        end
    end
end
local function LC2Restore()
    for part,data in pairs(LC2.OrigData) do
        pcall(function() if part and part.Parent then part.Material=data.mat; part.Color=data.col; part.BrickColor=data.bc; part.CastShadow=data.cast; part.Transparency=data.transp end end)
    end
    LC2.OrigData={}
end
local function EnableLC2()
    if LC2.Conn then LC2.Conn:Disconnect() end
    LC2.Conn=RS.RenderStepped:Connect(function()
        if not S.V.LCV2 then LC2Restore(); LC2.Conn:Disconnect(); LC2.Conn=nil; return end
        LC2Apply(S.V.LCV2Color,S.V.LCV2Style,S.V.LCV2Transp)
    end)
end
local function DisableLC2() if LC2.Conn then LC2.Conn:Disconnect(); LC2.Conn=nil end LC2Restore() end

-- Misc systems
local AFKThread
local function StartAFK()
    if AFKThread then pcall(task.cancel,AFKThread) end
    AFKThread=task.spawn(function()
        while S.F.AntiAFKEn do
            pcall(function()
                local ok,vim=pcall(function() return game:GetService("VirtualInputManager") end)
                if ok and vim then local vp=Cam.ViewportSize; local cx,cy=math.floor(vp.X/2),math.floor(vp.Y/2); vim:SendMouseMoveEvent(cx+1,cy,game); task.wait(0.1); vim:SendMouseMoveEvent(cx,cy,game)
                else local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.Jump=true end end
            end)
            task.wait(S.F.AntiAFKInterval)
        end
    end)
end
local function StopAFK() if AFKThread then pcall(task.cancel,AFKThread); AFKThread=nil end end

local FPSBoost={Active=false,OldQ=Enum.QualityLevel.Automatic}
local function EnableFPS()
    if FPSBoost.Active then return end; FPSBoost.Active=true
    pcall(function() FPSBoost.OldQ=settings().Rendering.QualityLevel; settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    pcall(function() _S.Lighting.GlobalShadows=false end)
end
local function DisableFPS()
    if not FPSBoost.Active then return end; FPSBoost.Active=false
    pcall(function() settings().Rendering.QualityLevel=FPSBoost.OldQ end)
    pcall(function() _S.Lighting.GlobalShadows=true end)
end

local NoRecoilState={Conn=nil,LastCF=CFrame.new()}
local function StartNoRecoil(sk)
    if NoRecoilState.Conn then NoRecoilState.Conn:Disconnect() end
    NoRecoilState.LastCF=Cam.CFrame
    NoRecoilState.Conn=RS.RenderStepped:Connect(function()
        local active=sk=="rage" and S.R.NoRecoil or S.A.NoRecoil
        if not active then NoRecoilState.Conn:Disconnect(); NoRecoilState.Conn=nil; return end
        local cur=Cam.CFrame; local _,cY,_=cur:ToEulerAnglesYXZ(); local _,lY,_=NoRecoilState.LastCF:ToEulerAnglesYXZ()
        if math.abs(cY-lY)<0.001 then
            local x,y,z=cur:ToEulerAnglesXYZ(); local xL,_,_=NoRecoilState.LastCF:ToEulerAnglesXYZ()
            if x<xL then Cam.CFrame=CFrame.new(cur.Position)*CFrame.fromEulerAnglesXYZ(xL,y,z) end
        end
        NoRecoilState.LastCF=Cam.CFrame
    end)
end

local ForceAutoConn
local function StartForceAuto()
    if ForceAutoConn then ForceAutoConn:Disconnect() end
    ForceAutoConn=RS.Heartbeat:Connect(function()
        if not((S.R.ForceAuto and S.R.En) or (S.A.ForceAuto and S.A.En)) then ForceAutoConn:Disconnect(); ForceAutoConn=nil; return end
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        local char=LP.Character; if not char then return end
        for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then pcall(function() t:Activate() end) end end
    end)
end

local AntiAim={Conn=nil,Angle=0}
local function StartAntiAim()
    if AntiAim.Conn then AntiAim.Conn:Disconnect(); AntiAim.Conn=nil end
    AntiAim.Conn=RS.Heartbeat:Connect(function(dt)
        if not S.R.En or not S.R.AntiAim then AntiAim.Conn:Disconnect(); AntiAim.Conn=nil; return end
        local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        AntiAim.Angle=(AntiAim.Angle+dt*360)%360
        local cur=hrp.CFrame; hrp.CFrame=CFrame.new(cur.Position)*CFrame.Angles(0,math.rad(S.R.AntiAimOffset+AntiAim.Angle*3),0)
    end)
end
local function StopAntiAim() if AntiAim.Conn then AntiAim.Conn:Disconnect(); AntiAim.Conn=nil end end

-- NOTIFICATION
local NotifyQueue={} local NotifyActive=false
local function ProcessNotify()
    if NotifyActive or #NotifyQueue==0 then return end
    NotifyActive=true
    local item=table.remove(NotifyQueue,1)
    local f=Instance.new("Frame",GUI)
    f.Size=UDim2.new(0,300,0,0); f.Position=UDim2.new(0.5,-150,0,-70)
    f.BackgroundColor3=T.BG; f.BorderSizePixel=0; f.ZIndex=999; f.ClipsDescendants=true
    Stroke(f,1,"Stroke")
    do
        local accent=Instance.new("Frame",f); accent.Size=UDim2.new(0,2,1,0); accent.BackgroundColor3=T.Stroke; accent.BorderSizePixel=0; accent.ZIndex=1001; Reg(accent,"BackgroundColor3","Stroke")
        local lbl=Instance.new("TextLabel",f); lbl.Size=UDim2.new(1,-16,0,40); lbl.Position=UDim2.new(0,10,0,6); lbl.BackgroundTransparency=1; lbl.Text=item.text; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextWrapped=true; lbl.ZIndex=1000; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextColor3=T.Text; Reg(lbl,"TextColor3","Text")
        local pbg=Instance.new("Frame",f); pbg.Size=UDim2.new(1,-12,0,2); pbg.Position=UDim2.new(0,6,1,-5); pbg.BackgroundColor3=T.SliderBG; pbg.BorderSizePixel=0; pbg.ZIndex=1000; Reg(pbg,"BackgroundColor3","SliderBG")
        local pb=Instance.new("Frame",pbg); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundColor3=T.Stroke; pb.BorderSizePixel=0; pb.ZIndex=1001; Reg(pb,"BackgroundColor3","Stroke")
        TS:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,300,0,54),Position=UDim2.new(0.5,-150,0,18)}):Play()
        task.spawn(function() task.wait(0.35); TS:Create(pb,TweenInfo.new(item.dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play() end)
        task.delay(item.dur+0.4,function()
            TS:Create(f,TweenInfo.new(0.25),{Size=UDim2.new(0,300,0,0),Position=UDim2.new(0.5,-150,0,-70)}):Play()
            task.wait(0.3); pcall(function() f:Destroy() end); NotifyActive=false; ProcessNotify()
        end)
    end
end
Notify=function(text,dur) table.insert(NotifyQueue,{text=text,dur=dur or 3}); ProcessNotify() end

-- HIT NOTIFIER
local HitF=Instance.new("Frame",GUI)
HitF.Size=UDim2.new(0,300,0,60); HitF.Position=UDim2.new(0.5,-150,0.38,-30)
HitF.BackgroundTransparency=1; HitF.BorderSizePixel=0; HitF.ZIndex=500

local function SpawnHit(txt,hs)
    local l=Instance.new("TextLabel",HitF); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Text=txt; l.Font=hs and Enum.Font.GothamBlack or Enum.Font.GothamBold; l.TextSize=hs and 30 or 22
    l.TextColor3=hs and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,255,255)
    l.TextStrokeTransparency=0; l.TextStrokeColor3=Color3.new(0,0,0); l.TextXAlignment=Enum.TextXAlignment.Center; l.ZIndex=501; l.TextTransparency=1
    TS:Create(l,TweenInfo.new(0.08),{TextTransparency=0}):Play()
    task.spawn(function()
        task.wait(0.35)
        TS:Create(l,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,-1,0),TextTransparency=1}):Play()
        task.wait(0.55); pcall(function() l:Destroy() end)
    end)
end

local HitConns={}
local function ConnectHP(p)
    if p==LP then return end
    if HitConns[p] then pcall(function() HitConns[p]:Disconnect() end); HitConns[p]=nil end
    local char=p.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local prev=hum.Health
    HitConns[p]=hum.HealthChanged:Connect(function(newHP)
        if not S.A.HitNotify then prev=newHP; return end
        if newHP<prev then local dmg=prev-newHP; if AimState.Active or S.R.Active or S.A.SAEn then SpawnHit(dmg>=70 and "HEADSHOT!" or "HIT!",dmg>=70) end end
        prev=newHP
    end)
end
local function DisconnectHP(p) if HitConns[p] then pcall(function() HitConns[p]:Disconnect() end); HitConns[p]=nil end end
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then ConnectHP(p); p.CharacterAdded:Connect(function() task.wait(0.5); ConnectHP(p) end) end end
Players.PlayerAdded:Connect(function(p) if p==LP then return end; ConnectHP(p); p.CharacterAdded:Connect(function() task.wait(0.5); ConnectHP(p) end) end)
Players.PlayerRemoving:Connect(DisconnectHP)

-- ESP (УЛУЧШЕННЫЙ ВИЗУАЛ)
local ESPObj={}
local AvatarCache={}
local BONES_R6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local BONES_R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local function GetBones(char) return char:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6 end
local function LoadAvatar(p)
    if AvatarCache[p.UserId] then return end; AvatarCache[p.UserId]="pending"
    task.spawn(function()
        local ok,img=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
        if ok then AvatarCache[p.UserId]=img end
    end)
end

local function MakeESP(p)
    if p==LP or ESPObj[p] then return end
    local o={}
    local function d(t,vis,fill,thick,col)
        local x=NewD(t); if not x then return x end
        x.Visible=false
        if t=="Square" then x.Filled=fill; if thick then x.Thickness=thick end end
        if col then x.Color=col end
        return x
    end
    -- ====== УЛУЧШЕННЫЕ ПАРАМЕТРЫ ESP ======
    o.filled=d("Square",false,true); if o.filled then o.filled.Transparency=0.15 end
    o.boxSh=d("Square",false,false,4.5,Color3.new(0,0,0)); if o.boxSh then o.boxSh.Transparency=0.65 end
    o.box=d("Square",false,false,2.5)
    o.headSh=d("Square",false,false,3.5,Color3.new(0,0,0)); if o.headSh then o.headSh.Transparency=0.65 end
    o.head=d("Square",false,false,2.2)
    o.name=NewD("Text"); if o.name then o.name.Visible=false o.name.Size=15 o.name.Center=true o.name.Outline=true o.name.OutlineColor=Color3.new(0,0,0) o.name.Font=Drawing.Fonts.UI end
    o.dist=NewD("Text"); if o.dist then o.dist.Visible=false o.dist.Size=12 o.dist.Center=true o.dist.Outline=true o.dist.OutlineColor=Color3.new(0,0,0) o.dist.Font=Drawing.Fonts.UI o.dist.Color=Color3.fromRGB(200,200,200) end
    o.hpbg=d("Square",false,true,nil,Color3.fromRGB(20,20,20)); if o.hpbg then o.hpbg.Transparency=0.7 end
    o.hp=d("Square",false,true)
    do
        local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,46,0,46); bb.StudsOffset=Vector3.new(0,4.2,0); bb.AlwaysOnTop=true; bb.LightInfluence=0; bb.Enabled=false
        local il=Instance.new("ImageLabel",bb); il.Size=UDim2.new(1,0,1,0); il.BackgroundTransparency=1; il.Image=""; Instance.new("UICorner",il).CornerRadius=UDim.new(1,0)
        local us=Instance.new("UIStroke",il); us.Thickness=2.8; us.Color=Color3.fromRGB(255,255,255)
        o.avatarBB=bb; o.avatarImg=il; o.avatarStroke=us
    end
    o.skel={}
    for _,b in ipairs(BONES_R15) do
        local sh=NewD("Line"); if sh then sh.Visible=false sh.Color=Color3.new(0,0,0) sh.Thickness=3.5 sh.Transparency=0.65 end
        local l=NewD("Line"); if l then l.Visible=false l.Thickness=2 end
        table.insert(o.skel,{sh=sh,l=l,f=b[1],t=b[2]})
    end
    ESPObj[p]=o; LoadAvatar(p)
end

local function HideESP(o)
    if not o then return end
    local function h(d) if d then d.Visible=false end end
    h(o.filled);h(o.box);h(o.boxSh);h(o.head);h(o.headSh);h(o.name);h(o.dist);h(o.hpbg);h(o.hp)
    if o.avatarBB then o.avatarBB.Enabled=false end
    for _,b in ipairs(o.skel) do h(b.l);h(b.sh) end
end
local function RemoveESP(p)
    local o=ESPObj[p]; if not o then return end
    local function rm(d) if d then pcall(function() d:Remove() end) end end
    rm(o.filled);rm(o.box);rm(o.boxSh);rm(o.head);rm(o.headSh);rm(o.name);rm(o.dist);rm(o.hpbg);rm(o.hp)
    if o.avatarBB then pcall(function() o.avatarBB:Destroy() end) end
    for _,b in ipairs(o.skel) do rm(b.l);rm(b.sh) end
    ESPObj[p]=nil
end
for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

-- Crosshair + FOV circles
local CXDot=NewD("Circle"); local CXOut=NewD("Circle"); local CXLines={}; local CXAngle=0
do
    if CXDot then CXDot.Visible=false CXDot.NumSides=32 CXDot.Radius=3 CXDot.Filled=true CXDot.Thickness=1 end
    if CXOut then CXOut.Visible=false CXOut.NumSides=32 CXOut.Radius=5 CXOut.Filled=false CXOut.Color=Color3.new(0,0,0) CXOut.Thickness=1 end
    for i=1,4 do
        local l=NewD("Line"); if l then l.Visible=false l.Thickness=1.5 end
        local o=NewD("Line"); if o then o.Visible=false o.Color=Color3.new(0,0,0) o.Thickness=2.5 end
        table.insert(CXLines,{l=l,o=o})
    end
end
FOVCirc=NewD("Circle"); if FOVCirc then FOVCirc.Visible=false FOVCirc.Thickness=1 FOVCirc.NumSides=64 FOVCirc.Filled=false FOVCirc.Transparency=0.4 FOVCirc.Color=T.AimFOV end
SAFOVCirc=NewD("Circle"); if SAFOVCirc then SAFOVCirc.Visible=false SAFOVCirc.Thickness=1 SAFOVCirc.NumSides=64 SAFOVCirc.Filled=false SAFOVCirc.Transparency=0.5 SAFOVCirc.Color=T.SAFOVColor end
RageFOVCirc=NewD("Circle"); if RageFOVCirc then RageFOVCirc.Visible=false RageFOVCirc.Thickness=1.5 RageFOVCirc.NumSides=64 RageFOVCirc.Filled=false RageFOVCirc.Transparency=0.5 RageFOVCirc.Color=T.RageFOVColor end

-- Aimbot helpers
local AimVel={Pos={},Time={}}
local function GetVel(p)
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return Vector3.new() end
    local pos,t=hrp.Position,tick(); local vel=Vector3.new()
    if AimVel.Pos[p] and AimVel.Time[p] then local dt=t-AimVel.Time[p]; if dt>0 and dt<0.5 then vel=(pos-AimVel.Pos[p])/dt end end
    AimVel.Pos[p]=pos; AimVel.Time[p]=t; return vel
end
local function PredPos(p,base)
    if not S.A.Predict then return base end
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return base end
    return base+GetVel(p)*((Cam.CFrame.Position-hrp.Position).Magnitude/500)
end
local function GetTgt()
    local best,bd=nil,S.A.FOV; local mp=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local part=FindPart(p.Character,S.A.HitPart); local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health>0 then
                local sp,os=Cam:WorldToViewportPoint(PredPos(p,part.Position))
                if os then local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude; if d<bd then best=p; bd=d end end
            end
        end
    end
    return best
end
local function GetRageTgt()
    local best,bd=nil,S.R.FOV; local mp=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local part=FindPart(p.Character,S.R.HitPart); local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health>0 then
                local sp,os=Cam:WorldToViewportPoint(part.Position)
                if os then local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude; if d<bd then best=p; bd=d end end
            end
        end
    end
    return best
end

local lastAimT=0
local function DoAim(tgt,dt)
    if not tgt or not tgt.Character then return end
    if math.random(1,100)>S.A.HitChance then return end
    if tick()-lastAimT<(S.A.ReactionTime or 0) then return end
    lastAimT=tick()
    local part=FindPart(tgt.Character,S.A.HitPart); if not part then return end
    local ap=PredPos(tgt,part.Position)
    if S.A.BypassMode then ap=ap+Vector3.new((math.random()-0.5)*0.01,(math.random()-0.5)*0.01,0) end
    if (S.A.ShakeAmount or 0)>0 then local sh=S.A.ShakeAmount*0.1; ap=ap+Vector3.new((math.random()-0.5)*sh,(math.random()-0.5)*sh,0) end
    
    -- ====== AIM MANIPULATION INTEGRATION ======
    if S.A.AimManip and AimManip.BypassFound then
        SAOverride.enabled=true
        SAOverride.hitPos=CFrame.new(ap)
        SAOverride.unitRay=Ray.new(Cam.CFrame.Position,(ap-Cam.CFrame.Position).Unit*999)
        SAOverride.target=part
    end
    
    local fac=math.clamp(1-math.exp(-S.A.Smooth*dt*5),0.01,0.99)
    Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,ap),fac)
end
local function DoRageAim(tgt,dt)
    if not tgt or not tgt.Character then return end
    local part=FindPart(tgt.Character,S.R.HitPart); if not part then return end
    local fac=math.clamp(1-math.exp(-S.R.Smooth*dt*60),0.05,1.0)
    Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,part.Position),fac)
end

-- Silent Aim
local SAVel={Pos={},Time={}}
local function GetSAVel(p)
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return Vector3.new() end
    local pos,t=hrp.Position,tick(); local vel=Vector3.new()
    if SAVel.Pos[p] and SAVel.Time[p] then local dt=t-SAVel.Time[p]; if dt>0 and dt<0.5 then vel=(pos-SAVel.Pos[p])/dt end end
    SAVel.Pos[p]=pos; SAVel.Time[p]=t; return vel
end
local function GetSAPos(p)
    if not p.Character then return nil end
    local part=FindPart(p.Character,S.A.SABone); if not part then return nil end
    return part.Position+GetSAVel(p)*((Cam.CFrame.Position-part.Position).Magnitude/600)
end
local function GetSATgt()
    local mp=UIS:GetMouseLocation(); local best,bd=nil,S.A.SAMethod=="Mouse" and S.A.SAFOV or math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hum=p.Character:FindFirstChildOfClass("Humanoid"); local bpos=GetSAPos(p)
            if bpos and hum and hum.Health>0 then
                local sp,os=Cam:WorldToViewportPoint(bpos)
                if os then
                    local d=S.A.SAMethod=="Mouse" and (Vector2.new(sp.X,sp.Y)-mp).Magnitude or (Cam.CFrame.Position-bpos).Magnitude
                    if d<bd then best=p; bd=d end
                end
            end
        end
    end
    return best
end

RS.Heartbeat:Connect(function()
    if S.A.SAEn then
        local tgt=GetSATgt()
        if tgt and tgt.Character then
            local bpos=GetSAPos(tgt)
            if bpos then
                SAOverride.enabled=true; SAOverride.hitPos=CFrame.new(bpos)
                SAOverride.unitRay=Ray.new(Cam.CFrame.Position,(bpos-Cam.CFrame.Position).Unit*999)
                SAOverride.target=FindPart(tgt.Character,S.A.SABone); return
            end
        end
    end
    if (S.R.ForceHeadshot or S.R.En) and S.R.HitPart then
        local bp,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local part=FindPart(p.Character,S.R.HitPart)
                if part then local d=(Cam.CFrame.Position-part.Position).Magnitude; if d<bd then bd=d; bp=part end end
            end
        end
        if bp then SAOverride.enabled=true; SAOverride.hitPos=CFrame.new(bp.Position); SAOverride.unitRay=Ray.new(Cam.CFrame.Position,(bp.Position-Cam.CFrame.Position).Unit*999); SAOverride.target=bp; return end
    end
    if S.R.NoSpread or S.A.NoSpread then
        local lp=Cam.CFrame.Position+Cam.CFrame.LookVector*500
        SAOverride.enabled=true; SAOverride.hitPos=CFrame.new(lp); SAOverride.unitRay=Ray.new(Cam.CFrame.Position,Cam.CFrame.LookVector*999); SAOverride.target=nil; return
    end
    SAOverride.enabled=false; SAOverride.hitPos=nil; SAOverride.target=nil; SAOverride.unitRay=nil
end)
task.delay(1,SafePatchMouse)

-- Input
local _menuOpen=false; local _menuAnimating=false
local _openMenu,_closeMenu

-- ====== ТОЛЬКО INSERT И КНОПКА МИНИ ПАНЕЛИ ЗАКРЫВАЮТ МЕНЮ ======
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==S.MenuKey then if S.Unlocked then if _menuOpen then _closeMenu() else _openMenu() end end; return end
    if S.F.SpeedEn and S.F.SpeedBind and i.KeyCode==S.F.SpeedBind then
        if S.F.SpeedType=="Hold" then SetSpeed(true) else SetSpeed(not SpeedState.Active) end end
    if S.F.FlyEn and S.F.FlyBind and i.KeyCode==S.F.FlyBind then
        if S.F.FlyType=="Hold" then EnableFly() else if Fly.Active then DisableFly() else EnableFly() end end end
    if S.F.FreeCamEn and S.F.FreeCamBind and i.KeyCode==S.F.FreeCamBind then
        if S.F.FreeCamType=="Hold" then EnableFC() else if FreeCam.Active then DisableFC() else EnableFC() end end end
    if S.F.ZoomEn and S.F.ZoomBind and i.KeyCode==S.F.ZoomBind then
        if S.F.ZoomType=="Hold" then EnableZoom() else if S.F.ZoomActive then DisableZoom() else EnableZoom() end end end
    if S.F.ThirdPersonEn and S.F.ThirdPersonBind and i.KeyCode==S.F.ThirdPersonBind then
        if S.F.ThirdPersonType=="Hold" then EnableThirdPerson() else if S.F.ThirdPersonActive then DisableThirdPerson() else EnableThirdPerson() end end end
    if S.F.DesyncEn and S.F.DesyncBind and i.KeyCode==S.F.DesyncBind then
        if S.F.DesyncType=="Hold" then EnableDesync() else if S.F.DesyncActive then DisableDesync() else EnableDesync() end end end
    if S.A.En then
        local isKey=(S.A.BindKey and i.KeyCode==S.A.BindKey) or (not S.A.BindKey and i.UserInputType==Enum.UserInputType.MouseButton2)
        if isKey then
            if S.A.Type=="Hold" then AimState.Active=true; AimState.Target=GetTgt()
            else AimState.Active=not AimState.Active; AimState.Target=AimState.Active and GetTgt() or nil end
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if S.F.SpeedEn and S.F.SpeedBind and i.KeyCode==S.F.SpeedBind and S.F.SpeedType=="Hold" then SetSpeed(false) end
    if S.F.FlyEn and S.F.FlyBind and i.KeyCode==S.F.FlyBind and S.F.FlyType=="Hold" then DisableFly() end
    if S.F.FreeCamEn and S.F.FreeCamBind and i.KeyCode==S.F.FreeCamBind and S.F.FreeCamType=="Hold" then DisableFC() end
    if S.F.ZoomEn and S.F.ZoomBind and i.KeyCode==S.F.ZoomBind and S.F.ZoomType=="Hold" then DisableZoom() end
    if S.F.ThirdPersonEn and S.F.ThirdPersonBind and i.KeyCode==S.F.ThirdPersonBind and S.F.ThirdPersonType=="Hold" then DisableThirdPerson() end
    if S.F.DesyncEn and S.F.DesyncBind and i.KeyCode==S.F.DesyncBind and S.F.DesyncType=="Hold" then DisableDesync() end
    if S.A.En then
        local isKey=(S.A.BindKey and i.KeyCode==S.A.BindKey) or (not S.A.BindKey and i.UserInputType==Enum.UserInputType.MouseButton2)
        if isKey and S.A.Type=="Hold" then AimState.Active=false; if not S.A.Sticky then AimState.Target=nil end end
    end
end)

-- ============================================================
-- MINI PANEL
-- ============================================================
local MiniTitle,MiniStream,MiniFPS,MiniPing,MiniMenuBtn
do
    local MP=Instance.new("Frame",GUI)
    MP.Size=UDim2.new(0,460,0,30); MP.Position=UDim2.new(0.5,-230,0,8)
    MP.BackgroundColor3=T.BG; MP.BorderSizePixel=0; MP.ZIndex=200
    Stroke(MP,1,"Stroke"); Reg(MP,"BackgroundColor3","BG")

    local handle=Instance.new("Frame",MP)
    handle.Size=UDim2.new(0,180,1,0); handle.BackgroundTransparency=1; handle.ZIndex=201
    Drag(MP,handle)

    local function mkL(x,w,txt)
        local l=Instance.new("TextLabel",MP)
        l.Size=UDim2.new(0,w,1,0); l.Position=UDim2.new(0,x,0,0)
        l.BackgroundTransparency=1; l.Text=txt; l.Font=Enum.Font.GothamBold
        l.TextSize=12; l.ZIndex=202; l.TextColor3=T.Text
        Reg(l,"TextColor3","Text"); return l
    end
    local function mkD(x)
        local d=Instance.new("Frame",MP)
        d.Size=UDim2.new(0,1,0.6,0); d.Position=UDim2.new(0,x,0.2,0)
        d.BackgroundColor3=T.Divider; d.BorderSizePixel=0; d.ZIndex=202
        Reg(d,"BackgroundColor3","Divider")
    end

    MiniTitle=mkL(18,130,"KIRIESHKA DLC")
    MiniStream=Instance.new("TextLabel",MP)
    MiniStream.Size=UDim2.new(0,70,1,0); MiniStream.Position=UDim2.new(0,150,0,0)
    MiniStream.BackgroundTransparency=1; MiniStream.Font=Enum.Font.GothamBold
    MiniStream.TextSize=9; MiniStream.Text=""; MiniStream.TextColor3=Color3.fromRGB(255,80,80); MiniStream.ZIndex=202

    mkD(222); MiniFPS=mkL(228,80,"-- FPS"); MiniFPS.TextXAlignment=Enum.TextXAlignment.Center
    mkD(310); MiniPing=mkL(316,80,"-- MS"); MiniPing.TextXAlignment=Enum.TextXAlignment.Center
    mkD(398)

    MiniMenuBtn=Instance.new("TextButton",MP)
    MiniMenuBtn.Size=UDim2.new(0,55,0,20); MiniMenuBtn.Position=UDim2.new(1,-58,0.5,-10)
    MiniMenuBtn.BackgroundColor3=T.Button; MiniMenuBtn.BorderSizePixel=0
    MiniMenuBtn.Font=Enum.Font.GothamBold; MiniMenuBtn.TextSize=10
    MiniMenuBtn.Text="MENU"; MiniMenuBtn.ZIndex=203; MiniMenuBtn.TextColor3=T.Text
    Stroke(MiniMenuBtn,1,"StrokeItem"); Hover(MiniMenuBtn,"Button")
    Reg(MiniMenuBtn,"BackgroundColor3","Button"); Reg(MiniMenuBtn,"TextColor3","Text")
    MiniMenuBtn.MouseButton1Click:Connect(function()
        if not S.Unlocked then return end
        if _menuOpen then _closeMenu() else _openMenu() end
    end)

    do
        local fT={}
        RS.Heartbeat:Connect(function()
            local now=tick(); table.insert(fT,now)
            while fT[1] and (now-fT[1])>1 do table.remove(fT,1) end
            local fps=#fT
            MiniFPS.TextColor3=fps>=55 and Color3.fromRGB(100,220,100) or fps>=30 and Color3.fromRGB(220,200,50) or Color3.fromRGB(220,80,80)
            MiniFPS.Text=fps.." FPS"
            local ping=0; pcall(function() ping=math.floor(LP:GetNetworkPing()*1000) end)
            MiniPing.TextColor3=ping<=80 and Color3.fromRGB(100,220,100) or ping<=150 and Color3.fromRGB(220,200,50) or Color3.fromRGB(220,80,80)
            MiniPing.Text=ping.." MS"
        end)
    end
    task.spawn(function() while MiniTitle and MiniTitle.Parent do MiniTitle.TextColor3=RBW() task.wait(0.03) end end)
end

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local LoadScreen,LoadBar,LoadText,LoadLogo
do
    LoadScreen=Instance.new("Frame",GUI)
    LoadScreen.Size=UDim2.new(1,0,1,0); LoadScreen.BackgroundColor3=Color3.new(0,0,0)
    LoadScreen.BorderSizePixel=0; LoadScreen.ZIndex=900

    LoadLogo=Instance.new("ImageLabel",LoadScreen)
    LoadLogo.Size=UDim2.new(0,180,0,180); LoadLogo.Position=UDim2.new(0.5,-90,0.35,-90)
    LoadLogo.BackgroundTransparency=1; LoadLogo.Image="rbxassetid://101728546466647"
    LoadLogo.ImageTransparency=1; LoadLogo.ZIndex=912
    TS:Create(LoadLogo,TweenInfo.new(0.7,Enum.EasingStyle.Quad),{ImageTransparency=0}):Play()

    local logoConn; local la=0
    logoConn=RS.Heartbeat:Connect(function(dt)
        if not(LoadLogo and LoadLogo.Parent) then logoConn:Disconnect(); return end
        la=(la+dt*120)%360; LoadLogo.Rotation=la
    end)

    local WORDS={"Kirieshka DLC","dobrograd","Decrypting...","Injecting...","Access Granted","Loading..."}
    local falling={}
    task.spawn(function()
        for i=1,30 do
            local t=Instance.new("TextLabel",LoadScreen)
            t.Size=UDim2.new(0,200,0,24); t.Position=UDim2.new(math.random(),0,-0.07,0)
            t.BackgroundTransparency=1; t.Font=Enum.Font.Code; t.TextSize=13
            t.Text=WORDS[math.random(#WORDS)]; t.TextXAlignment=Enum.TextXAlignment.Left; t.ZIndex=902
            table.insert(falling,t)
            TS:Create(t,TweenInfo.new(math.random(10,16),Enum.EasingStyle.Linear),{Position=UDim2.new(t.Position.X.Scale,0,1.12,0),TextTransparency=1}):Play()
            task.wait(0.14)
        end
    end)
    task.spawn(function() while LoadScreen and LoadScreen.Parent do for i,v in ipairs(falling) do if v and v.Parent then v.TextColor3=RBW(i*0.05) end end task.wait(0.04) end end)

    do
        local bbg=Instance.new("Frame",LoadScreen)
        bbg.Size=UDim2.new(0,480,0,2); bbg.Position=UDim2.new(0.5,-240,0.83,0)
        bbg.BackgroundColor3=Color3.fromRGB(20,20,20); bbg.BorderSizePixel=0; bbg.ZIndex=905
        LoadBar=Instance.new("Frame",bbg)
        LoadBar.Size=UDim2.new(0,0,1,0); LoadBar.BackgroundColor3=Color3.fromRGB(80,160,255)
        LoadBar.BorderSizePixel=0; LoadBar.ZIndex=906
    end

    LoadText=Instance.new("TextLabel",LoadScreen)
    LoadText.Size=UDim2.new(1,0,0,24); LoadText.Position=UDim2.new(0,0,0.83,-28)
    LoadText.BackgroundTransparency=1; LoadText.Font=Enum.Font.Code; LoadText.TextSize=12
    LoadText.TextColor3=Color3.fromRGB(120,170,255); LoadText.ZIndex=905; LoadText.Text="Loading..."
end

-- ============================================================
-- MAIN MENU
-- ============================================================
local MenuFrame,MenuTitle,MenuNick,MenuKeyLabel,MenuTabBar,MenuContent
local MenuDimmer
do
    MenuDimmer=Instance.new("Frame",GUI)
    MenuDimmer.Size=UDim2.new(1,0,1,0); MenuDimmer.BackgroundColor3=Color3.new(0,0,0)
    MenuDimmer.BackgroundTransparency=1; MenuDimmer.BorderSizePixel=0; MenuDimmer.ZIndex=98; MenuDimmer.Visible=false

    MenuFrame=Instance.new("Frame",GUI)
    MenuFrame.Name="KMenu"; MenuFrame.Size=UDim2.new(0,700,0,500)
    MenuFrame.Position=UDim2.new(0.5,-350,0.5,-250); MenuFrame.BackgroundColor3=T.BG
    MenuFrame.BorderSizePixel=0; MenuFrame.Visible=false; MenuFrame.ZIndex=100; MenuFrame.ClipsDescendants=true
    Stroke(MenuFrame,2,"Stroke"); Reg(MenuFrame,"BackgroundColor3","BG")

    _openMenu=function()
        if not S.Unlocked or _menuOpen or _menuAnimating then return end
        _menuAnimating=true; _menuOpen=true; MiniMenuBtn.Text="CLOSE"
        UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true
        MenuFrame.Size=UDim2.new(0,700,0,0); MenuFrame.Position=UDim2.new(0.5,-350,0.5,0)
        MenuFrame.BackgroundTransparency=1; MenuFrame.Visible=true
        MenuDimmer.Visible=true; MenuDimmer.BackgroundTransparency=1
        TS:Create(MenuFrame,TweenInfo.new(0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,700,0,500),Position=UDim2.new(0.5,-350,0.5,-250),BackgroundTransparency=0}):Play()
        TS:Create(MenuDimmer,TweenInfo.new(0.3),{BackgroundTransparency=0.55}):Play()
        task.delay(0.4,function() _menuAnimating=false end)
    end
    _closeMenu=function()
        if not _menuOpen or _menuAnimating then return end
        _menuAnimating=true; _menuOpen=false; MiniMenuBtn.Text="MENU"; DBSave()
        TS:Create(MenuFrame,TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,700,0,0),Position=UDim2.new(0.5,-350,0.5,0),BackgroundTransparency=1}):Play()
        TS:Create(MenuDimmer,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
        task.delay(0.3,function() MenuFrame.Visible=false; MenuDimmer.Visible=false; _menuAnimating=false end)
    end
    
    do
        local hdr=Instance.new("Frame",MenuFrame)
        hdr.Size=UDim2.new(1,0,0,52); hdr.BackgroundColor3=T.Header; hdr.BorderSizePixel=0; hdr.ZIndex=110
        Reg(hdr,"BackgroundColor3","Header")
        MenuTitle=Instance.new("TextLabel",hdr)
        MenuTitle.Size=UDim2.new(0.55,0,0,24); MenuTitle.Position=UDim2.new(0,12,0,6)
        MenuTitle.BackgroundTransparency=1; MenuTitle.Font=Enum.Font.GothamBold; MenuTitle.TextSize=16
        MenuTitle.TextXAlignment=Enum.TextXAlignment.Left; MenuTitle.ZIndex=111
        MenuTitle.Text="KIRIESHKA DLC"; MenuTitle.TextColor3=T.Text
        task.spawn(function() while MenuTitle and MenuTitle.Parent do MenuTitle.TextColor3=RBW() task.wait(0.03) end end)
        MenuNick=Instance.new("TextLabel",hdr)
        MenuNick.Size=UDim2.new(0.55,0,0,14); MenuNick.Position=UDim2.new(0,13,0,31)
        MenuNick.BackgroundTransparency=1; MenuNick.Font=Enum.Font.Gotham; MenuNick.TextSize=10
        MenuNick.TextXAlignment=Enum.TextXAlignment.Left; MenuNick.ZIndex=111
        MenuNick.Text="@"..LP.Name; MenuNick.TextColor3=T.TextDim; Reg(MenuNick,"TextColor3","TextDim")
        MenuKeyLabel=Instance.new("TextLabel",hdr)
        MenuKeyLabel.Size=UDim2.new(0.42,-10,1,0); MenuKeyLabel.Position=UDim2.new(0.58,0,0,0)
        MenuKeyLabel.BackgroundTransparency=1; MenuKeyLabel.Font=Enum.Font.Code; MenuKeyLabel.TextSize=10
        MenuKeyLabel.TextXAlignment=Enum.TextXAlignment.Right; MenuKeyLabel.ZIndex=111
        MenuKeyLabel.TextColor3=T.TextDim; Reg(MenuKeyLabel,"TextColor3","TextDim")
        Drag(MenuFrame,hdr)
        local dv=Instance.new("Frame",MenuFrame); dv.Size=UDim2.new(1,0,0,1); dv.Position=UDim2.new(0,0,0,52); dv.BackgroundColor3=T.Divider; dv.BorderSizePixel=0; dv.ZIndex=110; Reg(dv,"BackgroundColor3","Divider")
    end

    local function UpdateMenuKey() MenuKeyLabel.Text=tostring(S.MenuKey):gsub("Enum.KeyCode.","").." — toggle" end
    UpdateMenuKey()

    -- Snow
    do
        local sf=Instance.new("Frame",MenuFrame)
        sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.ClipsDescendants=true; sf.ZIndex=101; sf.BorderSizePixel=0
        for i=1,16 do
            local f=Instance.new("Frame",sf); f.Size=UDim2.new(0,2,0,2)
            f.Position=UDim2.new(math.random(),0,math.random(),0); f.BackgroundColor3=T.Snow; f.BorderSizePixel=0; f.ZIndex=102
            table.insert(ThemeState.Snow,{F=f,S=math.random(15,60)/10000,O=math.random(100)})
        end
        RS.Heartbeat:Connect(function()
            for _,v in ipairs(ThemeState.Snow) do
                local nx=v.F.Position.X.Scale+math.sin(tick()*1.5+v.O)*0.0002
                local ny=v.F.Position.Y.Scale+v.S
                if ny>1.05 then ny=-0.05; nx=math.random() end
                v.F.Position=UDim2.new(nx,0,ny,0)
                if T.Glow then v.F.BackgroundColor3=Color3.fromHSV(0.6+math.sin(tick()+v.O)*0.03,0.8,1) end
            end
        end)
    end

    MenuTabBar=Instance.new("Frame",MenuFrame)
    MenuTabBar.Size=UDim2.new(1,0,0,34); MenuTabBar.Position=UDim2.new(0,0,0,53)
    MenuTabBar.BackgroundColor3=T.TabBar; MenuTabBar.BorderSizePixel=0; MenuTabBar.ZIndex=110
    Reg(MenuTabBar,"BackgroundColor3","TabBar")
    do
        local dv=Instance.new("Frame",MenuFrame); dv.Size=UDim2.new(1,0,0,1); dv.Position=UDim2.new(0,0,0,87); dv.BackgroundColor3=T.Divider; dv.BorderSizePixel=0; dv.ZIndex=110; Reg(dv,"BackgroundColor3","Divider")
    end

    MenuContent=Instance.new("ScrollingFrame",MenuFrame)
    MenuContent.Size=UDim2.new(1,-10,1,-94); MenuContent.Position=UDim2.new(0,5,0,90)
    MenuContent.BackgroundTransparency=1; MenuContent.BorderSizePixel=0
    MenuContent.ScrollBarThickness=3; MenuContent.ScrollBarImageColor3=Color3.fromRGB(60,120,255)
    MenuContent.CanvasSize=UDim2.new(0,0,0,0); MenuContent.AutomaticCanvasSize=Enum.AutomaticSize.Y; MenuContent.ZIndex=115
end

-- ============================================================
-- UI WIDGET HELPERS
-- ============================================================
local LO={v=0}
local function NLO() LO.v=LO.v+1; return LO.v end
local function MkLL(p,g) local l=Instance.new("UIListLayout",p); l.FillDirection=Enum.FillDirection.Vertical; l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,g or 2); return l end
local function MkPad(p,t,b,l,r) local pd=Instance.new("UIPadding",p); pd.PaddingTop=UDim.new(0,t or 0); pd.PaddingBottom=UDim.new(0,b or 0); pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0) end
local function TLbl(par,txt,sz,bold,key)
    local l=Instance.new("TextLabel",par); l.BackgroundTransparency=1; l.Text=txt
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham; l.TextSize=sz
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=131; l.TextColor3=T[key or "Text"]
    if key then Reg(l,"TextColor3",key) end; return l
end
local function MkSep(par,lbl)
    local f=Instance.new("Frame",par); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=NLO()
    local l=TLbl(f," "..lbl,10,true,"Sep"); l.Size=UDim2.new(1,0,1,0)
end
local function MkInfo(par,txt,col)
    local l=TLbl(par,"  "..txt,10,false,"TextDim"); l.Size=UDim2.new(1,0,0,16); l.TextWrapped=true; l.BorderSizePixel=0; l.LayoutOrder=NLO()
    if col then l.TextColor3=col end; return l
end
local function IB(par,h)
    local f=Instance.new("Frame",par); f.Size=UDim2.new(1,0,0,h); f.BackgroundColor3=T.Item; f.BorderSizePixel=0; f.ZIndex=130; f.LayoutOrder=NLO()
    Stroke(f,1,"StrokeItem"); Reg(f,"BackgroundColor3","Item"); return f
end
local function MkSw(par)
    local tb=Instance.new("Frame",par); tb.Size=UDim2.new(0,32,0,15); tb.Position=UDim2.new(1,-38,0.5,-7.5); tb.BackgroundColor3=T.SliderBG; tb.BorderSizePixel=0; tb.ZIndex=131
    Stroke(tb,1,"StrokeItem"); Reg(tb,"BackgroundColor3","SliderBG")
    local ind=Instance.new("Frame",tb); ind.Size=UDim2.new(0,9,0,9); ind.Position=UDim2.new(0,2,0.5,-4.5); ind.BackgroundColor3=T.ToggleOff; ind.BorderSizePixel=0; ind.ZIndex=132; Reg(ind,"BackgroundColor3","ToggleOff")
    return tb,ind
end
local function MkToggle(par,lbl,cb,iv)
    local f=IB(par,30)
    local cl=Instance.new("TextButton",f); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.Text=""; cl.ZIndex=134
    local _l=TLbl(f," "..lbl,12,false,"Text"); _l.Size=UDim2.new(1,-48,1,0)
    local _,ind=MkSw(f)
    local on=(iv~=nil) and iv or (DB.Toggles[lbl]==true)
    local function upd(s) TS:Create(ind,TweenInfo.new(0.14),{Position=UDim2.new(s and 1 or 0,s and -11 or 2,0.5,-4.5),BackgroundColor3=s and T.ToggleOn or T.ToggleOff}):Play() end
    upd(on); if on then task.spawn(function() pcall(cb,true) end) end
    cl.MouseButton1Click:Connect(function() on=not on; DB.Toggles[lbl]=on; DBSave(); upd(on); pcall(cb,on) end)
    return f,function() return on end
end
local function MkSlider(par,lbl,mn,mx,dbKey,cb)
    local f=IB(par,44); local def=math.clamp(tonumber(DB.Sliders[dbKey]) or mn,mn,mx)
    local lbw=TLbl(f,lbl..": "..def,12,false,"Text"); lbw.Size=UDim2.new(1,-10,0,18); lbw.Position=UDim2.new(0,10,0,4)
    local trk=Instance.new("Frame",f); trk.Size=UDim2.new(1,-20,0,4); trk.Position=UDim2.new(0,10,1,-12); trk.BackgroundColor3=T.SliderBG; trk.BorderSizePixel=0; trk.ZIndex=131; Reg(trk,"BackgroundColor3","SliderBG")
    local fill=Instance.new("Frame",trk); fill.BackgroundColor3=T.SliderFill; fill.BorderSizePixel=0; fill.ZIndex=132; fill.Size=UDim2.new(math.clamp((def-mn)/(mx-mn),0,1),0,1,0); Reg(fill,"BackgroundColor3","SliderFill")
    task.spawn(function() pcall(cb,def) end); local dr=false
    local function upd(px) px=math.clamp(px,0,1); local v=math.floor(mn+(mx-mn)*px); fill.Size=UDim2.new(px,0,1,0); lbw.Text=lbl..": "..v; DB.Sliders[dbKey]=v; DBSave(); pcall(cb,v) end
    trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; upd(math.clamp((i.Position.X-trk.AbsolutePosition.X)/math.max(trk.AbsoluteSize.X,1),0,1)) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then upd(math.clamp((i.Position.X-trk.AbsolutePosition.X)/math.max(trk.AbsoluteSize.X,1),0,1)) end end)
end
local function MkRGB(par,pfx,dR,dG,dB,cb)
    MkSlider(par,pfx.." R",0,255,dR,function(v) pcall(cb,Color3.fromRGB(v,DB.Sliders[dG],DB.Sliders[dB])) end)
    MkSlider(par,pfx.." G",0,255,dG,function(v) pcall(cb,Color3.fromRGB(DB.Sliders[dR],v,DB.Sliders[dB])) end)
    MkSlider(par,pfx.." B",0,255,dB,function(v) pcall(cb,Color3.fromRGB(DB.Sliders[dR],DB.Sliders[dG],v)) end)
end
local function MkDrop(par,lbl,opts,dbKey,cb)
    local f=IB(par,30); local def=DB.Settings[dbKey] or opts[1]
    local valid=false; for _,o in ipairs(opts) do if o==def then valid=true; break end end
    if not valid then def=opts[1] end
    local _l=TLbl(f," "..lbl,12,false,"Text"); _l.Size=UDim2.new(0.55,0,1,0)
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(0.38,0,0,21); btn.Position=UDim2.new(0.59,0,0.5,-10.5)
    btn.BackgroundColor3=T.Button; btn.BorderSizePixel=0; btn.Font=Enum.Font.Gotham; btn.TextSize=11
    btn.Text=def; btn.ZIndex=131; btn.TextColor3=T.Text
    Stroke(btn,1,"StrokeItem"); Hover(btn,"Button"); Reg(btn,"BackgroundColor3","Button"); Reg(btn,"TextColor3","Text")
    local ci=1; for i,o in ipairs(opts) do if o==def then ci=i; break end end
    task.spawn(function() pcall(cb,def) end)
    btn.MouseButton1Click:Connect(function() ci=ci%#opts+1; btn.Text=opts[ci]; DB.Settings[dbKey]=opts[ci]; DBSave(); pcall(cb,opts[ci]) end)
end
local function MkKey(par,lbl,setFn,getFn)
    local f=IB(par,30); local _l=TLbl(f," "..lbl,12,false,"Text"); _l.Size=UDim2.new(0.55,0,1,0)
    local btn=Instance.new("TextButton",f); btn.Size=UDim2.new(0.38,0,0,21); btn.Position=UDim2.new(0.59,0,0.5,-10.5)
    btn.BackgroundColor3=T.Button; btn.BorderSizePixel=0; btn.Font=Enum.Font.Code; btn.TextSize=11
    btn.Text=getFn(); btn.ZIndex=131; btn.TextColor3=T.Text
    Stroke(btn,1,"StrokeItem"); Hover(btn,"Button"); Reg(btn,"BackgroundColor3","Button"); Reg(btn,"TextColor3","Text")
    local waiting=false; local conn
    btn.MouseButton1Click:Connect(function()
        if waiting then waiting=false; if conn then conn:Disconnect(); conn=nil end; btn.Text=getFn(); TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=T.Button}):Play(); return end
        waiting=true; btn.Text="[ ? ]"; TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(25,40,80)}):Play()
        conn=UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if i.UserInputType==Enum.UserInputType.Keyboard then
                setFn(i.KeyCode); btn.Text=getFn(); waiting=false
                TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=T.Button}):Play()
                if conn then conn:Disconnect(); conn=nil end
            end
        end)
    end)
end
local function MkBtn(par,lbl,cb)
    local btn=Instance.new("TextButton",par); btn.Size=UDim2.new(1,0,0,30)
    btn.BackgroundColor3=T.Button; btn.BorderSizePixel=0; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.Text=lbl; btn.ZIndex=130; btn.LayoutOrder=NLO(); btn.TextColor3=T.Text
    Stroke(btn,1,"Stroke"); Hover(btn,"Button"); Reg(btn,"BackgroundColor3","Button"); Reg(btn,"TextColor3","Text")
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
end
local function MkGroup(par,lbl,mainCB,buildInner)
    local outer=Instance.new("Frame",par); outer.Size=UDim2.new(1,0,0,0); outer.AutomaticSize=Enum.AutomaticSize.Y
    outer.BackgroundTransparency=1; outer.BorderSizePixel=0; outer.ZIndex=128; outer.LayoutOrder=NLO()
    Instance.new("UIListLayout",outer).SortOrder=Enum.SortOrder.LayoutOrder
    local hrow=Instance.new("Frame",outer); hrow.Size=UDim2.new(1,0,0,30); hrow.BackgroundColor3=T.Item; hrow.BorderSizePixel=0; hrow.ZIndex=130; hrow.LayoutOrder=1
    Stroke(hrow,1,"StrokeItem"); Reg(hrow,"BackgroundColor3","Item")
    local cl=Instance.new("TextButton",hrow); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.Text=""; cl.ZIndex=134
    local hl=TLbl(hrow," "..lbl,12,false,"Text"); hl.Size=UDim2.new(1,-52,1,0)
    local arr=TLbl(hrow,">",10,true,"TextDim"); arr.Size=UDim2.new(0,14,0,14); arr.Position=UDim2.new(1,-58,0.5,-7); arr.TextXAlignment=Enum.TextXAlignment.Center
    local _,ind=MkSw(hrow)
    local inn=Instance.new("Frame",outer); inn.Size=UDim2.new(1,0,0,0); inn.AutomaticSize=Enum.AutomaticSize.None
    inn.BackgroundTransparency=1; inn.BorderSizePixel=0; inn.ZIndex=129; inn.LayoutOrder=2; inn.ClipsDescendants=true; inn.Visible=false
    Instance.new("UIListLayout",inn).SortOrder=Enum.SortOrder.LayoutOrder; MkPad(inn,2,2,10,0)
    local sv=LO.v; LO.v=0; buildInner(inn); LO.v=sv
    local on=(DB.Toggles[lbl]==true)
    local function sExp(s)
        if s then inn.Visible=true; inn.AutomaticSize=Enum.AutomaticSize.Y; arr.Text="v"
        else inn.AutomaticSize=Enum.AutomaticSize.None; inn.Size=UDim2.new(1,0,0,0); inn.Visible=false; arr.Text=">" end
    end
    local function sV(s) TS:Create(ind,TweenInfo.new(0.14),{Position=UDim2.new(s and 1 or 0,s and -11 or 2,0.5,-4.5),BackgroundColor3=s and T.ToggleOn or T.ToggleOff}):Play() end
    sV(on); sExp(on); if on then task.spawn(function() pcall(mainCB,true) end) end
    cl.MouseButton1Click:Connect(function() on=not on; DB.Toggles[lbl]=on; DBSave(); sV(on); sExp(on); pcall(mainCB,on) end)
    return outer
end

-- ============================================================
-- TABS
-- ============================================================
local TABS={"VISUALS","AIMBOT","RAGE","FEATURES","SETTINGS"}
local TabBtns={}; local TabFrames={}; local ActiveTab=nil; local TAB_W=96
local TabLine,BindsPanel,BindsCont,RebuildBP

do
    TabLine=Instance.new("Frame",MenuTabBar)
    TabLine.Size=UDim2.new(0,0,0,2); TabLine.Position=UDim2.new(0,0,1,-2)
    TabLine.BackgroundColor3=T.TabLine; TabLine.BorderSizePixel=0; TabLine.ZIndex=114
    Reg(TabLine,"BackgroundColor3","TabLine")

    for i,name in ipairs(TABS) do
        local btn=Instance.new("TextButton",MenuTabBar)
        btn.Size=UDim2.new(0,TAB_W,1,0); btn.Position=UDim2.new(0,(i-1)*(TAB_W+2)+6,0,0)
        btn.BackgroundTransparency=1; btn.BorderSizePixel=0; btn.Font=Enum.Font.GothamBold
        btn.TextSize=11; btn.Text=name; btn.ZIndex=113
        btn.TextColor3=name=="RAGE" and Color3.fromRGB(200,60,60) or T.TextDim
        if name~="RAGE" then Reg(btn,"TextColor3","TextDim") end
        btn.MouseEnter:Connect(function() if ActiveTab~=name then TS:Create(btn,TweenInfo.new(0.12),{TextColor3=T.Text}):Play() end end)
        btn.MouseLeave:Connect(function() if ActiveTab~=name then TS:Create(btn,TweenInfo.new(0.12),{TextColor3=name=="RAGE" and Color3.fromRGB(200,60,60) or T.TextDim}):Play() end end)
        TabBtns[name]=btn
        local tf=Instance.new("Frame",MenuContent)
        tf.Size=UDim2.new(1,0,0,0); tf.AutomaticSize=Enum.AutomaticSize.Y
        tf.BackgroundTransparency=1; tf.Visible=false; tf.ZIndex=120; tf.BorderSizePixel=0
        MkLL(tf,2); MkPad(tf,4,8,0,0); TabFrames[name]=tf
    end
end

-- Binds Panel
do
    BindsPanel=Instance.new("Frame",GUI)
    BindsPanel.Size=UDim2.new(0,230,0,30); BindsPanel.AutomaticSize=Enum.AutomaticSize.Y
    BindsPanel.Position=UDim2.new(0,10,0.5,-60); BindsPanel.BackgroundColor3=T.BG
    BindsPanel.BorderSizePixel=0; BindsPanel.ZIndex=300; BindsPanel.Visible=false
    Stroke(BindsPanel,1,"Stroke"); Reg(BindsPanel,"BackgroundColor3","BG"); Drag(BindsPanel)
    local bt=Instance.new("TextLabel",BindsPanel)
    bt.Size=UDim2.new(1,0,0,26); bt.BackgroundTransparency=1; bt.Font=Enum.Font.GothamBold
    bt.TextSize=12; bt.ZIndex=301; bt.Text="BINDS"; bt.TextColor3=T.Sep; Reg(bt,"TextColor3","Sep")
    BindsCont=Instance.new("Frame",BindsPanel)
    BindsCont.Size=UDim2.new(1,0,0,0); BindsCont.AutomaticSize=Enum.AutomaticSize.Y
    BindsCont.Position=UDim2.new(0,0,0,30); BindsCont.BackgroundTransparency=1
    BindsCont.BorderSizePixel=0; BindsCont.ZIndex=302; MkLL(BindsCont,0); MkPad(BindsCont,2,5,8,8)
end

RebuildBP=function()
    for _,c in ipairs(BindsCont:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local function kn(k) return k and tostring(k):gsub("Enum.KeyCode.","") or "None" end
    local entries={
        {"Menu",tostring(S.MenuKey):gsub("Enum.KeyCode.","")},
        {"Aimbot",S.A.BindKey and kn(S.A.BindKey) or "Mouse2"},
        {"Speed",kn(S.F.SpeedBind)},{"Fly",kn(S.F.FlyBind)},
        {"FreeCam",kn(S.F.FreeCamBind)},{"Zoom",kn(S.F.ZoomBind)},
        {"3rd Person",kn(S.F.ThirdPersonBind)},{"Desync",kn(S.F.DesyncBind)},
    }
    for i,e in ipairs(entries) do
        local f=Instance.new("Frame",BindsCont); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=i
        local k=TLbl(f,e[1],11,true,"TextDim"); k.Size=UDim2.new(0.55,0,1,0)
        local v=TLbl(f,e[2],11,false,"Text"); v.Size=UDim2.new(0.45,0,1,0); v.Position=UDim2.new(0.55,0,0,0); v.TextXAlignment=Enum.TextXAlignment.Right; v.Font=Enum.Font.Code
    end
end
RebuildBP()

-- ============================================================
-- TARGET HUD
-- ============================================================
local THUD,TIcon,TName,THPLbl,THPFill,TDist,TEquip
local thudACache,lastThudP={},nil

do
    THUD=Instance.new("Frame",GUI)
    THUD.Size=UDim2.new(0,290,0,112); THUD.Position=UDim2.new(0.5,-145,0.73,0)
    THUD.BackgroundColor3=T.BG; THUD.BorderSizePixel=0; THUD.ZIndex=400; THUD.Visible=false
    Stroke(THUD,2,"Stroke"); Reg(THUD,"BackgroundColor3","BG"); Drag(THUD)

    do
        local hdr=Instance.new("Frame",THUD); hdr.Size=UDim2.new(1,0,0,22); hdr.BackgroundColor3=T.Header; hdr.BorderSizePixel=0; hdr.ZIndex=401; Reg(hdr,"BackgroundColor3","Header")
        local hl=Instance.new("TextLabel",hdr); hl.Size=UDim2.new(1,-10,1,0); hl.Position=UDim2.new(0,8,0,0); hl.BackgroundTransparency=1; hl.Text="TARGET INFO"; hl.Font=Enum.Font.GothamBold; hl.TextSize=10; hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=402; hl.TextColor3=T.TextDim; Reg(hl,"TextColor3","TextDim")
    end

    TIcon=Instance.new("ImageLabel",THUD); TIcon.Size=UDim2.new(0,44,0,44); TIcon.Position=UDim2.new(0,8,0,28); TIcon.BackgroundColor3=T.Item; TIcon.BorderSizePixel=0; TIcon.ZIndex=402; Stroke(TIcon,1,"StrokeItem"); Reg(TIcon,"BackgroundColor3","Item"); Instance.new("UICorner",TIcon).CornerRadius=UDim.new(1,0)
    TName=Instance.new("TextLabel",THUD); TName.Size=UDim2.new(1,-62,0,18); TName.Position=UDim2.new(0,58,0,26); TName.BackgroundTransparency=1; TName.Text="Target"; TName.Font=Enum.Font.GothamBold; TName.TextSize=14; TName.TextXAlignment=Enum.TextXAlignment.Left; TName.ZIndex=402; TName.TextColor3=T.Text; Reg(TName,"TextColor3","Text")
    THPLbl=Instance.new("TextLabel",THUD); THPLbl.Size=UDim2.new(1,-62,0,14); THPLbl.Position=UDim2.new(0,58,0,46); THPLbl.BackgroundTransparency=1; THPLbl.Text="HP: --"; THPLbl.Font=Enum.Font.Gotham; THPLbl.TextSize=10; THPLbl.TextXAlignment=Enum.TextXAlignment.Left; THPLbl.ZIndex=402; THPLbl.TextColor3=T.Text; Reg(THPLbl,"TextColor3","Text")

    do
        local hpbg=Instance.new("Frame",THUD); hpbg.Size=UDim2.new(1,-62,0,5); hpbg.Position=UDim2.new(0,58,0,62); hpbg.BackgroundColor3=T.SliderBG; hpbg.BorderSizePixel=0; hpbg.ZIndex=402; Reg(hpbg,"BackgroundColor3","SliderBG")
        THPFill=Instance.new("Frame",hpbg); THPFill.Size=UDim2.new(1,0,1,0); THPFill.BackgroundColor3=Color3.fromRGB(80,200,100); THPFill.BorderSizePixel=0; THPFill.ZIndex=403
    end

    TDist=Instance.new("TextLabel",THUD); TDist.Size=UDim2.new(1,-62,0,14); TDist.Position=UDim2.new(0,58,0,70); TDist.BackgroundTransparency=1; TDist.Text="Dist: 0 st"; TDist.Font=Enum.Font.Gotham; TDist.TextSize=10; TDist.TextXAlignment=Enum.TextXAlignment.Left; TDist.ZIndex=402; TDist.TextColor3=T.TextDim; Reg(TDist,"TextColor3","TextDim")
    TEquip=Instance.new("TextLabel",THUD); TEquip.Size=UDim2.new(1,-16,0,16); TEquip.Position=UDim2.new(0,8,0,94); TEquip.BackgroundTransparency=1; TEquip.Text="Tool: None"; TEquip.Font=Enum.Font.Gotham; TEquip.TextSize=10; TEquip.TextXAlignment=Enum.TextXAlignment.Left; TEquip.ZIndex=402; TEquip.TextColor3=T.TextDim; Reg(TEquip,"TextColor3","TextDim")
end

local function UpdateTHUD(tgt)
    if not S.A.TargetHUD or not tgt or not tgt.Character then THUD.Visible=false; lastThudP=nil; return end
    local char=tgt.Character; local hum=char:FindFirstChildOfClass("Humanoid"); local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then THUD.Visible=false; return end
    THUD.Visible=true; TName.Text=tgt.Name
    if lastThudP~=tgt then
        lastThudP=tgt
        task.spawn(function()
            if thudACache[tgt.UserId] then TIcon.Image=thudACache[tgt.UserId]; return end
            local ok,img=pcall(function() return Players:GetUserThumbnailAsync(tgt.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
            if ok then thudACache[tgt.UserId]=img; TIcon.Image=img end
        end)
    end
    local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    THPFill.Size=UDim2.new(hp,0,1,0); THPFill.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(200*hp),0)
    THPLbl.Text=("HP: %d / %d"):format(math.floor(hum.Health),math.floor(hum.MaxHealth))
    TDist.Text="Dist: "..math.floor((Cam.CFrame.Position-hrp.Position).Magnitude).." st"
    local tool="None"; for _,c in ipairs(char:GetChildren()) do if c:IsA("Tool") then tool=c.Name; break end end
    TEquip.Text="Tool: "..tool
end

-- ============================================================
-- SWITCH TAB + BUILDERS
-- ============================================================
local BUILDERS={}

local function BuildTab(name)
    local tf=TabFrames[name]
    for _,c in ipairs(tf:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    LO.v=0; if BUILDERS[name] then BUILDERS[name](tf) end
end

local function SwitchTab(name)
    if ActiveTab==name then return end; ActiveTab=name
    for k,tf in pairs(TabFrames) do
        tf.Visible=false
        TS:Create(TabBtns[k],TweenInfo.new(0.12),{TextColor3=k=="RAGE" and Color3.fromRGB(200,60,60) or T.TextDim}):Play()
    end
    TabFrames[name].Visible=true
    TS:Create(TabBtns[name],TweenInfo.new(0.12),{TextColor3=T.Text}):Play()
    local tb=TabBtns[name]
    TS:Create(TabLine,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{
        Position=UDim2.new(0,tb.Position.X.Offset,1,-2),
        Size=UDim2.new(0,TAB_W,0,2),
        BackgroundColor3=name=="RAGE" and Color3.fromRGB(255,50,50) or T.TabLine
    }):Play()
    BuildTab(name)
end
for _,n in ipairs(TABS) do TabBtns[n].MouseButton1Click:Connect(function() SwitchTab(n) end) end

-- ============================================================
-- RENDER HELPERS
-- ============================================================
local function RenderESP(p,obj)
    local char=p and p.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid"); local head=char and char:FindFirstChild("Head")
    if not(hrp and hum and head and hum.Health>0 and S.V.ESP) then HideESP(obj); return end
    local cSP,cOn=Cam:WorldToViewportPoint(hrp.Position); if not cOn then HideESP(obj); return end
    local tSP=Cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.8,0))
    local bSP=Cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
    local bH=math.max(math.abs(tSP.Y-bSP.Y),1); local bW=bH*0.55
    local bX=cSP.X-bW*0.5; local bY=math.min(tSP.Y,bSP.Y)
    local ec=GetESPColor(p); local bt=math.clamp((DB.Sliders.ESPBoxThick or 20)/10,1.5,4)
    if obj.filled then obj.filled.Visible=S.V.Filled; if S.V.Filled then obj.filled.Position=Vector2.new(bX,bY); obj.filled.Size=Vector2.new(bW,bH); obj.filled.Color=ec end end
    if obj.boxSh then obj.boxSh.Visible=S.V.Box; if S.V.Box then obj.boxSh.Position=Vector2.new(bX-1,bY-1); obj.boxSh.Size=Vector2.new(bW+2,bH+2) end end
    if obj.box then obj.box.Visible=S.V.Box; if S.V.Box then obj.box.Position=Vector2.new(bX,bY); obj.box.Size=Vector2.new(bW,bH); obj.box.Color=ec; obj.box.Thickness=bt end end
    do
        if obj.head then
            if S.V.Head then
                local hSP,hOn=Cam:WorldToViewportPoint(head.Position)
                if hOn then local hs=bW*0.45; obj.head.Visible=true; obj.head.Position=Vector2.new(hSP.X-hs*0.5,hSP.Y-hs*0.5); obj.head.Size=Vector2.new(hs,hs); obj.head.Color=ec; if obj.headSh then obj.headSh.Visible=true; obj.headSh.Position=Vector2.new(hSP.X-hs*0.5-1,hSP.Y-hs*0.5-1); obj.headSh.Size=Vector2.new(hs+2,hs+2) end
                else obj.head.Visible=false; if obj.headSh then obj.headSh.Visible=false end end
            else obj.head.Visible=false; if obj.headSh then obj.headSh.Visible=false end end
        end
    end
    if obj.name then obj.name.Visible=S.V.Name; if S.V.Name then obj.name.Text=p.Name; obj.name.Position=Vector2.new(cSP.X,bY-16); obj.name.Color=ec end end
    if obj.dist then obj.dist.Visible=S.V.Dist; if S.V.Dist then obj.dist.Text=math.floor((Cam.CFrame.Position-hrp.Position).Magnitude).." st"; obj.dist.Position=Vector2.new(cSP.X,bY+bH+3) end end
    do
        if obj.hpbg and obj.hp then
            obj.hpbg.Visible=S.V.HP; obj.hp.Visible=S.V.HP
            if S.V.HP then
                local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1); local bx2=bX-7
                obj.hpbg.Position=Vector2.new(bx2,bY); obj.hpbg.Size=Vector2.new(4,bH)
                obj.hp.Position=Vector2.new(bx2,bY+bH*(1-hp)); obj.hp.Size=Vector2.new(4,bH*hp)
                obj.hp.Color=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(200*hp),0)
            end
        end
    end
    if obj.avatarBB and obj.avatarImg then
        if S.V.ShowAvatar then
            obj.avatarBB.Adornee=hrp; if obj.avatarBB.Parent~=GUI then obj.avatarBB.Parent=GUI end; obj.avatarBB.Enabled=true
            local img=AvatarCache[p.UserId]; if img and img~="pending" and obj.avatarImg.Image~=img then obj.avatarImg.Image=img end
            if obj.avatarStroke then obj.avatarStroke.Color=ec end
        else obj.avatarBB.Enabled=false end
    end
    if S.V.Skel then
        local bones=GetBones(char)
        for i,b in ipairs(obj.skel) do
            local bd=bones[i]
            if bd then
                local p1=char:FindFirstChild(bd[1]); local p2=char:FindFirstChild(bd[2])
                if p1 and p2 then
                    local s1,v1=Cam:WorldToViewportPoint(p1.Position); local s2,v2=Cam:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        if b.sh then b.sh.Visible=true; b.sh.From=Vector2.new(s1.X,s1.Y); b.sh.To=Vector2.new(s2.X,s2.Y) end
                        if b.l then b.l.Visible=true; b.l.From=Vector2.new(s1.X,s1.Y); b.l.To=Vector2.new(s2.X,s2.Y); b.l.Color=ec end
                    else if b.l then b.l.Visible=false end; if b.sh then b.sh.Visible=false end end
                else if b.l then b.l.Visible=false end; if b.sh then b.sh.Visible=false end end
            else if b.l then b.l.Visible=false end; if b.sh then b.sh.Visible=false end end
        end
    else for _,b in ipairs(obj.skel) do if b.l then b.l.Visible=false end; if b.sh then b.sh.Visible=false end end end
end

local function RenderFOV(mp)
    if FOVCirc then FOVCirc.Visible=S.A.ShowFOV and S.A.En; if FOVCirc.Visible then FOVCirc.Position=mp; FOVCirc.Radius=S.A.FOV; FOVCirc.Color=T.AimFOV end end
    if SAFOVCirc then SAFOVCirc.Visible=S.A.SAEn and S.A.SAShowFOV; if SAFOVCirc.Visible then SAFOVCirc.Position=mp; SAFOVCirc.Radius=S.A.SAFOV; SAFOVCirc.Color=T.SAFOVColor end end
    if RageFOVCirc then RageFOVCirc.Visible=S.R.En; if RageFOVCirc.Visible then RageFOVCirc.Position=mp; RageFOVCirc.Radius=S.R.FOV; RageFOVCirc.Color=T.RageFOVColor; RageFOVCirc.Transparency=math.sin(tick()*4)*0.2+0.6 end end
end

local function RenderCX(mp,dt)
    if not S.F.CrosshairEn then
        if CXDot then CXDot.Visible=false end; if CXOut then CXOut.Visible=false end
        for _,c in ipairs(CXLines) do if c.l then c.l.Visible=false end; if c.o then c.o.Visible=false end end; return
    end
    if S.F.CrosshairStyle=="DOT" then
        if CXDot then CXDot.Visible=true; CXDot.Position=mp; CXDot.Color=T.CrosshairColor end
        if CXOut then CXOut.Visible=true; CXOut.Position=mp end
        for _,c in ipairs(CXLines) do if c.l then c.l.Visible=false end; if c.o then c.o.Visible=false end end
    else
        if CXDot then CXDot.Visible=false end; if CXOut then CXOut.Visible=false end
        CXAngle=CXAngle+dt*110
        for i,c in ipairs(CXLines) do
            local a=math.rad(CXAngle+(i-1)*90)
            local p1=Vector2.new(mp.X+math.cos(a)*4,mp.Y+math.sin(a)*4)
            local p2=Vector2.new(mp.X+math.cos(a)*16,mp.Y+math.sin(a)*16)
            if c.o then c.o.Visible=true; c.o.From=p1; c.o.To=p2 end
            if c.l then c.l.Visible=true; c.l.From=p1; c.l.To=p2; c.l.Color=T.CrosshairColor end
        end
    end
end

-- Main Loop
RS.Heartbeat:Connect(function(dt)
    local mp=UIS:GetMouseLocation()
    for p,obj in pairs(ESPObj) do RenderESP(p,obj) end
    RenderFOV(mp); RenderCX(mp,dt)
    if S.A.En and AimState.Active then
        if not S.A.Sticky then AimState.Target=GetTgt() end
        if AimState.Target then
            DoAim(AimState.Target,dt)
            if S.A.AutoShoot then
                local part=AimState.Target.Character and FindPart(AimState.Target.Character,S.A.HitPart)
                if part then local sp,os=Cam:WorldToViewportPoint(part.Position); if os and (Vector2.new(sp.X,sp.Y)-mp).Magnitude<35 then SafeAutoShoot(Vector2.new(sp.X,sp.Y)) end end
            end
        end
    end
    if S.R.En then
        local rt=GetRageTgt(); S.R.Target=rt
        if rt then
            DoRageAim(rt,dt)
            if S.R.AutoShoot then
                local part=rt.Character and FindPart(rt.Character,S.R.HitPart)
                if part then local sp,os=Cam:WorldToViewportPoint(part.Position); if os and (Vector2.new(sp.X,sp.Y)-mp).Magnitude<35 then SafeAutoShoot(Vector2.new(sp.X,sp.Y)) end end
            end
        end
    end
    local cur=nil
    if S.A.En and AimState.Active and AimState.Target then cur=AimState.Target end
    if not cur and S.R.En and S.R.Target then cur=S.R.Target end
    if not cur and S.A.SAEn then cur=GetSATgt() end
    UpdateTHUD(cur)
    if S.F.SpeedEn and S.F.SpeedType=="Toggle" and SpeedState.Active then local h=GetHum(); if h and h.WalkSpeed~=S.F.Speed then h.WalkSpeed=S.F.Speed end end
end)

-- ============================================================
-- TAB BUILDERS (ПОЛНОСТЬЮ)
-- ============================================================
do -- VISUALS
    BUILDERS["VISUALS"]=function(tf)
        MkSep(tf,"PLAYER ESP")
        MkGroup(tf,"Player ESP",function(v) S.V.ESP=v end,function(inn)
            MkToggle(inn,"Box",function(v) S.V.Box=v end)
            MkToggle(inn,"Head Box",function(v) S.V.Head=v end)
            MkToggle(inn,"Name",function(v) S.V.Name=v end)
            MkToggle(inn,"Distance",function(v) S.V.Dist=v end)
            MkToggle(inn,"HP Bar",function(v) S.V.HP=v end)
            MkToggle(inn,"Skeleton",function(v) S.V.Skel=v end)
            MkToggle(inn,"Filled",function(v) S.V.Filled=v end)
            MkToggle(inn,"Show Avatar",function(v)
                S.V.ShowAvatar=v
                if not v then for _,obj in pairs(ESPObj) do if obj.avatarBB then obj.avatarBB.Enabled=false end end end
            end)
            MkToggle(inn,"Team Check",function(v) S.V.TeamCheck=v end)
            MkSlider(inn,"Box Thickness",10,40,"ESPBoxThick",function(v) end)
            MkSep(inn,"ENEMY COLOR"); MkRGB(inn,"Enemy","ESPBoxR","ESPBoxG","ESPBoxB",function(c) S.V.ESPBoxColor=c end)
            MkSep(inn,"ALLY COLOR"); MkRGB(inn,"Ally","ESPAllyR","ESPAllyG","ESPAllyB",function(c) S.V.ESPAllyColor=c end)
        end)
        MkSep(tf,"LOCAL CHAMS V1 — Drawing")
        MkGroup(tf,"Local Chams V1",function(v) S.V.LocalChams=v end,function(inn)
            MkDrop(inn,"Style",{"Outline","Filled","Glow"},"LocalChamsStyle",function(v) S.V.LocalChamsStyle=v end)
            MkSlider(inn,"Transparency",0,90,"LocalChamsTransp",function(v) S.V.LocalChamsTransp=v/100 end)
        end)
        MkSep(tf,"LOCAL CHAMS V2 — ForceField")
        MkGroup(tf,"Local Chams V2",function(v) S.V.LCV2=v; if v then EnableLC2() else DisableLC2() end end,function(inn)
            MkDrop(inn,"Style",{"Filled","Rainbow","Neon","Glass","Invisible"},"LCV2Style",function(v) S.V.LCV2Style=v end)
            MkSlider(inn,"Transparency",0,95,"LCV2Transp",function(v) S.V.LCV2Transp=v/100 end)
            MkSep(inn,"COLOR"); MkRGB(inn,"Color","LCV2R","LCV2G","LCV2B",function(c) S.V.LCV2Color=c end)
        end)
    end
end

do -- AIMBOT
    BUILDERS["AIMBOT"]=function(tf)
        MkSep(tf,"AIMBOT")
        MkGroup(tf,"Aimbot",function(v) S.A.En=v end,function(inn)
            MkKey(inn,"Bind",function(k) S.A.BindKey=k; RebuildBP() end,function() return S.A.BindKey and tostring(S.A.BindKey):gsub("Enum.KeyCode.","") or "Mouse2" end)
            MkDrop(inn,"Type",{"Hold","Toggle"},"AimType",function(v) S.A.Type=v end)
            MkDrop(inn,"Mode",{"Smooth","Snap"},"AimMode",function(v) S.A.Mode=v end)
            MkSlider(inn,"Smooth",1,20,"AimbotSmooth",function(v) S.A.Smooth=v end)
            MkSlider(inn,"Hit Chance %",10,100,"HitChance",function(v) S.A.HitChance=v end)
            MkSlider(inn,"FOV",50,600,"AimbotFOV",function(v) S.A.FOV=v end)
            MkSlider(inn,"Max Distance",50,1000,"AimMaxDistance",function(v) S.A.MaxDistance=v end)
            MkSlider(inn,"Reaction Time ms",0,500,"AimReactionTime",function(v) S.A.ReactionTime=v/1000 end)
            MkSlider(inn,"Shake",0,100,"AimShakeAmount",function(v) S.A.ShakeAmount=v/100 end)
            MkDrop(inn,"Hit Part",{"Head","Torso","HumanoidRootPart","Left Arm","Right Arm"},"AimHitPart",function(v) S.A.HitPart=v; DB.Settings.AimHitPart=v; DBSave() end)
            MkSep(inn,"OPTIONS")
            MkToggle(inn,"Show FOV",function(v) S.A.ShowFOV=v end)
            MkToggle(inn,"Prediction",function(v) S.A.Predict=v end)
            MkToggle(inn,"Sticky",function(v) S.A.Sticky=v end)
            MkToggle(inn,"Hit Notifier",function(v) S.A.HitNotify=v end)
            MkToggle(inn,"Target HUD",function(v) S.A.TargetHUD=v; if not v then THUD.Visible=false end end)
            MkToggle(inn,"Bypass Mode",function(v) S.A.BypassMode=v end)
            MkSep(inn,"WEAPON")
            MkToggle(inn,"Auto Shoot",function(v) S.A.AutoShoot=v end)
            MkToggle(inn,"No Recoil",function(v) S.A.NoRecoil=v; if v then StartNoRecoil("aim") end end)
            MkToggle(inn,"No Spread",function(v) S.A.NoSpread=v end)
            MkToggle(inn,"Force Auto",function(v) S.A.ForceAuto=v; if v then StartForceAuto() end end)
        end)
        MkSep(tf,"SILENT AIM")
        MkGroup(tf,"Silent Aim",function(v) S.A.SAEn=v end,function(inn)
            MkDrop(inn,"Method",{"Mouse","Distance"},"SAMethod",function(v) S.A.SAMethod=v end)
            MkDrop(inn,"Bone",{"Head","Torso","HumanoidRootPart","Left Arm","Right Arm"},"SABone",function(v) S.A.SABone=v; DB.Settings.SABone=v; DBSave() end)
            MkSlider(inn,"SA FOV",10,600,"SAFOV",function(v) S.A.SAFOV=v end)
            MkToggle(inn,"Show SA FOV",function(v) S.A.SAShowFOV=v end)
        end)
        
        -- ====== AIM MANIPULATION ======
        MkSep(tf,"AIM MANIPULATION")
        MkGroup(tf,"Aim Manipulation",function(v) 
            S.A.AimManip=v
            if v then ScanForBypass() end
        end,function(inn)
            do
                local so=NLO()
                local sf=Instance.new("Frame",inn); sf.Size=UDim2.new(1,0,0,28); sf.BackgroundColor3=Color3.fromRGB(8,4,18); sf.BorderSizePixel=0; sf.ZIndex=131; sf.LayoutOrder=so
                Stroke(sf,1,"Stroke")
                local dot=Instance.new("Frame",sf); dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,8,0.5,-4); dot.BackgroundColor3=Color3.fromRGB(60,60,60); dot.BorderSizePixel=0; dot.ZIndex=132
                Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                local lbl=Instance.new("TextLabel",sf); lbl.Size=UDim2.new(1,-24,1,0); lbl.Position=UDim2.new(0,22,0,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.Code; lbl.TextSize=10; lbl.Text="Scanning..."; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=132; lbl.TextColor3=Color3.fromRGB(150,150,150)
                
                RS.Heartbeat:Connect(function()
                    if not(dot and dot.Parent) then return end
                    if S.A.AimManip then
                        if AimManip.Scanning then
                            dot.BackgroundColor3=Color3.fromRGB(255,200,0)
                            lbl.Text=S.A.ManipStatus
                            lbl.TextColor3=Color3.fromRGB(255,200,0)
                        elseif AimManip.BypassFound then
                            dot.BackgroundColor3=Color3.fromRGB(50,255,50)
                            lbl.Text=S.A.ManipStatus
                            lbl.TextColor3=Color3.fromRGB(50,255,50)
                        else
                            dot.BackgroundColor3=Color3.fromRGB(220,60,60)
                            lbl.Text=S.A.ManipStatus
                            lbl.TextColor3=Color3.fromRGB(220,60,60)
                        end
                    else
                        dot.BackgroundColor3=Color3.fromRGB(60,60,60)
                        lbl.Text="Disabled"
                        lbl.TextColor3=Color3.fromRGB(150,150,150)
                    end
                end)
            end
        end)
    end
end

do -- RAGE
    BUILDERS["RAGE"]=function(tf)
        MkSep(tf,"RAGE AIMBOT")
        MkGroup(tf,"Rage Aimbot",function(v) S.R.En=v; S.R.Active=v; if not v then StopAntiAim() end end,function(inn)
            MkSlider(inn,"FOV",50,800,"RageFOV",function(v) S.R.FOV=v end)
            MkSlider(inn,"Snap Speed",1,20,"RageSmooth",function(v) S.R.Smooth=v end)
            MkDrop(inn,"Hit Part",{"Head","Torso","HumanoidRootPart","Left Arm","Right Arm"},"RageHitPart",function(v) S.R.HitPart=v; DB.Settings.RageHitPart=v; DBSave() end)
            MkToggle(inn,"Auto Shoot",function(v) S.R.AutoShoot=v end)
            MkSep(inn,"MODS")
            MkToggle(inn,"No Recoil",function(v) S.R.NoRecoil=v; if v then StartNoRecoil("rage") end end)
            MkToggle(inn,"No Spread",function(v) S.R.NoSpread=v end)
            MkToggle(inn,"Force Auto",function(v) S.R.ForceAuto=v; if v then StartForceAuto() end end)
            MkToggle(inn,"Force Headshot",function(v) S.R.ForceHeadshot=v end)
            MkSep(inn,"ANTI-AIM")
            MkToggle(inn,"Anti-Aim",function(v) S.R.AntiAim=v; if v then StartAntiAim() else StopAntiAim() end end)
            MkSlider(inn,"AA Offset",0,360,"AntiAimOffset",function(v) S.R.AntiAimOffset=v end)
        end)
        do
            local so=NLO()
            local sf=Instance.new("Frame",tf); sf.Size=UDim2.new(1,0,0,32); sf.BackgroundColor3=T.Item; sf.BorderSizePixel=0; sf.ZIndex=130; sf.LayoutOrder=so; Stroke(sf,1,"StrokeItem"); Reg(sf,"BackgroundColor3","Item")
            local dot=Instance.new("Frame",sf); dot.Size=UDim2.new(0,10,0,10); dot.Position=UDim2.new(0,10,0.5,-5); dot.BackgroundColor3=Color3.fromRGB(60,60,60); dot.BorderSizePixel=0; dot.ZIndex=131; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local lbl=Instance.new("TextLabel",sf); lbl.Size=UDim2.new(1,-30,1,0); lbl.Position=UDim2.new(0,28,0,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.Text="RAGE: OFFLINE"; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=131; lbl.TextColor3=Color3.fromRGB(150,150,150)
            RS.Heartbeat:Connect(function()
                if not(dot and dot.Parent) then return end
                if S.R.En then local rt=GetRageTgt(); if rt then dot.BackgroundColor3=Color3.fromRGB(255,50,50); lbl.Text="RAGE: LOCKED — "..rt.Name; lbl.TextColor3=Color3.fromRGB(255,80,80)
                else dot.BackgroundColor3=Color3.fromRGB(255,200,0); lbl.Text="RAGE: SCANNING..."; lbl.TextColor3=Color3.fromRGB(255,200,0) end
                else dot.BackgroundColor3=Color3.fromRGB(60,60,60); lbl.Text="RAGE: OFFLINE"; lbl.TextColor3=Color3.fromRGB(150,150,150) end
            end)
        end
    end
end

do -- FEATURES
    local function BFMove(tf)
        MkSep(tf,"MOVEMENT")
        MkGroup(tf,"SpeedHack",function(v) S.F.SpeedEn=v; if not v then SetSpeed(false) end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.SpeedBind=k; RebuildBP() end,function() return S.F.SpeedBind and tostring(S.F.SpeedBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Hold","Toggle"},"SpeedType",function(v) S.F.SpeedType=v end)
            MkSlider(inn,"Speed",5,150,"Speed",function(v) S.F.Speed=v; if SpeedState.Active then local h=GetHum(); if h then h.WalkSpeed=v end end end)
        end)
        MkGroup(tf,"Fly",function(v) S.F.FlyEn=v; if not v then DisableFly() end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.FlyBind=k; RebuildBP() end,function() return S.F.FlyBind and tostring(S.F.FlyBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Hold","Toggle"},"FlyType",function(v) S.F.FlyType=v end)
            MkSlider(inn,"Speed",5,200,"FlySpeed",function(v) S.F.FlySpeed=v end)
        end)
        MkGroup(tf,"FreeCam",function(v) S.F.FreeCamEn=v; if not v then DisableFC() end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.FreeCamBind=k; RebuildBP() end,function() return S.F.FreeCamBind and tostring(S.F.FreeCamBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Hold","Toggle"},"FreeCamType",function(v) S.F.FreeCamType=v end)
        end)
    end
    local function BFCam(tf)
        MkSep(tf,"CAMERA")
        MkGroup(tf,"FOV Zoom",function(v) S.F.ZoomEn=v; if not v then DisableZoom() end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.ZoomBind=k; RebuildBP() end,function() return S.F.ZoomBind and tostring(S.F.ZoomBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Hold","Toggle"},"ZoomType",function(v) S.F.ZoomType=v end)
            MkSlider(inn,"FOV",20,120,"ZoomFOV",function(v) S.F.ZoomFOV=v; if S.F.ZoomActive then Cam.FieldOfView=v end end)
        end)
        MkGroup(tf,"Third Person",function(v) S.F.ThirdPersonEn=v; if not v then DisableThirdPerson() end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.ThirdPersonBind=k; RebuildBP() end,function() return S.F.ThirdPersonBind and tostring(S.F.ThirdPersonBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Toggle","Hold"},"ThirdPersonType",function(v) S.F.ThirdPersonType=v end)
            MkSlider(inn,"Distance",3,30,"ThirdPersonDist",function(v) S.F.ThirdPersonDist=v end)
        end)
    end
    local function BFDesync(tf)
        MkSep(tf,"DESYNC")
        MkGroup(tf,"Desync",function(v) S.F.DesyncEn=v; if not v then DisableDesync() end end,function(inn)
            MkKey(inn,"Bind",function(k) S.F.DesyncBind=k; RebuildBP() end,function() return S.F.DesyncBind and tostring(S.F.DesyncBind):gsub("Enum.KeyCode.","") or "None" end)
            MkDrop(inn,"Type",{"Toggle","Hold"},"DesyncType",function(v) S.F.DesyncType=v end)
            MkSlider(inn,"Intensity",1,100,"DesyncIntensity",function(v) S.F.DesyncIntensity=v/100 end)
            MkSlider(inn,"Speed",10,200,"DesyncSpeed",function(v) S.F.DesyncSpeed=v/100 end)
            MkToggle(inn,"Visualizer",function(v) S.F.DesyncDraw=v; if not v then DesyncHideAll() end end)
            do
                local so=NLO()
                local sf=Instance.new("Frame",inn); sf.Size=UDim2.new(1,0,0,26); sf.BackgroundColor3=Color3.fromRGB(8,4,18); sf.BorderSizePixel=0; sf.ZIndex=131; sf.LayoutOrder=so; Stroke(sf,1,"Stroke")
                local dot=Instance.new("Frame",sf); dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,8,0.5,-4); dot.BackgroundColor3=Color3.fromRGB(60,60,60); dot.BorderSizePixel=0; dot.ZIndex=132; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                local lbl=Instance.new("TextLabel",sf); lbl.Size=UDim2.new(1,-24,1,0); lbl.Position=UDim2.new(0,22,0,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.Text="DESYNC: OFFLINE"; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=132; lbl.TextColor3=Color3.fromRGB(150,150,150)
                RS.Heartbeat:Connect(function()
                    if not(dot and dot.Parent) then return end
                    if S.F.DesyncActive then dot.BackgroundColor3=Color3.fromRGB(255,100,50); lbl.Text="DESYNC: ACTIVE"; lbl.TextColor3=Color3.fromRGB(255,120,50)
                    else dot.BackgroundColor3=Color3.fromRGB(60,60,60); lbl.Text="DESYNC: OFFLINE"; lbl.TextColor3=Color3.fromRGB(150,150,150) end
                end)
            end
        end)
    end
    local function BFMisc(tf)
        MkSep(tf,"MISC")
        MkGroup(tf,"Anti-AFK",function(v) S.F.AntiAFKEn=v; if v then StartAFK() else StopAFK() end end,function(inn)
            MkSlider(inn,"Interval sec",5,300,"AntiAFKInterval",function(v) S.F.AntiAFKInterval=v end)
        end)
        MkSep(tf,"CROSSHAIR")
        MkGroup(tf,"Crosshair",function(v) S.F.CrosshairEn=v end,function(inn)
            MkDrop(inn,"Style",{"DOT","Flying"},"CrosshairStyle",function(v) S.F.CrosshairStyle=v end)
        end)
        MkSep(tf,"PANELS")
        MkToggle(tf,"Binds Panel",function(v) S.F.BindsPanelVisible=v; BindsPanel.Visible=v; if v then RebuildBP() end end)
    end
    BUILDERS["FEATURES"]=function(tf) BFMove(tf); BFCam(tf); BFDesync(tf); BFMisc(tf) end
end

do -- SETTINGS
    BUILDERS["SETTINGS"]=function(tf)
        MkSep(tf,"GENERAL")
        MkKey(tf,"Menu Key",function(k) S.MenuKey=k; MenuKeyLabel.Text=tostring(k):gsub("Enum.KeyCode.","").." — toggle"; RebuildBP() end,function() return tostring(S.MenuKey):gsub("Enum.KeyCode.","") end)
        MkToggle(tf,"Streamer Mode",function(v) S.Stream=v; MenuTitle.Text=v and "EXTERNAL" or "KIRIESHKA DLC"; MiniStream.Text=v and "[ STREAM ]" or "" end)
        MkSep(tf,"PERFORMANCE")
        MkToggle(tf,"FPS Boost",function(v) if v then EnableFPS() else DisableFPS() end end)
        MkSep(tf,"APPEARANCE")
        MkDrop(tf,"Theme",{"Blue","Dark","White"},"Theme",function(v) DB.Settings.Theme=v; DBSave(); ApplyTheme(v) end)
        MkDrop(tf,"Language",{"ENG","RU"},"Language",function(v) DB.Settings.Language=v; SetLang(v); DBSave() end)
        MkSep(tf,"INFO")
        MkInfo(tf,"v9.6 | @"..LP.Name.." | ID: "..tostring(LP.UserId))
        MkSep(tf,"DANGER")
        MkBtn(tf,"SELF-DESTRUCT",function()
            Notify(L.selfDestruct,3); task.wait(3)
            WLDelete(); DBDelete(); DisableDesync(); DisableFly(); DisableFC(); DisableThirdPerson(); DisableLC2()
            pcall(function() GUI:Destroy() end)
        end)
        MkBtn(tf,"CLEAR DATA",function() DBDelete(); Notify("Data cleared.",3) end)
    end
end

-- ============================================================
-- KEY INPUT GUI
-- ============================================================
local function BuildKeyGUI(onSuccess)
    local ov=Instance.new("Frame",LoadScreen); ov.Size=UDim2.new(1,0,1,0); ov.BackgroundColor3=Color3.new(0,0,0); ov.BackgroundTransparency=0.4; ov.BorderSizePixel=0; ov.ZIndex=945
    local panel=Instance.new("Frame",LoadScreen); panel.Size=UDim2.new(0,340,0,0); panel.Position=UDim2.new(0.5,-170,0.5,0); panel.BackgroundColor3=T.BG; panel.BorderSizePixel=0; panel.ZIndex=950; panel.ClipsDescendants=true; Stroke(panel,1,"Stroke")
    TS:Create(panel,TweenInfo.new(0.35,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,340,0,220),Position=UDim2.new(0.5,-170,0.5,-110)}):Play()
    local function mkT(txt,sz,bold,yp,h)
        local l=Instance.new("TextLabel",panel); l.Size=UDim2.new(1,0,0,h or 30); l.Position=UDim2.new(0,0,0,yp); l.BackgroundTransparency=1; l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham; l.TextSize=sz; l.Text=txt; l.ZIndex=951; l.TextColor3=T.Text; Reg(l,"TextColor3","Text"); return l
    end
    local title=mkT("KIRIESHKA DLC",18,true,3,36); task.spawn(function() while title and title.Parent do title.TextColor3=RBW() task.wait(0.03) end end)
    mkT("SECURE ACCESS",10,false,39,18); mkT(L.uid..tostring(LP.UserId),9,false,57,16).TextColor3=T.TextDim
    local permKeyLbl=mkT("",8,false,75,14)
    permKeyLbl.TextColor3=Color3.fromRGB(100,200,255)
    permKeyLbl.TextXAlignment=Enum.TextXAlignment.Center
    local existingKey = LoadPermKey()
    if existingKey then
        permKeyLbl.Text=L.permKeyGen.." "..existingKey
    end
    do
        local bar=Instance.new("Frame",panel); bar.Size=UDim2.new(1,0,0,1); bar.Position=UDim2.new(0,0,0,92); bar.BackgroundColor3=T.Divider; bar.BorderSizePixel=0; bar.ZIndex=951; Reg(bar,"BackgroundColor3","Divider")
    end
    local wrap=Instance.new("Frame",panel); wrap.Size=UDim2.new(1,-40,0,34); wrap.Position=UDim2.new(0,20,0,104); wrap.BackgroundColor3=T.Item; wrap.BorderSizePixel=0; wrap.ZIndex=951; Stroke(wrap,1,"StrokeItem"); Reg(wrap,"BackgroundColor3","Item")
    local ki=Instance.new("TextBox",wrap); ki.Size=UDim2.new(1,-16,1,0); ki.Position=UDim2.new(0,8,0,0); ki.BackgroundTransparency=1; ki.TextColor3=T.Text; ki.Font=Enum.Font.Code; ki.TextSize=14; ki.PlaceholderText=L.enterKey; ki.PlaceholderColor3=T.TextDim; ki.Text=""; ki.ClearTextOnFocus=false; ki.ZIndex=952; ki.TextXAlignment=Enum.TextXAlignment.Left; Reg(ki,"TextColor3","Text")
    local cb=Instance.new("TextButton",panel); cb.Size=UDim2.new(1,-40,0,32); cb.Position=UDim2.new(0,20,0,148); cb.BackgroundColor3=T.Stroke; cb.BorderSizePixel=0; cb.Font=Enum.Font.GothamBold; cb.TextSize=13; cb.Text=L.access; cb.ZIndex=952; cb.TextColor3=Color3.fromRGB(255,255,255); Stroke(cb,1,"Stroke")
    cb.MouseEnter:Connect(function() TS:Create(cb,TweenInfo.new(0.1),{BackgroundTransparency=0.2}):Play() end)
    cb.MouseLeave:Connect(function() TS:Create(cb,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    local errl=Instance.new("TextLabel",panel); errl.Size=UDim2.new(1,-40,0,18); errl.Position=UDim2.new(0,20,0,184); errl.BackgroundTransparency=1; errl.Font=Enum.Font.Gotham; errl.TextSize=11; errl.TextColor3=Color3.fromRGB(220,60,60); errl.ZIndex=951; errl.Text=""; errl.TextXAlignment=Enum.TextXAlignment.Left
    local att=0; local maxA=5
    local function check()
        att=att+1
        if ValidKey(ki.Text) then
            if not existingKey then
                local newPermKey = GenPermKey()
                SavePermKey(newPermKey)
                permKeyLbl.Text=L.permKeyGen.." "..newPermKey
            end
            TS:Create(panel,TweenInfo.new(0.3),{BackgroundTransparency=1,Size=UDim2.new(0,340,0,0),Position=UDim2.new(0.5,-170,0.5,0)}):Play()
            TS:Create(ov,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
            task.wait(0.35); pcall(function() panel:Destroy() end); pcall(function() ov:Destroy() end)
            WLSave(LP.UserId); onSuccess()
        else
            task.spawn(function()
                local o=panel.Position
                for i=1,6 do panel.Position=o+UDim2.new(0,math.random(-8,8),0,math.random(-4,4)); task.wait(0.04) end
                panel.Position=o
            end)
            TS:Create(wrap,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,10,10)}):Play()
            task.wait(0.3); TS:Create(wrap,TweenInfo.new(0.2),{BackgroundColor3=T.Item}):Play()
            if att>=maxA then errl.Text=L.tooMany; cb.Active=false; ki.Editable=false; task.wait(2); pcall(function() GUI:Destroy() end)
            else errl.Text=L.invalidKey..(maxA-att).." left)"; ki.Text=""; task.wait(2); errl.Text="" end
        end
    end
    cb.MouseButton1Click:Connect(check)
    ki.FocusLost:Connect(function(e) if e then check() end end)
end

-- ============================================================
-- LOADING SEQUENCE
-- ============================================================
task.spawn(function()
    local msgs={"Initializing...","Bypassing...","Allocating...","Connecting...","Finalizing..."}
    local mi,prog=1,0
    while prog<100 do
        prog=math.min(prog+math.random(4,12),100)
        TS:Create(LoadBar,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(prog/100,0,1,0)}):Play()
        if math.random(2)==1 and mi<=#msgs then LoadText.Text=msgs[mi]; mi=mi+1 end
        task.wait(math.random(20,50)/100)
    end
    LoadText.Text="Checking..."; task.wait(0.7)
    TS:Create(LoadText,TweenInfo.new(0.4),{TextTransparency=1}):Play()
    TS:Create(LoadLogo,TweenInfo.new(0.4),{ImageTransparency=1}):Play()
    task.wait(0.5)

    local function FinishLoad()
        S.Unlocked=true
        local gl=Instance.new("TextLabel",GUI); gl.Size=UDim2.new(1,0,0,56); gl.Position=UDim2.new(0,0,0.5,-28); gl.BackgroundTransparency=1; gl.Font=Enum.Font.GothamBold; gl.TextSize=30; gl.TextTransparency=1; gl.ZIndex=960; gl.Text=L.welcome
        TS:Create(gl,TweenInfo.new(0.4),{TextTransparency=0}):Play()
        task.spawn(function() while gl and gl.Parent do gl.TextColor3=RBW() task.wait(0.02) end end)
        TS:Create(LoadScreen,TweenInfo.new(0.6),{BackgroundTransparency=1}):Play()
        task.wait(1.8); TS:Create(gl,TweenInfo.new(0.5),{TextTransparency=1}):Play()
        task.wait(0.5); pcall(function() gl:Destroy() end); pcall(function() LoadScreen:Destroy() end)
        Notify(L.uid..tostring(LP.UserId),4)
        task.wait(0.3); SwitchTab("VISUALS"); ApplyTheme(ThemeState.Current); _openMenu()
    end

    if WLCheck() then FinishLoad() else BuildKeyGUI(FinishLoad) end
end)

ApplyTheme(ThemeState.Current)
print("[KDLC v9.6] key: dobrograd | @"..LP.Name)