if myHero.charName ~= "Kled" then return end
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

function UseTiamat()
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
	if target then 
		local tiamatitem = GetInventorySlotItem(3077) or GetInventorySlotItem(3074) or GetInventorySlotItem(3748)
		if tiamatitem then
			Control.CastSpell(keybindings[tiamatitem])
		end
	end
end

class "Kled"
local Scriptname,Version,Author,LVersion = "TRUSt in my Kled","v1.0","TRUS","7.22"
require "2DGeometry"
require "MapPositionGOS"	
require "DamageLib"
if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
end

function Kled:__init()
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

local lastpick = 0
--[[Spells]]
function Kled:LoadSpells()
	Q = {Range = 700, Width = 40, Delay = 0.2, Speed = 3000, Collision = false, aoe = false, type = "line"}
	SkarlQ = {Range = 800, Width = 45, Delay = 0.25, Speed = 1600, Collision = false, aoe = false, type = "line"}
	E = {Range = 550, Delay = 0.1, Speed = 500, Width = 10}
end

function Kled:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyKled", name = Scriptname})
	
	self.Menu:MenuElement({id = "Items", name = "Items", type = MENU})
	self.Menu.Items:MenuElement({id = "UseBotrk", name = "Use Botrk", value = true})
	self.Menu.Items:MenuElement({id = "UseTiamat", name = "Use Tiamat/Hydras", value = true})
	
	
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQDismounted", name = "UseQ dismounted", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseQMounted", name = "UseQ mounted", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "UseE", value = true})
	
	
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQDismounted", name = "UseQ dismounted", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseQMounted", name = "UseQ mounted", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "UseE", value = false})
	
	if (TPred) then
		self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 1, min = 0, max = 5, step = 1, identifier = ""})
	end
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Kled:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local farmactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.EOW and _G.EOW:Mode() == 3) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Lasthit") 
	local laneclear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.EOW and _G.EOW:Mode() == 4) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Clear") 
	local mounted = self:IsKled()

	if combomodeactive then
		
		if self.Menu.Items.UseBotrk:Value() then
			UseBotrk()
		end
		if self.Menu.Items.UseTiamat:Value() and not canattack then
			UseTiamat()
		end 
		if (self:CanCast(_Q)) then
			if not mounted and self.Menu.ComboMode.UseQDismounted:Value() and (not canattack or not currenttarget) then 
				self:UseQDM(currenttarget)
			end
			if mounted and self.Menu.ComboMode.UseQMounted:Value() and (not canattack or not currenttarget) then 
				self:UseQM(currenttarget)
			end
		end
		if (mounted and self:CanCast(_E)) then
			if self.Menu.ComboMode.UseE:Value() and not currenttarget then
				self:UseE(currenttarget)
			end
		end
	end
	if harassactive then
		if (mounted and self:CanCast(_E)) then
			if self.Menu.HarassMode.UseE:Value() and not currenttarget then
				self:UseE(currenttarget)
			end
		end
		if (self:CanCast(_Q)) then
			if not mounted and self.Menu.HarassMode.UseQDismounted:Value() and (not canattack or not currenttarget) then 
				self:UseQDM(currenttarget)
			end
			if mounted and self.Menu.HarassMode.UseQMounted:Value() and (not canattack or not currenttarget) then 
				self:UseQM(currenttarget)
			end
		end
	end
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

function Kled:CastSpell(spell,pos)
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


function Kled:IsKled()
	return myHero:GetSpellData(_Q).name == "KledQ"
end


function Kled:UseE(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AD"))
	if target and target.type == "AIHeroClient" then
		if (myHero:GetSpellData(_E).name == "KledE") then
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, E.Delay, E.Width, E.Range,E.Speed,myHero.pos,true, "line")
				local EndLine = LineSegment(Point(myHero.pos), Point(castpos))
				local inwall = MapPosition:intersectsWall(EndLine)
				if not inwall and (HitChance >= self.Menu.minchance:Value()) then
					local newpos = myHero.pos:Extended(castpos,math.random(100,300))
					self:CastSpell(HK_E, newpos)
				end
			else
				local castPos = target:GetPrediction(E.Speed,E.Delay)
				local EndLine = LineSegment(Point(myHero.pos), Point(castPos))
				local inwall = MapPosition:intersectsWall(EndLine)
				if not inwall then
					local newpos = myHero.pos:Extended(castPos,math.random(100,300))
					self:CastSpell(HK_E, newpos)
				end
			end
			
		else
			self:CastSpell(HK_E, target.pos)
		end
	end
end



function Kled:UseQDM(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
	if target and target.type == "AIHeroClient" then
		local castPos
		local Qlvl = myHero:GetSpellData(_Q).level
		local tempdmg = ({30, 45, 60, 75, 90})[Qlvl] + 0.8* myHero.bonusDamage
		local runningaway = (myHero.pos:DistanceTo(target.posTo) - myHero.pos:DistanceTo(target.pos)) > 10
		if runningaway and CalcPhysicalDamage(myHero,target,tempdmg) < target.health and myHero.mana < 75 then return end 
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay, Q.Width, Q.Range,Q.Speed,myHero.pos,true, "line")
			if (HitChance >= self.Menu.minchance:Value()) then
				local newpos = myHero.pos:Extended(castpos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
		else
			castPos = target:GetPrediction(Q.Speed,Q.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, newpos)
		end
	end
end

function Kled:UseQM(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(SkarlQ.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(SkarlQ.Range,"AD"))
	if target and target.type == "AIHeroClient" then
		local castPos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, SkarlQ.Delay, SkarlQ.Width, SkarlQ.Range,SkarlQ.Speed,myHero.pos,true, "line")
			if (HitChance >= self.Menu.minchance:Value()) then
				local newpos = myHero.pos:Extended(castpos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
		else
			castPos = target:GetPrediction(SkarlQ.Speed,SkarlQ.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, newpos)
		end
	end
end


function Kled:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end


function Kled:CanCast(spellSlot)
	return self:IsReady(spellSlot)
end


function OnLoad()
	Kled()
end