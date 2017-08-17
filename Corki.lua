if myHero.charName ~= "Corki" then return end
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		SDK.Orbwalker:SetMovement(bool)
		SDK.Orbwalker:SetAttack(bool)
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
		currenttarget = _G.SDK.TargetSelector.SelectedTarget or _G.SDK.Orbwalker:GetTarget()
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

class "Corki"
local Scriptname,Version,Author,LVersion = "TRUSt in my Corki","v1.0","TRUS","7.12"

if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
	require 'Eternal Prediction'
	PrintChat("Eternal Prediction library loaded")
end
local EPrediction = {}

function Corki:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
		_G.SDK.Orbwalker:OnPostAttack(function() 
			local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
			local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
			if (combomodeactive or harassactive) then
				self:CastQ(_G.SDK.TargetSelector.SelectedTarget or _G.SDK.Orbwalker:GetTarget(825,_G.SDK.DAMAGE_TYPE_MAGICAL),combomodeactive)
			end
		end)
	elseif _G.EOW then
		orbwalkername = "EOW"	
		_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
			local combomodeactive = _G.EOW:Mode() == 1
			local harassactive = _G.EOW:Mode() == 2
			if (combomodeactive or harassactive) then
				self:CastQ(_G.EOW:GetTarget(),combomodeactive)
			end
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		_G.GOS:OnAttackComplete(function() 
			local combomodeactive = _G.GOS:GetMode() == "Combo"
			local harassactive = _G.GOS:GetMode() == "Harass"
			if (combomodeactive or harassactive) then
				self:CastQ(_G.GOS:GetTarget(),combomodeactive)
			end
		end)
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end

--[[Spells]]
function Corki:LoadSpells()
	Q = {Range = 825, Width = 250, Delay = 0.3, Speed = 1000}
	R = {Range = 1300, Delay = 0.2, Width = 120, Speed = 2000}
	R2 = {Range = 1500, Delay = 0.2, Width = 120, Speed = 2000}
	E = {Range = 400}
	
	if TYPE_GENERIC then
		local QSpell = Prediction:SetSpell({range = Q.Range, speed = Q.Speed, delay = Q.Delay, width = Q.Width}, TYPE_CIRCULAR, true)
		EPrediction["Q"] = QSpell
		local RSpell = Prediction:SetSpell({range = R.Range, speed = R.Speed, delay = R.Delay, width = R.Width}, TYPE_LINE, true)
		EPrediction["R"] = RSpell
		local R2Spell = Prediction:SetSpell({range = R.Range, speed = R2.Speed, delay = R2.Delay, width = R2.Width}, TYPE_LINE, true)
		EPrediction["R2"] = R2Spell
		
	end
end

function Corki:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyCorki", name = Scriptname})
	--[[Combo]]
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "MaxStacks", name = "Min R stacks: ", value = 0, min = 0, max = 7})
	self.Menu.Combo:MenuElement({id = "ManaW", name = "Save mana for W", value = true})
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseR", name = "Use R", value = true})
	self.Menu.Harass:MenuElement({id = "HarassMaxStacks", name = "Min R stacks: ", value = 3, min = 0, max = 7})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	
	if TYPE_GENERIC then
		self.Menu:MenuElement({id = "EternalUse", name = "Use eternal prediction", value = true})
		self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
	end
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Corki:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	
	
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	
	if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) and (canmove or not currenttarget) then
		self:CastQ(currenttarget,combomodeactive or false)
		if combomodeactive then
			self:CastE(currenttarget,true)
		end
		self:CastR(currenttarget,combomodeactive or false)
	end
end

function EnableMovement()
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

function Corki:CastSpell(spell,pos)
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

function Corki:GetRRange()
	return (self:HasBig() and R2.Range or R.Range)
end

function Corki:GetBuffs()
	self.T = {}
	for i = 0, myHero.buffCount do
		local Buff = myHero:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Corki:HasBig()
	for K, Buff in pairs(self:GetBuffs()) do
		if Buff.name:lower() == "corkimissilebarragecounterbig" then
			return true
		end
	end
	return false
end

function Corki:StacksR()
	return myHero:GetSpellData(_R).ammo
end
--[[CastQ]]
function Corki:CastQ(target, combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) then
		local castpos
		if TYPE_GENERIC and self.Menu.EternalUse:Value() then
			castPos = EPrediction["Q"]:GetPrediction(target, myHero.pos)
			if castPos.hitChance >= self.Menu.minchance:Value() then
				self:CastSpell(HK_Q, castPos.castPos)
			end
		else
			castPos = target:GetPrediction(Q.Speed,Q.Delay)
			self:CastSpell(HK_Q, castPos)
		end
	end
end


--[[CastE]]
function Corki:CastE(target,combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_E) and self.Menu.Combo.comboUseE:Value() then
		self:CastSpell(HK_E, target.pos)
	end
end

--[[CastR]]
function Corki:CastR(target,combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local RRange = self:GetRRange()
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(RRange, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(RRange,"AP"))
	local currentultstacks = self:StacksR()
	if target and target.type == "AIHeroClient" and self:CanCast(_R) 
	and ((combo and self.Menu.Combo.comboUseR:Value()) or (combo == false and self.Menu.Harass.harassUseR:Value())) 
	and ((combo == false and currentultstacks > self.Menu.Harass.HarassMaxStacks:Value()) or (combo and currentultstacks > self.Menu.Combo.MaxStacks:Value()))
	then
		local ulttype = self:HasBig() and "R2" or "R"
		if TYPE_GENERIC and self.Menu.EternalUse:Value() then
			castPos = EPrediction[ulttype]:GetPrediction(target, myHero.pos)
			if castPos.hitChance >= self.Menu.minchance:Value() and EPrediction[ulttype]:mCollision() == 0 then
				local newpos = myHero.pos:Extended(castPos.castPos,math.random(100,300))
				self:CastSpell(HK_R, newpos)
			end
		elseif ulttype == "R2" and target:GetCollision(R2.Radius,R2.Speed,R2.Delay) == 0 then
			castPos = target:GetPrediction(R2.Speed,R2.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_R, newpos)
		elseif ulttype == "R" and target:GetCollision(R.Radius,R.Speed,R.Delay) == 0 then
			castPos = target:GetPrediction(R.Speed,R.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_R, newpos)
		end
	end
end

function Corki:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Corki:CheckMana(spellSlot)
	local savemana = self.Menu.Combo.ManaW:Value()
	return myHero:GetSpellData(spellSlot).mana < (myHero.mana - ((savemana and 40) or 0))
end

function Corki:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


function OnLoad()
	Corki()
end