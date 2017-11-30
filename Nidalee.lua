if myHero.charName ~= "Nidalee" then return end
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

class "Nidalee"
local Scriptname,Version,Author,LVersion = "TRUSt in my Nidalee","v1.0","TRUS","7.22"
require "2DGeometry"
require "MapPositionGOS"	
require "DamageLib"
if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
end

function Nidalee:__init()
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
function Nidalee:LoadSpells()
	Q = {Range = 1500, Width = 40, Delay = 250, Speed = 1300, Collision = false, aoe = false, type = "line"}
	E = {Range = 300}
end

function Nidalee:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyNidalee", name = Scriptname})
	
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "UseQ dismounted", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseQCat", name = "UseQ in form", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseWCat", name = "UseW in form", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseECat", name = "UseE in form", value = true})
	
	
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "UseQ dismounted", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseQCat", name = "UseQ form", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseECat", name = "UseE in form", value = false})
	
	if (TPred) then
		self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 1, min = 0, max = 5, step = 1, identifier = ""})
	end
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Nidalee:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local farmactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.EOW and _G.EOW:Mode() == 3) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Lasthit") 
	local laneclear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.EOW and _G.EOW:Mode() == 4) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Clear") 
	local formed = self:IsCat()
	if combomodeactive then
		if formed and self:CanCast(_W) and self.Menu.ComboMode.UseWCat:Value() then 
			self:UseWCat(currenttarget)
		elseif self:CanCast(_E) and formed and self.Menu.ComboMode.UseECat:Value() and currenttarget then
			self:UseECat(currenttarget)
		elseif (self:CanCast(_Q)) then
			if not formed and self.Menu.ComboMode.UseQ:Value() and (not canattack or not currenttarget) then 
				self:UseQ(currenttarget)
			end
			if formed and self.Menu.ComboMode.UseQCat:Value() and (not canattack or not currenttarget) then 
				self:UseQCat(currenttarget)
			end
		end
		
	end
	if harassactive then
		if (formed and self:CanCast(_E) and self.Menu.HarassMode.UseECat:Value() and currenttarget) then
			self:UseECat(currenttarget)
		elseif (self:CanCast(_Q) and not formed and self.Menu.HarassMode.UseQ:Value()) then 
			self:UseQ(currenttarget)
		elseif formed and self.Menu.HarassMode.UseQCat:Value() and currenttarget then 
			self:UseCat(currenttarget)
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

function Nidalee:CastSpell(spell,pos)
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

function Nidalee:UseWCat(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = self:HauntedEnemy() or target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(375, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(375,"AP"))
	if target and myHero.pos:DistanceTo(target.pos)> 150 then
		self:CastSpell(HK_W, target.pos)
	end
end
function Nidalee:IsCat()
	return myHero:GetSpellData(_Q).name == "Takedown"
end


function Nidalee:UseECat(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target and target.type == "AIHeroClient" then
		self:CastSpell(HK_E, target.pos)
	end
end

function Nidalee:HauntedEnemy()
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos)<750 and self:Haunted(Hero) then
			return Hero
		end
	end
end

function Nidalee:UseQ(target)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" then
		local castPos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay/1000, Q.Width, Q.Range,Q.Speed,myHero.pos,true, "line")
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

function Nidalee:UseQCat(target)
	if (not _G.SDK and not _G.GOS) then return end
	if self:QCharged() then return end 
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(myHero.range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(myHero.range,"AP"))
	if target and target.type == "AIHeroClient" then
		Control.CastSpell(HK_Q)
	end
end


function Nidalee:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end


function Nidalee:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Nidalee:Haunted(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == "nidaleepassivehunted" then
			return true
		end
	end
	return false
end

function Nidalee:QCharged()
	for K, Buff in pairs(self:GetBuffs(myHero)) do
		if Buff.name:lower() == "takedown" then
			return true
		end
	end
	return false
end

function Nidalee:CanCast(spellSlot)
	return self:IsReady(spellSlot)
end

function OnLoad()
	Nidalee()
end