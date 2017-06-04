if myHero.charName ~= "Lucian" then return end
require "2DGeometry"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}

function CurrentModes()
	local combomodeactive, harassactive, canmove, canattack, currenttarget
	if _G.SDK then -- ic orbwalker
		combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
		currenttarget = _G.SDK.Orbwalker:GetTarget()
	elseif _G.EOW then -- eternal orbwalker
		combomodeactive = _G.EOW:Mode() == 1
		harassactive = _G.EOW:Mode() == 2
		canmove = _G.EOW:CanMove() 
		canattack = _G.EOW:CanAttack()
		currenttarget = _G.EOW:GetTarget()
	else -- default orbwalker
		combomodeactive = _G.GOS:GetMode() == "Combo"
		harassactive = _G.GOS:GetMode() == "Harass"
		canmove = _G.GOS:CanMove()
		canattack = _G.GOS:CanAttack()
		currenttarget = _G.GOS:GetTarget()
	end
	return combomodeactive, harassactive, canmove, canattack, currenttarget
end

function GetInventorySlotItem(itemID)
	assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
		if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
	end
	return nil
end

function UseBotrk()
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
	if target then 
		local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
		if botrkitem then
			Control.CastSpell(keybindings[botrkitem],target.pos)
		end
	end
end
class "Lucian"
local Scriptname,Version,Author,LVersion = "TRUSt in my Lucian","v1.4","TRUS","7.11"
local passive = true
local lastbuff = 0
function Lucian:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
		_G.SDK.Orbwalker:OnPostAttack(function() 
			passive = false 
			--PrintChat("passive removed")
			local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
			if combomodeactive and _G.SDK.Orbwalker:CanMove() and Game.Timer() > lastbuff - 3.5 then 
				if self:CanCast(_E) and self.Menu.UseE:Value() and _G.SDK.Orbwalker:GetTarget() then
					self:CastSpell(HK_E,mousePos)
					return
				end
			end
		end)
	elseif _G.EOW then
		orbwalkername = "EOW"	
		_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
			passive = false 
			local combomodeactive = _G.EOW:Mode() == 1
			local canmove = _G.EOW:CanMove()
			if combomodeactive and canmove and Game.Timer() > lastbuff - 3.5 then 
				if self:CanCast(_E) and self.Menu.UseE:Value() and _G.EOW:GetTarget() then
					self:CastSpell(HK_E,mousePos)
					return
				end
			end
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		_G.GOS:OnAttackComplete(function() 
			passive = false 
			local combomodeactive = _G.GOS:GetMode() == "Combo"
			local canmove = _G.GOS:CanMove()
			if combomodeactive and canmove and Game.Timer() > lastbuff - 3.5 then 
				if self:CanCast(_E) and self.Menu.UseE:Value() and _G.GOS:GetTarget() then
					self:CastSpell(HK_E,mousePos)
					return
				end
			end
		end)
		
		
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end
onetimereset = true
blockattack = false
blockmovement = false

local lastpick = 0

--[[Spells]]
function Lucian:LoadSpells()
	Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
end



function Lucian:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyLucian", name = Scriptname})
	self.Menu:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu:MenuElement({id = "UseW", name = "UseW", value = true})
	self.Menu:MenuElement({id = "UseE", name = "UseE", value = true})
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "UseQHarass", name = "Harass with Q", value = true})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Lucian:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Lucian:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return Buff.expireTime
		end
	end
	return false
end

function Lucian:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local buffcheck = self:HasBuff(myHero,"lucianpassivebuff")
	if buffcheck and buffcheck ~= lastbuff then
		lastbuff = buffcheck
		--PrintChat("Passive added : "..Game.Timer().." : "..lastbuff)
		passive = true
	end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	if harassactive and self.Menu.UseQHarass:Value() and self:CanCast(_Q) then self:Harass() end 
	if combomodeactive and canmove and not canattack and Game.Timer() > lastbuff - 3 then 
		if self:CanCast(_E) and self.Menu.UseE:Value() and currenttarget then
			self:CastSpell(HK_E,mousePos)
			return
		end
		if self:CanCast(_Q) and self.Menu.UseQ:Value() and currenttarget then
			self:CastQ(currenttarget)
			return
		end
		if self:CanCast(_W) and self.Menu.UseW:Value() and currenttarget then
			self:CastW(currenttarget)
			return
		end
		
		
	end
	
	if myHero.activeSpell and myHero.activeSpell.valid and 
	(myHero.activeSpell.name == "LucianQ" or myHero.activeSpell.name == "LucianW") then
		passive = true
		--PrintChat("found passive1")
	end
	
	
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}



function EnableMovement()
	--unblock movement
	if _G.SDK then 
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	elseif _G.EOW then 
		EOW:SetMovements(true)
		EOW:SetAttacks(true)
	else
		_G.GOS.BlockAttack = false
		_G.GOS.BlockMovement = false
	end
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

function Lucian:CastSpell(spell,pos)
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
				if _G.SDK then 
					_G.SDK.Orbwalker:SetMovement(false)
					_G.SDK.Orbwalker:SetAttack(false)
				elseif _G.EOW then 
					EOW:SetMovements(false)
					EOW:SetAttacks(false)	
				else
					_G.GOS.BlockAttack = true
					_G.GOS.BlockMovement = true
				end
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
function Lucian:CastQ(target)
	if target and self:CanCast(_Q) and passive == false then
		self:CastSpell(HK_Q, target.pos)
	end
end

--[[CastQ]]
function Lucian:CastW(target)
	if target and self:CanCast(_W) and passive == false then
		self:CastSpell(HK_W, target.pos)
	end
end


function Lucian:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Lucian:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Lucian:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end



function Lucian:Harass()
	local temptarget = self:FarQTarget()
	if temptarget then
		self:CastSpell(HK_Q,temptarget.pos)
	end
end




function Lucian:FarQTarget()
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
	Lucian()
end