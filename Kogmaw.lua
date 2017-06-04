if myHero.charName ~= "KogMaw" then return end
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

class "KogMaw"
local Scriptname,Version,Author,LVersion = "TRUSt in my KogMaw","v1.1","TRUS","7.11"
function KogMaw:__init()
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
				self:CastQ(_G.SDK.Orbwalker:GetTarget(),combomodeactive)
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
blockattack = false
blockmovement = false

local lastpick = 0
--[[Spells]]
function KogMaw:LoadSpells()
	Q = {Range = 1175, width = 70, Delay = 0.25, Speed = 1650}
	E = {Range = 1280, width = 120, Delay = 0.5, Speed = 1350}
	R = {Range = 1200, Delay = 1.2, Radius = 120, Speed = math.huge}
end

function KogMaw:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyKogMaw", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "MaxStacks", name = "Max R stacks: ", value = 3, min = 0, max = 10})
	self.Menu.Combo:MenuElement({id = "ManaW", name = "Save mana for W", value = true})
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "harassUseR", name = "Use R", value = true})
	self.Menu.Harass:MenuElement({id = "HarassMaxStacks", name = "Max R stacks: ", value = 3, min = 0, max = 10})
	
	
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function KogMaw:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	
	
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	
	if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) and (canmove or not currenttarget) then
		self:CastQ(currenttarget,combomodeactive or false)
		self:CastE(currenttarget,combomodeactive or false)
		self:CastR(currenttarget,combomodeactive or false)
	end
	
	
	if myHero.activeSpell and myHero.activeSpell.valid and (myHero.activeSpell.name == "KogMawQ" or myHero.activeSpell.name == "KogMawVoidOozeMissile" or myHero.activeSpell.name == "KogMawLivingArtillery") then
		EnableMovement()
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

function KogMaw:CastSpell(spell,pos)
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

function KogMaw:GetRRange()
	return (myHero:GetSpellData(_R).level > 0 and ({1200,1500,1800})[myHero:GetSpellData(_R).level]) or 0
end

function KogMaw:GetBuffs()
	self.T = {}
	for i = 0, myHero.buffCount do
		local Buff = myHero:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function KogMaw:UltStacks()
	for K, Buff in pairs(self:GetBuffs()) do
		if Buff.name:lower() == "kogmawlivingartillerycost" then
			return Buff.count
		end
	end
	return 0
end


--[[CastQ]]
function KogMaw:CastQ(target, combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) and target:GetCollision(Q.Width,Q.Speed,Q.Delay) == 0 then
		local castPos = target:GetPrediction(Q.Speed,Q.Delay)
		local newpos = myHero.pos:Extended(castPos,math.random(100,300))
		self:CastSpell(HK_Q, newpos)
	end
end


--[[CastE]]
function KogMaw:CastE(target,combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_E) and ((combo and self.Menu.Combo.comboUseE:Value()) or (combo == false and self.Menu.Harass.harassUseE:Value())) then
		local castPos = target:GetPrediction(E.Speed,E.Delay)
		local newpos = myHero.pos:Extended(castPos,math.random(100,300))
		self:CastSpell(HK_E, newpos)
	end
end

--[[CastR]]
function KogMaw:CastR(target,combo)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local RRange = self:GetRRange()
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(RRange, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(RRange,"AP"))
	local currentultstacks = self:UltStacks()
	if target and target.type == "AIHeroClient" and self:CanCast(_R) 
	and ((combo and self.Menu.Combo.comboUseR:Value()) or (combo == false and self.Menu.Harass.harassUseR:Value())) 
	and ((combo == false and currentultstacks < self.Menu.Harass.HarassMaxStacks:Value()) or (currentultstacks < self.Menu.Combo.MaxStacks:Value()))
	then
		local castPos = target:GetPrediction(R.Speed,R.Delay)
		self:CastSpell(HK_R, castPos)
	end
end

function KogMaw:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function KogMaw:CheckMana(spellSlot)
	local savemana = self.Menu.Combo.ManaW:Value()
	return myHero:GetSpellData(spellSlot).mana < (myHero.mana - ((savemana and 40) or 0))
end

function KogMaw:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


function OnLoad()
	KogMaw()
end