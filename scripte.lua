local P=game:GetService("Players");local RS=game:GetService("RunService");local UIS=game:GetService("UserInputService");local TS=game:GetService("TweenService");local HTTP=game:GetService("HttpService");local LP=P.LocalPlayer;local Cam=workspace.CurrentCamera
local S={Fly=false,FlySpd=50,WalkSpd=16,Jump=50,NoClip=false,XRay=false,Spec=false,SpecTgt=nil,Auth=false,Aimbot=false,AimFOV=100,AimSmooth=0.5,AimPart="Head",ESP=false,AutoClick=false,InfJump=false,WallBang=false}
local Conn={};local OrigTrans={};local ESPObj={};local FocusP=nil
local AUTH_FILE="AP_Key_"..LP.UserId..".txt"
local MASTER_KEY="iygyiegfiygeyfgyeyf7089"

local function GetKeyTimestamp(k)
    if not k then return nil end
    local ts=k:match("%-(%d+)$")
    if ts then return tonumber(ts)end
    return nil
end

local function IsKeyValid(k)
    if not k or k==""then return false end
    if k==MASTER_KEY then return true end
    if not k:match("^ADMIN%-.+%-%d+$")then return false end
    local ts=GetKeyTimestamp(k)
    if not ts then return false end
    local now=os.time()
    local age=now-ts
    if age>=86400 then return false end
    if age<0 then return false end
    return true
end

local function SaveKey(k)
    pcall(function()
        if writefile then writefile(AUTH_FILE,k)end
    end)
end

local function LoadKey()
    local k=nil
    pcall(function()
        if isfile and readfile and isfile(AUTH_FILE)then
            k=readfile(AUTH_FILE)
        end
    end)
    return k
end

local function DeleteKey()
    pcall(function()
        if delfile and isfile and isfile(AUTH_FILE)then delfile(AUTH_FILE)end
    end)
end

local function Tw(o,t,p)TS:Create(o,TweenInfo.new(t),p):Play()end
local function N(c,p,r)local i=Instance.new(c);for k,v in pairs(r or{})do i[k]=v end;i.Parent=p;return i end
local function Cr(p,r)return N("UICorner",p,{CornerRadius=UDim.new(0,r or 8)})end

local function CreateUI()
    if game:GetService("CoreGui"):FindFirstChild("AP")then game:GetService("CoreGui").AP:Destroy()end
    local G=N("ScreenGui",game:GetService("CoreGui"),{Name="AP",ResetOnSpawn=false})
    local LF=N("Frame",G,{Name="LF",Size=UDim2.new(0,320,0,200),Position=UDim2.new(0.5,-160,0.5,-100),BackgroundColor3=Color3.fromRGB(25,25,35)});Cr(LF,10);N("UIStroke",LF,{Color=Color3.fromRGB(100,100,255),Thickness=2})
    N("TextLabel",LF,{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,Text="ADMIN PANEL",TextColor3=Color3.fromRGB(255,255,255),TextSize=20,Font=Enum.Font.GothamBold})
    local KI=N("TextBox",LF,{Size=UDim2.new(0.9,0,0,35),Position=UDim2.new(0.05,0,0,50),BackgroundColor3=Color3.fromRGB(40,40,55),PlaceholderText="Enter key...",PlaceholderColor3=Color3.fromRGB(150,150,150),Text="",TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,ClearTextOnFocus=false});Cr(KI,6)
    local LB=N("TextButton",LF,{Size=UDim2.new(0.9,0,0,35),Position=UDim2.new(0.05,0,0,95),BackgroundColor3=Color3.fromRGB(80,80,200),Text="LOGIN",TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.GothamBold});Cr(LB,6)
    local GB=N("TextButton",LF,{Size=UDim2.new(0.9,0,0,35),Position=UDim2.new(0.05,0,0,140),BackgroundColor3=Color3.fromRGB(50,150,50),Text="GET KEY",TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.GothamBold});Cr(GB,6)
    local MF=N("Frame",G,{Name="MF",Size=UDim2.new(0,350,0,500),Position=UDim2.new(0,20,0.5,-250),BackgroundColor3=Color3.fromRGB(25,25,35),Visible=false});Cr(MF,12);N("UIStroke",MF,{Color=Color3.fromRGB(100,100,255),Thickness=2})
    local H=N("Frame",MF,{Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(35,35,50)});Cr(H,12);N("Frame",H,{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=Color3.fromRGB(35,35,50)})
    N("TextLabel",H,{Size=UDim2.new(0.5,0,0.5,0),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text="ADMIN PANEL",TextColor3=Color3.fromRGB(255,255,255),TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
    local TL=N("TextLabel",H,{Name="Timer",Size=UDim2.new(0.5,-50,0.5,0),Position=UDim2.new(0,10,0.5,0),BackgroundTransparency=1,Text="Key: --:--:--",TextColor3=Color3.fromRGB(0,255,136),TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
    local MinB=N("TextButton",H,{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0,10),BackgroundColor3=Color3.fromRGB(200,100,100),Text="-",TextColor3=Color3.fromRGB(255,255,255),TextSize=20,Font=Enum.Font.GothamBold});Cr(MinB,6)
    local C=N("ScrollingFrame",MF,{Size=UDim2.new(1,-20,1,-60),Position=UDim2.new(0,10,0,55),BackgroundTransparency=1,ScrollBarThickness=6,ScrollBarImageColor3=Color3.fromRGB(100,100,255),CanvasSize=UDim2.new(0,0,0,1400),AutomaticCanvasSize=Enum.AutomaticSize.Y});N("UIListLayout",C,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})
    local Mini=N("TextButton",G,{Name="Mini",Size=UDim2.new(0,50,0,50),Position=UDim2.new(0,20,0.5,-25),BackgroundColor3=Color3.fromRGB(80,80,200),Text="+",TextColor3=Color3.fromRGB(255,255,255),TextSize=24,Visible=false});Cr(Mini,10);N("UIStroke",Mini,{Color=Color3.fromRGB(100,100,255),Thickness=2})
    return{G=G,LF=LF,KI=KI,LB=LB,GB=GB,MF=MF,H=H,C=C,MinB=MinB,Mini=Mini,TL=TL}
end

local function Sec(p,t,o)local F=N("Frame",p,{Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(35,35,50),LayoutOrder=o});Cr(F);N("TextLabel",F,{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="  "..t,TextColor3=Color3.fromRGB(150,150,255),TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left});return F end

local function Tog(p,t,o,cb,def)local F=N("Frame",p,{Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(40,40,55),LayoutOrder=o});Cr(F);N("TextLabel",F,{Size=UDim2.new(0.7,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=t,TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left});local TB=N("TextButton",F,{Size=UDim2.new(0,50,0,25),Position=UDim2.new(1,-60,0.5,-12.5),BackgroundColor3=def and Color3.fromRGB(80,200,80)or Color3.fromRGB(60,60,80),Text=""});Cr(TB,12);local Ci=N("Frame",TB,{Size=UDim2.new(0,21,0,21),Position=def and UDim2.new(1,-23,0.5,-10.5)or UDim2.new(0,2,0.5,-10.5),BackgroundColor3=Color3.fromRGB(200,200,200)});Cr(Ci,10);local on=def or false;TB.MouseButton1Click:Connect(function()on=not on;Tw(Ci,0.2,{Position=on and UDim2.new(1,-23,0.5,-10.5)or UDim2.new(0,2,0.5,-10.5)});Tw(TB,0.2,{BackgroundColor3=on and Color3.fromRGB(80,200,80)or Color3.fromRGB(60,60,80)});if cb then cb(on)end end);return F end

local function Sld(p,t,mn,mx,df,o,cb)local F=N("Frame",p,{Size=UDim2.new(1,0,0,55),BackgroundColor3=Color3.fromRGB(40,40,55),LayoutOrder=o});Cr(F);N("TextLabel",F,{Size=UDim2.new(0.7,0,0,25),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text=t,TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left});local VL=N("TextLabel",F,{Size=UDim2.new(0.3,-10,0,25),Position=UDim2.new(0.7,0,0,5),BackgroundTransparency=1,Text=tostring(df),TextColor3=Color3.fromRGB(100,200,255),TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right});local BG=N("Frame",F,{Size=UDim2.new(1,-20,0,8),Position=UDim2.new(0,10,0,35),BackgroundColor3=Color3.fromRGB(60,60,80)});Cr(BG,4);local Fl=N("Frame",BG,{Size=UDim2.new((df-mn)/(mx-mn),0,1,0),BackgroundColor3=Color3.fromRGB(80,150,255)});Cr(Fl,4);local Kb=N("Frame",BG,{Size=UDim2.new(0,16,0,16),Position=UDim2.new((df-mn)/(mx-mn),-8,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255)});Cr(Kb,8);local dr=false;local function upd(i)local ps=math.clamp((i.Position.X-BG.AbsolutePosition.X)/BG.AbsoluteSize.X,0,1);local vl=math.floor(mn+(mx-mn)*ps);Fl.Size=UDim2.new(ps,0,1,0);Kb.Position=UDim2.new(ps,-8,0.5,-8);VL.Text=tostring(vl);if cb then cb(vl)end end;BG.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true;upd(i)end end);UIS.InputChanged:Connect(function(i)if dr and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then upd(i)end end);UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end);return F end

local function PBtn(p,t,o,cb)local B=N("TextButton",p,{Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(60,60,100),Text=t,TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,LayoutOrder=o});Cr(B,6);B.MouseEnter:Connect(function()Tw(B,0.2,{BackgroundColor3=Color3.fromRGB(80,80,140)})end);B.MouseLeave:Connect(function()Tw(B,0.2,{BackgroundColor3=Color3.fromRGB(60,60,100)})end);B.MouseButton1Click:Connect(function()if cb then cb()end end);return B end

local function DD(p,t,o)local F=N("Frame",p,{Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(40,40,55),LayoutOrder=o,ClipsDescendants=true});Cr(F);local HB=N("TextButton",F,{Size=UDim2.new(1,0,0,35),BackgroundTransparency=1,Text="  "..t.." >",TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left});local IC=N("Frame",F,{Name="I",Size=UDim2.new(1,-10,0,0),Position=UDim2.new(0,5,0,40),BackgroundTransparency=1});local IL=N("UIListLayout",IC,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)});local op=false;HB.MouseButton1Click:Connect(function()op=not op;HB.Text=op and("  "..t.." v")or("  "..t.." >");Tw(F,0.3,{Size=op and UDim2.new(1,0,0,35+IL.AbsoluteContentSize.Y+10)or UDim2.new(1,0,0,35)})end);return F,IC,function()if op then Tw(F,0.3,{Size=UDim2.new(1,0,0,35+IL.AbsoluteContentSize.Y+10)})end end end

local function EFly(on)S.Fly=on;local ch=LP.Character;if not ch then return end;local hum,rp=ch:FindFirstChildOfClass("Humanoid"),ch:FindFirstChild("HumanoidRootPart");if not hum or not rp then return end;if on then local bg=N("BodyGyro",rp,{Name="FG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=9e4,CFrame=rp.CFrame});local bv=N("BodyVelocity",rp,{Name="FV",MaxForce=Vector3.new(1e9,1e9,1e9),Velocity=Vector3.zero});hum.PlatformStand=true;Conn.Fly=RS.RenderStepped:Connect(function()if not S.Fly then return end;local d=Vector3.zero;if UIS:IsKeyDown(Enum.KeyCode.W)then d=d+Cam.CFrame.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.S)then d=d-Cam.CFrame.LookVector end;if UIS:IsKeyDown(Enum.KeyCode.A)then d=d-Cam.CFrame.RightVector end;if UIS:IsKeyDown(Enum.KeyCode.D)then d=d+Cam.CFrame.RightVector end;if UIS:IsKeyDown(Enum.KeyCode.Space)then d=d+Vector3.new(0,1,0)end;if UIS:IsKeyDown(Enum.KeyCode.LeftControl)or UIS:IsKeyDown(Enum.KeyCode.LeftShift)then d=d-Vector3.new(0,1,0)end;bv.Velocity=d.Magnitude>0 and d.Unit*S.FlySpd or Vector3.zero;bg.CFrame=Cam.CFrame end)else if Conn.Fly then Conn.Fly:Disconnect();Conn.Fly=nil end;local bg,bv=rp:FindFirstChild("FG"),rp:FindFirstChild("FV");if bg then bg:Destroy()end;if bv then bv:Destroy()end;hum.PlatformStand=false end end

local function ENoClip(on)S.NoClip=on;if on then Conn.NoClip=RS.Stepped:Connect(function()local ch=LP.Character;if ch then for _,p in pairs(ch:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end end)else if Conn.NoClip then Conn.NoClip:Disconnect();Conn.NoClip=nil end;local ch=LP.Character;if ch then for _,p in pairs(ch:GetDescendants())do if p:IsA("BasePart")and p.Name~="HumanoidRootPart"then p.CanCollide=true end end end end end

local function EInfJump(on)S.InfJump=on;if on then Conn.InfJump=UIS.JumpRequest:Connect(function()local ch=LP.Character;if ch then local h=ch:FindFirstChildOfClass("Humanoid");if h then h:ChangeState(Enum.HumanoidStateType.Jumping)end end end)else if Conn.InfJump then Conn.InfJump:Disconnect();Conn.InfJump=nil end end end

local function SetSpd(v)S.WalkSpd=v;local ch=LP.Character;if ch then local h=ch:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=v end end end
local function SetJmp(v)S.Jump=v;local ch=LP.Character;if ch then local h=ch:FindFirstChildOfClass("Humanoid");if h then h.UseJumpPower=true;h.JumpPower=v end end end

local function EXRay(on)S.XRay=on;if on then for _,o in pairs(workspace:GetDescendants())do if o:IsA("BasePart")and not o:IsDescendantOf(LP.Character or{})then if not P:GetPlayerFromCharacter(o.Parent)and not P:GetPlayerFromCharacter(o.Parent and o.Parent.Parent)then if not OrigTrans[o]then OrigTrans[o]=o.Transparency end;o.Transparency=0.7 end end end else for o,t in pairs(OrigTrans)do if o and o.Parent then o.Transparency=t end end;OrigTrans={}end end

local function CESP(pl)if pl==LP then return end;local function Add()if not pl.Character then return end;local hrp=pl.Character:FindFirstChild("HumanoidRootPart");if not hrp then return end;if ESPObj[pl]then for _,v in pairs(ESPObj[pl])do if v then pcall(function()v:Destroy()end)end end;ESPObj[pl]=nil end;local e={};local bx=Instance.new("BoxHandleAdornment");bx.Adornee=hrp;bx.AlwaysOnTop=true;bx.ZIndex=10;bx.Size=Vector3.new(4,6,4);bx.Transparency=0.3;bx.Color3=Color3.fromRGB(255,255,255);bx.Parent=game:GetService("CoreGui");e.bx=bx;local nt=Instance.new("BillboardGui");nt.Adornee=hrp;nt.Size=UDim2.new(0,100,0,40);nt.StudsOffset=Vector3.new(0,4,0);nt.AlwaysOnTop=true;nt.Parent=game:GetService("CoreGui");local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,0,0.6,0);nl.BackgroundTransparency=1;nl.Text=pl.Name;nl.TextColor3=Color3.fromRGB(255,255,255);nl.TextStrokeTransparency=0;nl.Font=Enum.Font.GothamBold;nl.TextSize=14;nl.Parent=nt;e.nt=nt;local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,0,0.4,0);dl.Position=UDim2.new(0,0,0.6,0);dl.BackgroundTransparency=1;dl.Text="0m";dl.TextColor3=Color3.fromRGB(200,200,200);dl.TextStrokeTransparency=0;dl.Font=Enum.Font.Gotham;dl.TextSize=12;dl.Parent=nt;e.cn=RS.RenderStepped:Connect(function()if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")and hrp then dl.Text="["..math.floor((LP.Character.HumanoidRootPart.Position-hrp.Position).Magnitude).."m]"end end);ESPObj[pl]=e end;Add();pl.CharacterAdded:Connect(function()task.wait(0.5);if S.ESP then Add()end end)end

local function RESP(pl)if ESPObj[pl]then for _,v in pairs(ESPObj[pl])do if typeof(v)=="RBXScriptConnection"then v:Disconnect()elseif v then pcall(function()v:Destroy()end)end end;ESPObj[pl]=nil end end

local function EESP(on)S.ESP=on;if on then for _,pl in pairs(P:GetPlayers())do CESP(pl)end;Conn.EA=P.PlayerAdded:Connect(function(pl)task.wait(1);if S.ESP then CESP(pl)end end);Conn.ER=P.PlayerRemoving:Connect(function(pl)RESP(pl)end)else if Conn.EA then Conn.EA:Disconnect();Conn.EA=nil end;if Conn.ER then Conn.ER:Disconnect();Conn.ER=nil end;for pl,_ in pairs(ESPObj)do RESP(pl)end;ESPObj={}end end

local function Fling(tgt)if not tgt or tgt==LP then return end;local ch,tc=LP.Character,tgt.Character;if not ch or not tc then return end;local rp,tr=ch:FindFirstChild("HumanoidRootPart"),tc:FindFirstChild("HumanoidRootPart");if not rp or not tr then return end;local op=rp.CFrame;local bav=N("BodyAngularVelocity",rp,{Name="FA",MaxTorque=Vector3.new(1e9,1e9,1e9),AngularVelocity=Vector3.new(0,9999,0)});for _,p in pairs(ch:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end;local st=tick();local fc;fc=RS.Heartbeat:Connect(function()if tick()-st>1.5 then fc:Disconnect();if bav then bav:Destroy()end;if rp then rp.CFrame=op end;for _,p in pairs(ch:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=true end end;return end;if tr and rp then rp.CFrame=tr.CFrame end end)end

local function Spec(tgt)if S.Spec and S.SpecTgt==tgt then S.Spec=false;S.SpecTgt=nil;Cam.CameraSubject=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid");return end;if not tgt or tgt==LP then return end;local tc=tgt.Character;if not tc then return end;local th=tc:FindFirstChildOfClass("Humanoid");if not th then return end;S.Spec=true;S.SpecTgt=tgt;Cam.CameraSubject=th end

local function TpTo(tgt)if not tgt or tgt==LP then return end;local ch,tc=LP.Character,tgt.Character;if not ch or not tc then return end;local rp,tr=ch:FindFirstChild("HumanoidRootPart"),tc:FindFirstChild("HumanoidRootPart");if not rp or not tr then return end;rp.CFrame=tr.CFrame*CFrame.new(3,0,0)end

local function LoS(tgt)local ch=LP.Character;if not ch then return false end;local hd=ch:FindFirstChild("Head");if not hd or not tgt then return false end;local pm=RaycastParams.new();pm.FilterType=Enum.RaycastFilterType.Exclude;pm.FilterDescendantsInstances={ch};local r=workspace:Raycast(hd.Position,(tgt.Position-hd.Position).Unit*500,pm);if r and r.Instance:IsDescendantOf(tgt.Parent)then return true end;return not r end

local function GetCP()local cl,ds=nil,math.huge;local mc=LP.Character;if not mc or not mc:FindFirstChild("HumanoidRootPart")then return nil end;local myPos=mc.HumanoidRootPart.Position;for _,pl in pairs(P:GetPlayers())do if pl~=LP and pl.Character then local tg=pl.Character:FindFirstChild(S.AimPart)or pl.Character:FindFirstChild("Head");local hm=pl.Character:FindFirstChildOfClass("Humanoid");if tg and hm and hm.Health>0 then local dist=(tg.Position-myPos).Magnitude;local sp,os=Cam:WorldToScreenPoint(tg.Position);local inFOV=S.AimFOV==0;if os and S.AimFOV>0 then local mg=(Vector2.new(sp.X,sp.Y)-Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)).Magnitude;inFOV=mg<=S.AimFOV end;if(inFOV or S.AimFOV==0)and dist<ds then cl=tg;ds=dist end end end end;FocusP=cl and P:GetPlayerFromCharacter(cl.Parent);return cl end

local function EAim(on)S.Aimbot=on;if on then Conn.Aim=RS.RenderStepped:Connect(function()if not S.Aimbot then return end;if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)then local tg=GetCP();if tg then local sp,os=Cam:WorldToViewportPoint(tg.Position);if os then local mp=UIS:GetMouseLocation();local tp=Vector2.new(sp.X,sp.Y);local dt=(tp-mp)*S.AimSmooth;if mousemoverel then mousemoverel(dt.X,dt.Y)end;if S.AutoClick and(S.WallBang or LoS(tg))then if mouse1click then mouse1click()end end else Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,tg.Position),S.AimSmooth)end end end end)else if Conn.Aim then Conn.Aim:Disconnect();Conn.Aim=nil end end end

local function DFOV()local fc=Drawing and Drawing.new("Circle");if fc then fc.Visible=false;fc.Radius=S.AimFOV;fc.Color=Color3.fromRGB(255,0,0);fc.Thickness=2;fc.Transparency=1;fc.Filled=false;Conn.FOV=RS.RenderStepped:Connect(function()fc.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2);fc.Radius=S.AimFOV;fc.Visible=S.Aimbot and S.AimFOV>0;fc.Color=FocusP and Color3.fromRGB(255,0,255)or Color3.fromRGB(255,0,0)end)end end

local function Init()
    local UI=CreateUI()
    local TimerConn=nil
    local CurrentKey=nil
    
    local function StartKeyTimer()
        if TimerConn then TimerConn:Disconnect() end
        if not CurrentKey or CurrentKey==MASTER_KEY then
            UI.TL.Text="Key: UNLIMITED"
            UI.TL.TextColor3=Color3.fromRGB(0,255,136)
            return
        end
        local ts=GetKeyTimestamp(CurrentKey)
        if not ts then return end
        TimerConn=RS.Heartbeat:Connect(function()
            local now=os.time()
            local left=86400-(now-ts)
            if left<=0 then
                UI.TL.Text="KEY EXPIRED!"
                UI.TL.TextColor3=Color3.fromRGB(255,80,80)
                TimerConn:Disconnect()
                DeleteKey()
                wait(2)
                UI.MF.Visible=false
                UI.LF.Visible=true
                return
            end
            local h=math.floor(left/3600)
            local m=math.floor((left%3600)/60)
            local s=left%60
            UI.TL.Text=string.format("Key: %02d:%02d:%02d",h,m,s)
            if left<300 then
                UI.TL.TextColor3=Color3.fromRGB(255,80,80)
            elseif left<3600 then
                UI.TL.TextColor3=Color3.fromRGB(255,200,0)
            else
                UI.TL.TextColor3=Color3.fromRGB(0,255,136)
            end
        end)
    end
    
    local function Show(key)
        S.Auth=true
        CurrentKey=key
        UI.LF.Visible=false
        UI.MF.Visible=true
        UI.MF.Position=UDim2.new(0,-400,0.5,-250)
        Tw(UI.MF,0.5,{Position=UDim2.new(0,20,0.5,-250)})
        StartKeyTimer()
    end
    
    local savedKey=LoadKey()
    if savedKey and IsKeyValid(savedKey)then
        Show(savedKey)
    else
        if savedKey then DeleteKey()end
        
        local function Chk()
            local k=UI.KI.Text
            if IsKeyValid(k)then
                SaveKey(k)
                Show(k)
            else
                UI.KI.BackgroundColor3=Color3.fromRGB(200,50,50)
                if k==""then
                    UI.KI.Text="ENTER A KEY"
                elseif not k:match("^ADMIN%-")and k~=MASTER_KEY then
                    UI.KI.Text="INVALID FORMAT"
                else
                    UI.KI.Text="KEY EXPIRED"
                end
                wait(1.5)
                UI.KI.BackgroundColor3=Color3.fromRGB(40,40,55)
                UI.KI.Text=""
            end
        end
        
        UI.LB.MouseButton1Click:Connect(Chk)
        UI.KI.FocusLost:Connect(function(e)if e then Chk()end end)
        UI.GB.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard("https://votre-site.com/page1.html")end
            UI.GB.Text="Link copied!"
            wait(2)
            UI.GB.Text="GET KEY"
        end)
    end
    
    UI.MinB.MouseButton1Click:Connect(function()UI.MF.Visible=false;UI.Mini.Visible=true end)
    UI.Mini.MouseButton1Click:Connect(function()UI.Mini.Visible=false;UI.MF.Visible=true end)
    
    local dr,dS,sP
    UI.H.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=true;dS=i.Position;sP=UI.MF.Position end end)
    UI.H.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UIS.InputChanged:Connect(function(i)if dr and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dS;UI.MF.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)end end)
    
    local o=0
    Sec(UI.C,"MOVEMENT",o);o=o+1
    Tog(UI.C,"Fly",o,EFly);o=o+1
    Sld(UI.C,"Fly Speed",10,500,50,o,function(v)S.FlySpd=v end);o=o+1
    Sld(UI.C,"Walk Speed",16,500,16,o,SetSpd);o=o+1
    Sld(UI.C,"Jump Power",50,500,50,o,SetJmp);o=o+1
    Tog(UI.C,"Infinite Jump",o,EInfJump);o=o+1
    Tog(UI.C,"NoClip",o,ENoClip);o=o+1
    
    Sec(UI.C,"VISION",o);o=o+1
    Tog(UI.C,"X-Ray",o,EXRay);o=o+1
    Tog(UI.C,"ESP",o,EESP);o=o+1
    
    Sec(UI.C,"AIMBOT",o);o=o+1
    Tog(UI.C,"Aimbot",o,EAim);o=o+1
    Tog(UI.C,"Auto-Click",o,function(on)S.AutoClick=on end);o=o+1
    Tog(UI.C,"WallBang",o,function(on)S.WallBang=on end);o=o+1
    Sld(UI.C,"FOV (0=Inf)",0,500,100,o,function(v)S.AimFOV=v end);o=o+1
    Sld(UI.C,"Smooth",1,100,50,o,function(v)S.AimSmooth=v/100 end);o=o+1
    
    local aD,aI,aU=DD(UI.C,"Aim Part",o);o=o+1
    for _,pt in pairs({"Head","HumanoidRootPart","UpperTorso","LowerTorso"})do PBtn(aI,pt,0,function()S.AimPart=pt end)end
    task.wait(0.1);aU()
    
    Sec(UI.C,"PLAYERS",o);o=o+1
    local sB=N("TextBox",UI.C,{Size=UDim2.new(1,0,0,35),BackgroundColor3=Color3.fromRGB(50,50,70),PlaceholderText="Search...",PlaceholderColor3=Color3.fromRGB(150,150,150),Text="",TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,LayoutOrder=o});Cr(sB,6);o=o+1
    local sR=N("Frame",UI.C,{Size=UDim2.new(1,0,0,0),BackgroundColor3=Color3.fromRGB(40,40,55),LayoutOrder=o,ClipsDescendants=true});Cr(sR,6);o=o+1
    N("UIListLayout",sR,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)})
    
    local function UpS(q)
        for _,c in pairs(sR:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
        if q==""then sR.Size=UDim2.new(1,0,0,0);return end
        local rs={}
        for _,pl in pairs(P:GetPlayers())do if pl~=LP and string.lower(pl.Name):sub(1,#q)==string.lower(q)then table.insert(rs,pl)end end
        if #rs==0 then for _,pl in pairs(P:GetPlayers())do if pl~=LP and string.find(string.lower(pl.Name),string.lower(q))then table.insert(rs,pl)end end end
        local ct=0
        for _,pl in pairs(rs)do
            local bt=N("TextButton",sR,{Size=UDim2.new(1,-10,0,30),Position=UDim2.new(0,5,0,0),BackgroundColor3=Color3.fromRGB(60,60,100),Text=pl.Name,TextColor3=Color3.fromRGB(255,255,255),TextSize=14,Font=Enum.Font.Gotham,LayoutOrder=ct});Cr(bt,4)
            bt.MouseButton1Click:Connect(function()TpTo(pl);sB.Text="";sR.Size=UDim2.new(1,0,0,0)end)
            ct=ct+1
            if ct>=5 then break end
        end
        sR.Size=UDim2.new(1,0,0,math.min(ct,5)*33+5)
    end
    sB:GetPropertyChangedSignal("Text"):Connect(function()UpS(sB.Text)end)
    
    local tD,tI,tU=DD(UI.C,"Teleport",o);o=o+1
    local sD,sI,sU=DD(UI.C,"Spectate",o);o=o+1
    local fD,fI,fU=DD(UI.C,"Fling",o);o=o+1
    PBtn(UI.C,"Stop Spectate",o,function()S.Spec=false;S.SpecTgt=nil;Cam.CameraSubject=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")end);o=o+1
    
    local function UpP()
        for _,c in pairs(tI:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
        for _,c in pairs(sI:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
        for _,c in pairs(fI:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
        local po=0
        for _,pl in pairs(P:GetPlayers())do
            if pl~=LP then
                PBtn(tI,pl.Name,po,function()TpTo(pl)end)
                PBtn(sI,pl.Name,po,function()Spec(pl)end)
                PBtn(fI,pl.Name,po,function()Fling(pl)end)
                po=po+1
            end
        end
        task.wait(0.1);tU();sU();fU()
    end
    UpP()
    P.PlayerAdded:Connect(UpP)
    P.PlayerRemoving:Connect(UpP)
    
    Sec(UI.C,"INFO",o);o=o+1
    N("TextLabel",UI.C,{Size=UDim2.new(1,0,0,60),BackgroundColor3=Color3.fromRGB(40,40,55),Text="Fly: WASD+Space/Ctrl\nAimbot: Hold Right Click\nKey expires after 24h",TextColor3=Color3.fromRGB(180,180,180),TextSize=10,Font=Enum.Font.Gotham,TextWrapped=true,LayoutOrder=o})
    
    DFOV()
    
    LP.CharacterAdded:Connect(function(ch)
        local h=ch:WaitForChild("Humanoid",10)
        if not h then return end
        wait(0.5)
        if S.WalkSpd~=16 then SetSpd(S.WalkSpd)end
        if S.Jump~=50 then SetJmp(S.Jump)end
        if S.Fly then EFly(true)end
        if S.NoClip then ENoClip(true)end
    end)
end

Init()
