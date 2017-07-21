if myHero.charName ~= "Lissandra" then return end
require "2DGeometry"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

class "Lissandra"
local Scriptname,Version,Author,LVersion = "TRUSt in my Lissandra","v1.0","TRUS","7.14"
local passive = true
local lastbuff = 0
function Lissandra:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end

--[[Spells]]
function Lissandra:LoadSpells()
	Q = {Range = 700, width = 75, Delay = 0.25, Speed = 2250}
	W = {Range = 440, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
	E = {Range = 1050, width = 110, Delay = 0.25, Speed = 850}
	R = {Range = 550, width = 690, Delay = 0.25, Speed = 800}
end



function Lissandra:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyLissandra", name = Scriptname})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "UseW", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "UseE", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "UseR on enemy", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseRSelf", name = "Use self ult", value = true})
	self.Menu.ComboMode:MenuElement({id = "UltCount", name = "Min enemys for SelfR", value = 2, min = 0, max = 5, step = 1, identifier = ""})
	
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseQCreeps", name = "Use Q through creeps", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "UseW", value = true})

	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end



function Lissandra:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end

	
end

function EnableMovement()
	--unblock movement
	SetMovement(true)
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

function Lissandra:CastSpell(spell,pos)
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
				SetMovement(false)
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
function Lissandra:CastQ(target)
	if target and self:CanCast(_Q) then
		self:CastSpell(HK_Q, target.pos)
	end
end

--[[CastQ]]
function Lissandra:CastW(target)
	if target and self:CanCast(_W) then
		self:CastSpell(HK_W, target.pos)
	end
end


function Lissandra:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Lissandra:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Lissandra:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end



function Lissandra:Harass()
	local temptarget = self:FarQTarget()
	if temptarget then
		self:CastSpell(HK_Q,temptarget.pos)
	end
end




function Lissandra:FarQTarget()
	local qtarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(900,"AD"))
	if qtarget then
		
		if myHero.pos:DistanceTo(qtarget.pos)<500 then
			return qtarget
		end
		
		
		local qdelay = 0.4 - myHero.levelData.lvl*0.01
		local pos = qtarget:GetPrediction(math.huge,qdelay)
		if not pos then return false end 
		local minionlist = {}
		if _G.SDK then
			minionlist = _G.SDK.ObjectManager:GetEnemyMinions(500)
		elseif _G.GOS then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 500 then
					table.insert(minionlist, minion)
				end
			end
		end
		V = Vector(pos) - Vector(myHero.pos)
		
		Vn = V:Normalized()
		Distance = myHero.pos:DistanceTo(pos)
		tx, ty, tz = Vn:Unpack()
		TopX = pos.x - (tx * Distance)
		TopY = pos.y - (ty * Distance)
		TopZ = pos.z - (tz * Distance)
		
		Vr = V:Perpendicular():Normalized()
		Radius = qtarget.boundingRadius or 65
		tx, ty, tz = Vr:Unpack()
		
		LeftX = pos.x + (tx * Radius)
		LeftY = pos.y + (ty * Radius)
		LeftZ = pos.z + (tz * Radius)
		RightX = pos.x - (tx * Radius)
		RightY = pos.y - (ty * Radius)
		RightZ = pos.z - (tz * Radius)
		
		Left = Point(LeftX, LeftY, LeftZ)
		Right = Point(RightX, RightY, RightZ)
		Top = Point(TopX, TopY, TopZ)
		Poly = Polygon(Left, Right, Top)
		
		for i, minion in pairs(minionlist) do
			toPoint = Point(minion.pos.x, minion.pos.y,minion.pos.z)
			if Poly:__contains(toPoint) then
				return minion
			end
		end
	end
	return false 
end


function OnLoad()
	Lissandra()
end