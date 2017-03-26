--[v1.0]]
local Scriptname,Version,Author,LVersion = "TRUSt in my Ezreal","v1.0","TRUS","7.6"

class "Ezreal"



function Ezreal:__init()
	if myHero.charName ~= "Ezreal" then return end
	PrintChat("TRUSt in my Ezreal "..Version.." - Loaded....")
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	
	
	
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreMovement(function(arg) 
			if blockmovement then
				arg.Process = false
			end
		end)
		
		_G.SDK.Orbwalker:OnPostAttack(function() 
				self:CastQ(_G.SDK.Orbwalker:GetTarget())
		end)
		
		_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
			if blockattack then
				arg.Process = false
			end
		end)
	else
		PrintChat("This script support IC Orbwalker only")
		
	end
end
onetimereset = true
blockattack = false
blockmovement = false

local lastpick = 0
--[[Spells]]
function Ezreal:LoadSpells()
	Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
end

function Ezreal:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyEzreal", name = Scriptname})
	self.Menu:MenuElement({id = "UseQ", name = "UseQ", key = string.byte("V")})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Ezreal:Tick()
	if myHero.dead or not _G.SDK then return end
	
	if self:CanCast(_Q) and self.Menu.UseQ:Value() and (_G.SDK.Orbwalker:CanMove() or not _G.SDK.Orbwalker:GetTarget()) then
		self:CastQ()
	end
	
	
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}



function EnableMovement()
	--unblock movement
	blockattack = false
	blockmovement = false
	onetimereset = true
	castSpell.state = 0
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Ezreal:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				--block movement
				blockattack = true
				blockmovement = true
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end


--[[CastQ]]
function Ezreal:CastQ(target)
if not _G.SDK then return end
	local target = target or _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	if target and self:CanCast(_Q) and self.Menu.UseQ:Value() and target:GetCollision(Q.Radius,Q.Speed,Q.Delay) == 0 then
		local castPos = target:GetPrediction(Q.Delay)
		local newpos = myHero.pos:Extended(castPos,math.random(0,Q.Range))
		self:CastSpell(HK_Q, castPos)
	end
end


function Ezreal:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Ezreal:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Ezreal:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


function OnLoad()
	Ezreal()
end