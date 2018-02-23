if myHero.charName ~= "Twitch" then return end

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
local Scriptname,Version,Author,LVersion = "TRUSt in my Twitch","v1.6","TRUS","8.1"
local Twitch = {}
Twitch.__index = Twitch
require "DamageLib"
local qtarget
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8
function Twitch:__init()
	if not TRUStinMyMarksmanloaded then TRUStinMyMarksmanloaded = true else return end
	self:LoadMenu()
	self.eBuffs = {}
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
		_G.SDK.Orbwalker:OnPostAttack(function(arg) 		
			DelayAction(recheckparticle,0.2)
		end)
	elseif _G.EOW then
		orbwalkername = "EOW"	
		_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
			DelayAction(recheckparticle,0.2)
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		_G.GOS:OnAttackComplete(function() 
			DelayAction(recheckparticle,0.2)
		end)
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end

function Twitch:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyTwitch", name = Scriptname})
	self.Menu:MenuElement({id = "UseEKS", name = "Use E on killable", value = true})
	self.Menu:MenuElement({id = "UseERange", name = "Use E on running enemy", value = true})
	self.Menu:MenuElement({id = "MinStacks", name = "Minimal E stacks", value = 2, min = 0, max = 6, step = 1, identifier = ""})
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
	self.Menu:MenuElement({id = "DrawE", name = "Draw Killable with E", value = true})
	self.Menu:MenuElement({id = "DrawEDamage", name = "Draw E damage on HPBar", value = true})
	self.Menu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end
local lastcasttime = 0
function Twitch:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	self:DeadlyVenomCheck()
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name:lower() == "twitchvenomcask" and myHero.activeSpell.startTime ~= lastcasttime then
		lastcasttime = myHero.activeSpell.startTime
		DelayAction(recheckparticle,0.3)
	end
	
	
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	
	if combomodeactive then 
		if self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end	
	end
	
	if self:CanCast(_E) and self.Menu.UseEKS:Value() then
		self:UseEKS()
	end
	
	if (harassactive or combomodeactive) and self.Menu.UseERange:Value() and self:CanCast(_E) then
		self:UseERange()
	end
end

function Twitch:UseERange()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	local target = (_G.SDK and _G.SDK.TargetSelector.SelectedTarget) or (_G.GOS and _G.GOS:GetTarget())
	if target then return end 
	for i, hero in pairs(heroeslist) do
		if self.eBuffs[hero.networkID] and self.eBuffs[hero.networkID].count >= self.Menu.MinStacks:Value() then
			if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) > 1000 then
				Control.CastSpell(HK_E)
			end
		end
	end
end

function Twitch:DeadlyVenomCheck()
	for i = 1, Game.HeroCount() do
		local target = Game.Hero(i)
		if target.isEnemy then
			local target = Game.Hero(i)
			local nID = target.networkID
			local venomed = false
			if not self.eBuffs[nID] then
				self.eBuffs[nID]={count=0,durT=0}
			end
			if target:IsValidTarget(3000,false,myHero) then
				local cB = self.eBuffs[nID].count
				local dB = self.eBuffs[nID].durT
				for i = 0, target.buffCount do
					local buff = target:GetBuff(i)
					if buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
						venomed = true
						if cB < 6 and buff.duration > dB then
							self.eBuffs[nID].count = cB + 1
							self.eBuffs[nID].durT = buff.duration
						else
							self.eBuffs[nID].durT = buff.duration
						end
					end
				end
				if not venomed then 
					self.eBuffs[nID].count = 0
					self.eBuffs[nID].durT = 0
				end
			end
		end
	end
end

local DamageModifiersTable = {
	summonerexhaustdebuff = 0.6,
	itemphantomdancerdebuff = 0.88
}

function Twitch:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end
function Twitch:DamageModifiers(target)
	local currentpercent = 1
	for K, Buff in pairs(self:GetBuffs(myHero)) do
		if DamageModifiersTable[Buff.name:lower()] then
			currentpercent = currentpercent*DamageModifiersTable[Buff.name:lower()]
		end
	end
	for K, Buff in pairs(self:GetBuffs(target)) do
		if Buff.count > 0 and Buff.name and string.find(Buff.name, "PressThreeAttack") and (Buff.expireTime - Buff.startTime == 6) then
			currentpercent = currentpercent * 1.12
		end
	end
	return currentpercent
end
function Twitch:GetETarget()
	self.KillableHeroes = {}
	self.DamageHeroes = {}
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1200)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	local level = myHero:GetSpellData(_E).level
	if level == 0 then return end
	for i, hero in pairs(heroeslist) do
		if self.eBuffs[hero.networkID] then
			local stackscount = self.eBuffs[hero.networkID].count
			if stackscount > 0 then 
				local EDamage = (self:GetStacks(stacks[hero.charName].name) * (({15, 20, 25, 30, 35})[level] + 0.2 * myHero.ap + 0.25 * myHero.bonusDamage)) + ({20, 25, 30, 35, 40})[level]
				local tmpdmg = CalcPhysicalDamage(myHero, hero, EDamage)
				local damagemods = self:DamageModifiers(hero)
				--PrintChat(damagemods)
				tmpdmg = tmpdmg * damagemods
				if hero.health and tmpdmg then 
					if tmpdmg > hero.health and myHero.pos:DistanceTo(hero.pos)<1200 then
						table.insert(self.KillableHeroes, hero)
					else
						table.insert(self.DamageHeroes, {hero = hero, damage = tmpdmg})
					end
				end
			end
		end
	end
	return self.KillableHeroes, self.DamageHeroes
end

function Twitch:UseEKS()
	local ETarget, damaged = self:GetETarget()
	if #ETarget > 0 then
		Control.KeyDown(HK_E)
		Control.KeyUp(HK_E)
	end
end

function Twitch:Draw()
	if self.Menu.DrawE:Value() or self.Menu.DrawEDamage:Value() then
		local ETarget, damaged = self:GetETarget()
		if self.Menu.DrawE:Value() then
			if not ETarget then return end
			for i, hero in pairs(ETarget) do
				Draw.Circle(hero.pos, 60, 3, self.Menu.DrawColor:Value())
			end
		end
		if self.Menu.DrawEDamage:Value() then 
			if not damaged then return end
			for i, hero in pairs(damaged) do
				local barPos = hero.hero.hpBar
				if barPos.onScreen then
					local damage = hero.damage
					local percentHealthAfterDamage = math.max(0, hero.hero.health - damage) / hero.hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.hero.health/hero.hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 12, self.Menu.DrawColor:Value())
				end
			end
		end
	end
end


function Twitch:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Twitch:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Twitch:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function OnLoad()
	Twitch:__init()
end