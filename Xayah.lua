if myHero.charName ~= "Xayah" then return end
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

local Scriptname,Version,Author,LVersion = "TRUSt in my Xayah","v1.1","TRUS","7.24b"
class "Xayah"
require "DamageLib"
if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
end
XayahPassiveTable = {}

function Xayah:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"	
		_G.SDK.Orbwalker:OnPostAttack(function() 
		end)
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end


function Xayah:LoadSpells()
	Q = {Range = 1100, Width = 50, Delay = 0.5, Speed = 1200}
	E = {Range = 1000}
	R = {Delay = 1, Range = 1100}
	
end

function Xayah:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyXayah", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboEFeathers", name = "Minimal feather for E:", value = 4, min = 1, max = 8})
	self.Menu.Combo:MenuElement({id = "savemana", name = "Save mana for E:", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "EUsage", name = "EUsage"})
	self.Menu.EUsage:MenuElement({id = "autoroot", name = "Auto Root", value = true})
	self.Menu.EUsage:MenuElement({id = "rootedamount", name = "Minimal enemys for autoroot:", value = 2, min = 1, max = 5})
	self.Menu.EUsage:MenuElement({id = "autoks", name = "Autokill with E", value = true})
	
	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw Featherhit amounts", value = true})
	self.Menu.Draw:MenuElement({id = "DrawOnGround", name = "Draw Feathers on ground", value = true})
	self.Menu.Draw:MenuElement({id = "DrawFLines", name = "Draw Feathers lines", value = true})
	
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "minEFeathers", name = "Minimal feather for E:", value = 2, min = 1, max = 8})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	
	
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function alreadycontains(element)
	for _, value in pairs(XayahPassiveTable) do
		if value.ID == element.networkID then
			return true
		end
	end
	return false
end

function Xayah:GetFeatherHits(target)
	local HitCount = 0
	if target then	
		for i, object in ipairs(XayahPassiveTable) do
			local collidingLine = LineSegment(myHero.pos, object.Position)
			if Point(target):__distance(collidingLine) < 80 + target.boundingRadius then
				HitCount = HitCount + 1
				object.hit = true
			end
		end
	end
	return HitCount
end

function Xayah:UpdateFeathers()
	for i = 1, Game.MissileCount() do
		local missile = Game.Missile(i)
		if missile.missileData and missile.missileData.owner == myHero.handle and not alreadycontains(missile) then
			if missile.missileData.name == "XayahQMissile1" or missile.missileData.name == "XayahQMissile2" or missile.missileData.name == "XayahRMissile" then
				table.insert(XayahPassiveTable, {placetime = Game.Timer() + 6, ID = missile.networkID, Position = Vector(missile.missileData.endPos), hit = false})
			elseif missile.missileData.name == "XayahPassiveAttack" then
				local newpos = myHero.pos:Extended(missile.missileData.endPos,1000)
				table.insert(XayahPassiveTable, {placetime = Game.Timer() + 6, ID = missile.networkID, Position = Vector(newpos), hit = false})
			elseif missile.missileData.name == "XayahEMissile" then
				XayahPassiveTable = {}
			end
		end
	end
end

function Xayah:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	local savemana = self.Menu.Combo.savemana:Value()
	local Eautoroot = self.Menu.EUsage.autoroot:Value()
	local eKS = self.Menu.EUsage.autoks:Value()
	self:UpdateFeathers()
	
	
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	if self:CanCast(_Q) and ((combomodeactive and self.Menu.Combo.comboUseQ:Value() and (not savemana or myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_E).mana)) or (harassactive and self.Menu.Harass.harassUseQ:Value() and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) then
		if canmove and (not canattack or not currenttarget) then
			self:CastQ(currenttarget,combomodeactive or false)
		end
	end
	if self:CanCast(_E) then 
		if (Eautoroot or eKS) then
			self:EUsage()
		end
		if (harassactive and self.Menu.Harass.harassUseE:Value()) then
			if canmove and (not canattack or not currenttarget) then
				local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
				for i, target in ipairs(heroeslist) do
					if self:IsValidTarget(target) then
						local hits = self:GetFeatherHits(target)
						if hits >= self.Menu.Harass.minEFeathers:Value() then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
		if (combomodeactive and self.Menu.Combo.comboUseE:Value()) then
			if canmove and (not canattack or not currenttarget) then
				local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
				for i, target in ipairs(heroeslist) do
					if self:IsValidTarget(target) then
						local hits = self:GetFeatherHits(target)
						if hits >= self.Menu.Combo.comboEFeathers:Value() then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
	end
	if self:CanCast(_W) and self.Menu.Combo.comboUseW:Value() and combomodeactive then
		Control.CastSpell(HK_W)
	end	
	
end

function EnableMovement()
	--unblock movement
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
	Control.mouse_event(MOUSEEVENTF_RIGHTUP)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Xayah:CastSpell(spell,pos)
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



function Xayah:CastQ(target, combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
	if target and target.type == "AIHeroClient" then
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay, Q.Width, Q.Range,Q.Speed,myHero.pos,false)
			if (HitChance >= 1) then
				local newpos = myHero.pos:Extended(castpos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
		elseif (target:GetCollision(Q.Width,Q.Speed,Q.Delay) == 0) then
			local castPos = target:GetPrediction(Q.Speed,Q.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, newpos)
		end
	end
end
function Xayah:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	if myHero.pos:DistanceTo(unit.pos)>range then return false end 
	return true 
end

function Xayah:EUsage()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
	local rootedenemy = 0
	for i, target in ipairs(heroeslist) do
		if self:IsValidTarget(target) then
			local hits = self:GetFeatherHits(target)
			if hits == 0 then return end 
			if hits >= 3 then
				rootedenemy = rootedenemy +1
			end
			local edamage = (45 + myHero:GetSpellData(_E).level*10 + 0.6*myHero.bonusDamage)*hits*(1+myHero.critChance/2)
			local tempdmg = CalcPhysicalDamage(myHero,target,edamage)
			if tempdmg > target.health then
				Control.CastSpell(HK_E)
			end
			if rootedenemy >= self.Menu.EUsage.rootedamount:Value() then 
				Control.CastSpell(HK_E)
			end
			
		end
	end
end

function Xayah:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Xayah:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Xayah:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Xayah:Draw()
	if self.Menu.Draw.DrawE:Value() then
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
		for i, target in ipairs(heroeslist) do
			local hits = self:GetFeatherHits(target)
			Draw.Text(tostring(hits), 25, target.pos:To2D().x, target.pos:To2D().y, Draw.Color(255, 255, 255, 0))
		end
	end
	if self.Menu.Draw.DrawOnGround:Value() or self.Menu.Draw.DrawFLines:Value() then
		for i, object in ipairs(XayahPassiveTable) do
			if object.placetime > Game.Timer() then
				if self.Menu.Draw.DrawOnGround:Value() then
					Draw.Circle(object.Position, 90, 3, Draw.Color(255, 255, 255, 0))
				end
				if self.Menu.Draw.DrawFLines:Value() then
					Draw.Line(myHero.pos:To2D().x, myHero.pos:To2D().y, object.Position:To2D().x, object.Position:To2D().y, 4, object.hit and Draw.Color(255, 255, 0, 0) or Draw.Color(255, 255, 255, 0))
				end
			else
				table.remove(XayahPassiveTable,i)
			end
			object.hit = false
		end
	end
end

function OnLoad()
	Xayah()
end