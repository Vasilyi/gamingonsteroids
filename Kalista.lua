if myHero.charName ~= "Kalista" then return end
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

local Scriptname,Version,Author,LVersion = "TRUSt in my Kalista","v1.12","TRUS","7.22"
class "Kalista"
require "DamageLib"
local chainedally = nil
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8

JungleHpBarOffset = {
	["SRU_Dragon_Water"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
	["SRU_Dragon_Fire"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
	["SRU_Dragon_Earth"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
	["SRU_Dragon_Air"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
	["SRU_Dragon_Elder"] = {Width = 140, Height = 4, XOffset = 11, YOffset = -142},
	["SRU_Baron"] = {Width = 190, Height = 10, XOffset = 16, YOffset = 24},
	["SRU_RiftHerald"] = {Width = 139, Height = 6, XOffset = 12, YOffset = 22},
	["SRU_Red"] = {Width = 139, Height = 4, XOffset = -7, YOffset = -19},
	["SRU_Blue"] = {Width = 139, Height = 4, XOffset = -14, YOffset = -38},
	["SRU_Gromp"] = {Width = 86, Height = 2, XOffset = 16, YOffset = -28},
	["Sru_Crab"] = {Width = 61, Height = 2, XOffset = 37, YOffset = -8},
	["SRU_Krug"] = {Width = 79, Height = 2, XOffset = 22, YOffset = -30},
	["SRU_Razorbeak"] = {Width = 74, Height = 2, XOffset = 15, YOffset = -23},
	["SRU_Murkwolf"] = {Width = 74, Height = 2, XOffset = 24, YOffset = -30}
}


function Kalista:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"	
		_G.SDK.Orbwalker:OnPostAttack(function() 
			local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
			local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
			local QMinMana = self.Menu.Combo.qMinMana:Value()
			if (combomodeactive or harassactive) then	
				if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
					self:CastQ(_G.SDK.Orbwalker:GetTarget(),combomodeactive or false)
				end
			end
		end)
	elseif _G.EOW then
		orbwalkername = "EOW"	
		_G.EOW:AddCallback(_G.EOW.AfterAttack, function() self:DelayedQ() end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		_G.GOS:OnAttackComplete(function() 
			local combomodeactive = _G.GOS:GetMode() == "Combo"
			local harassactive = _G.GOS:GetMode() == "Harass"
			local QMinMana = self.Menu.Combo.qMinMana:Value()
			if (combomodeactive or harassactive) then
				if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
					self:CastQ(_G.GOS:GetTarget(),combomodeactive or false)
				end
			end
		end)
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end
function Kalista:DelayedQ()
	DelayAction(function() 
		local combomodeactive = _G.EOW:Mode() == 1
		local harassactive = _G.EOW:Mode() == 2
		local QMinMana = self.Menu.Combo.qMinMana:Value()
		if (combomodeactive or harassactive) then
			if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
				self:CastQ(_G.EOW:GetTarget(),combomodeactive or false)
			end
		end
	end, 0.05)
end
--[[Spells]]
function Kalista:LoadSpells()
	Q = {Range = 1150, width = 40, Delay = 0.25, Speed = 2100}
	E = {Range = 1000}
end

function Kalista:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyKalista", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "AlwaysKS", name = "Always KS with E", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "qMinMana", name = "Minimal mana for Q:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	
	--[[UseR]]
	self.Menu:MenuElement({type = MENU, id = "RLogic", name = "AutoR Settings"})
	self.Menu.RLogic:MenuElement({id = "Active", name = "Active", value = true})
	self.Menu.RLogic:MenuElement({id = "RMaxHealth", name = "Health for AutoR:", value = 30, min = 0, max = 100, identifier = "%"})
	
	--[[LastHit]]
	self.Menu:MenuElement({type = MENU, id = "AutLastHit", name = "LastHit E settings"})
	self.Menu.AutLastHit:MenuElement({id = "Active", name = "Always active", value = true})
	self.Menu.AutLastHit:MenuElement({id = "keyActive", name = "Activation key", key = string.byte(" ")})
	self.Menu.AutLastHit:MenuElement({id = "MinTargets", name = "Min creeps:", value = 1, min = 0, max = 5})
	
	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawEDamage", name = "Draw number health after E", value = true})
	self.Menu.Draw:MenuElement({id = "DrawEBarDamage", name = "On hpbar after E", value = true})
	--self.Menu.Draw:MenuElement({id = "HPBarOffset", name = "Z offset for HPBar ", value = 0, min = -100, max = 100, tooltip = "change this if damage showed in wrong position"})
	self.Menu.Draw:MenuElement({id = "DrawInPrecent", name = "Draw numbers in percent", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw Killable with E", value = true})
	self.Menu.Draw:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.Draw:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	self.Menu.Draw:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseELasthit", name = "Use E Harass when lasthit", value = true})
	self.Menu.Harass:MenuElement({id = "HarassMinEStacksLH", name = "Min E stacks (LastHit): ", value = 3, min = 0, max = 10})
	self.Menu.Harass:MenuElement({id = "harassUseERange", name = "Use E when out of range", value = true})
	self.Menu.Harass:MenuElement({id = "HarassMinEStacks", name = "Min E stacks (Range): ", value = 3, min = 0, max = 10})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	
	self.Menu:MenuElement({type = MENU, id = "SmiteMarker", name = "AutoE Jungle"})
	self.Menu.SmiteMarker:MenuElement({id = "Enabled", name = "Enabled", key = string.byte("K"), toggle = true})
	self.Menu.SmiteMarker:MenuElement({id = "MarkBaron", name = "Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkHerald", name = "Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkDragon", name = "Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkBlue", name = "Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkRed", name = "Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkGromp", name = "Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkWolves", name = "Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkRazorbeaks", name = "Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkKrugs", name = "Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
	self.Menu.SmiteMarker:MenuElement({id = "MarkCrab", name = "Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
	
	
	self.Menu:MenuElement({type = MENU, id = "SmiteDamage", name = "Draw damage in Jungle"})
	self.Menu.SmiteDamage:MenuElement({id = "Enabled", name = "Display text", value = true})
	self.Menu.SmiteDamage:MenuElement({id = "EnabledHPBar", name = "Display on HPBar", value = true})
	self.Menu.SmiteDamage:MenuElement({id = "MarkBaron", name = "Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkHerald", name = "Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkDragon", name = "Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkBlue", name = "Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkRed", name = "Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkGromp", name = "Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkWolves", name = "Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkRazorbeaks", name = "Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkKrugs", name = "Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
	self.Menu.SmiteDamage:MenuElement({id = "MarkCrab", name = "Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Kalista:ChainedAlly()
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:HasBuff(hero,"kalistacoopstrikeally") then
			chainedally = hero
		end
	end	
end



function Kalista:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	if not chainedally then self:ChainedAlly() end 
	
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	local QMinMana = self.Menu.Combo.qMinMana:Value()
	
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) then
		if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) and not currenttarget then
			self:CastQ(currenttarget,combomodeactive or false)
		end
		if (not canattack or not currenttarget) and self.Menu.Combo.comboUseE:Value() then
			self:CastE(currenttarget,combomodeactive or false)
		end
	end
	
	if self.Menu.AlwaysKS:Value() then
		self:CastE(false,combomodeactive or false)
	end
	if self:CanCast(_E) then 
		if self.Menu.Harass.harassUseELasthit:Value() then
			self:UseEOnLasthit()
		end
		if self.Menu.AutLastHit.Active:Value() or self.Menu.keyActive.Active:Value() then
			self:LastHitCreeps()
		end
	end
	if (harassactive or combomodeactive) and self:CanCast(_E) and not canattack then
		if self.Menu.Harass.harassUseERange:Value() then 
			self:UseERange()
		end
	end
	
	
	if self.Menu.RLogic.Active:Value() and chainedally and self:CanCast(_R) then
		if chainedally.health/chainedally.maxHealth <= self.Menu.RLogic.RMaxHealth:Value()/100 and self:EnemyInRange(chainedally.pos,500) > 0 then
			Control.CastSpell(HK_R)
		end
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

function Kalista:CastSpell(spell,pos)
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

local SmiteTable = {
	SRU_Baron = "MarkBaron",
	SRU_RiftHerald = "MarkHerald",
	SRU_Dragon_Water = "MarkDragon",
	SRU_Dragon_Fire = "MarkDragon",
	SRU_Dragon_Earth = "MarkDragon",
	SRU_Dragon_Air = "MarkDragon",
	SRU_Dragon_Elder = "MarkDragon",
	SRU_Blue = "MarkBlue",
	SRU_Red = "MarkRed",
	SRU_Gromp = "MarkGromp",
	SRU_Murkwolf = "MarkWolves",
	SRU_Razorbeak = "MarkRazorbeaks",
	SRU_Krug = "MarkKrugs",
	Sru_Crab = "MarkCrab",
}

function Kalista:LastHitCreeps()
	local minionlist = {}
	local lhcount = 0
	if _G.SDK then
		minionlist = _G.SDK.ObjectManager:GetEnemyMinions(E.Range)
		for i, minion in pairs(minionlist) do
			if minion.valid and minion.isEnemy and self:GetSpears(minion) > 0 then 
				local EDamage = getdmg("E",minion,myHero) 
				if EDamage > minion.health then
					lhcount = lhcount + 1
				end
			end
		end
	elseif _G.GOS then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion.valid and minion.isEnemy and self:GetSpears(minion) > 0 then 
				local EDamage = getdmg("E",minion,myHero) 
				if EDamage > minion.health then
					lhcount = lhcount + 1
				end
			end
		end
	end
	if lhcount >= self.Menu.AutLastHit.MinTargets:Value() then
		Control.CastSpell(HK_E)
	end
end
function Kalista:DrawDamageMinion(type, minion, damage)
	if not type or not self.Menu.SmiteDamage[type] then
		return
	end
	
	
	if self.Menu.SmiteDamage[type]:Value() then
		
		if self.Menu.SmiteDamage.Enabled:Value() then
			local offset = self.Menu.Draw.TextOffset:Value()
			local fontsize = self.Menu.Draw.TextSize:Value()
			local InPercents = self.Menu.Draw.DrawInPrecent:Value()
			local healthremaining = InPercents and math.floor((minion.health - damage)/minion.maxHealth*100).."%" or math.floor(minion.health - damage,1)
			Draw.Text(healthremaining, fontsize, minion.pos2D.x, minion.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
		end
		
		if self.Menu.SmiteDamage.EnabledHPBar:Value() then 
			local barPos = minion.hpBar
			if barPos.onScreen then
				local damage = damage
				local percentHealthAfterDamage = math.max(0, minion.health - damage) / minion.maxHealth
				local BarWidth = JungleHpBarOffset[minion.charName]["Width"]
				local BarHeight = JungleHpBarOffset[minion.charName]["Height"]
				local YOffset = JungleHpBarOffset[minion.charName]["YOffset"]
				local XOffset = JungleHpBarOffset[minion.charName]["XOffset"]
				local XPosStart = barPos.x + XOffset + BarWidth * 0
				local xPosEnd = barPos.x + XOffset + BarWidth * percentHealthAfterDamage
				
				Draw.Line(XPosStart, barPos.y + YOffset,xPosEnd, barPos.y + YOffset, BarHeight, self.Menu.Draw.DrawColor:Value())
			end
		end
		
	end
	
end

function Kalista:DrawSmiteableMinion(type,minion)
	if not type or not self.Menu.SmiteMarker[type] then
		return
	end
	if self.Menu.SmiteMarker[type]:Value() then
		if minion.pos2D.onScreen then
			Draw.Circle(minion.pos,minion.boundingRadius,6,Draw.Color(0xFF00FF00));
		end
		if self:CanCast(_E) then
			Control.CastSpell(HK_E)
		end
	end
end
function Kalista:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return Buff.expireTime
		end
	end
	return false
end


function Kalista:CheckKillableMinion()
	local minionlist = {}
	if _G.SDK then
		minionlist = _G.SDK.ObjectManager:GetMonsters(E.Range)
	elseif _G.GOS then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < E.Range then
				table.insert(minionlist, minion)
			end
		end
	end
	for i, minion in pairs(minionlist) do
		if self:GetSpears(minion) > 0 then 
			local EDamage = getdmg("E",minion,myHero)
			local minionName = minion.charName
			if EDamage*((minion.charName == "SRU_RiftHerald" and 0.65) or (self:HasBuff(myHero,"barontarget") and 0.5) or 0.79) > minion.health then
				local minionName = minion.charName
				self:DrawSmiteableMinion(SmiteTable[minionName], minion)
			else
				self:DrawDamageMinion(SmiteTable[minionName], minion, EDamage)
			end
		end
	end
end
function Kalista:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Kalista:GetSpears(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == "kalistaexpungemarker" then
			return Buff.count
		end
	end
	return 0
end

function Kalista:UseERange()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or self:GetEnemyHeroes()
	local target = (_G.SDK and _G.SDK.TargetSelector.SelectedTarget) or (_G.EOW and _G.EOW:GetTarget()) or (_G.GOS and _G.GOS:GetTarget())
	if target then return end 
	for i, hero in pairs(heroeslist) do
		if self:GetSpears(hero) >= self.Menu.Harass.HarassMinEStacks:Value() then
			if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) > 900 then
				Control.CastSpell(HK_E)
			end
		end
	end
end

function Kalista:UseEOnLasthit()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or self:GetEnemyHeroes()
	local useE = false
	local minionlist = {}
	
	for i, hero in pairs(heroeslist) do
		if self:GetSpears(hero) >= self.Menu.Harass.HarassMinEStacksLH:Value() then
			if _G.SDK then
				minionlist = _G.SDK.ObjectManager:GetEnemyMinions(E.Range)
			elseif _G.GOS then
				for i = 1, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < E.Range then
						table.insert(minionlist, minion)
					end
				end
			end
			
			for i, minion in pairs(minionlist) do
				local spearsamount = self:GetSpears(minion)
				if spearsamount > 0 then 
					local EDamage = getdmg("E",minion,myHero)
					-- local basedmg = ({20, 30, 40, 50, 60})[level] + 0.6* (myHero.totalDamage)
					-- local perspear = ({10, 14, 19, 25, 32})[level] + ({0.2, 0.225, 0.25, 0.275, 0.3})[level]* (myHero.totalDamage)
					-- local tempdamage = basedmg + perspear*spearsamount
					if EDamage*0.8 > minion.health then
						Control.CastSpell(HK_E)
					end
				end
			end
		end
	end
end

function Kalista:EnemyInRange(source,radius)
	local count = 0
	if not source then return end
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1700)) or self:GetEnemyHeroes()
	for i, target in ipairs(heroeslist) do
		if target.pos:DistanceTo(source) < radius then 
			count = count + 1
		end
	end
	return count
end

function Kalista:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy and Hero.isTargetable then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Kalista:GetETarget()
	self.KillableHeroes = {}
	self.DamageHeroes = {}
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1200)) or self:GetEnemyHeroes()
	local level = myHero:GetSpellData(_E).level
	for i, hero in pairs(heroeslist) do
		if self:GetSpears(hero) > 0 and myHero.pos:DistanceTo(hero.pos)<E.Range then 
			local EDamage = getdmg("E",hero,myHero)*0.9
			if hero.health and EDamage and EDamage > hero.health then
				table.insert(self.KillableHeroes, hero)
			else
				table.insert(self.DamageHeroes, {hero = hero, damage = EDamage})
			end
		end
	end
	return self.KillableHeroes, self.DamageHeroes
end

--[[CastQ]]
function Kalista:CastQ(target, combo)
	if (not _G.SDK and not _G.GOS) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) and target:GetCollision(Q.Width,Q.Speed,Q.Delay) == 0 then
		local castPos = target:GetPrediction(Q.Speed,Q.Delay)
		self:CastSpell(HK_Q, castPos)
	end
end


--[[CastE]]
function Kalista:CastE(target,combo)
	local killable, damaged = self:GetETarget()
	if self:CanCast(_E) and #killable > 0 then
		Control.CastSpell(HK_E)
	end
end



function Kalista:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Kalista:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Kalista:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Kalista:Draw()
	if self.Menu.SmiteMarker.Enabled:Value() then
		self:CheckKillableMinion()
	end
	local killable, damaged = self:GetETarget()
	local offset = self.Menu.Draw.TextOffset:Value()
	local fontsize = self.Menu.Draw.TextSize:Value()
	local InPercents = self.Menu.Draw.DrawInPrecent:Value()
	if self.Menu.Draw.DrawE:Value() then
		for i, hero in pairs(killable) do
			Draw.Circle(hero.pos, 80, 6, self.Menu.Draw.DrawColor:Value())
			Draw.Text("killable", fontsize, hero.pos2D.x, hero.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
		end	
	end
	if self.Menu.Draw.DrawEDamage:Value() or self.Menu.Draw.DrawEBarDamage:Value()then
		for i, hero in pairs(damaged) do
			if self.Menu.Draw.DrawEBarDamage:Value() then 
				local barPos = hero.hero.hpBar
				if barPos.onScreen then
					--local barYOffset = self.Menu.Draw.HPBarOffset:Value()
					local damage = hero.damage
					local percentHealthAfterDamage = math.max(0, hero.hero.health - damage) / hero.hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.hero.health/hero.hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 12, self.Menu.Draw.DrawColor:Value())
				end
			end
			if self.Menu.Draw.DrawEDamage:Value() then 
				local healthremaining = InPercents and math.floor((hero.hero.health - hero.damage)/hero.hero.maxHealth*100).."%" or math.floor(hero.hero.health - hero.damage,1)
				Draw.Text(healthremaining, fontsize, hero.hero.pos2D.x, hero.hero.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
			end
		end
	end
end

function OnLoad()
	Kalista()
end