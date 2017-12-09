if myHero.charName ~= "Diana" then return end
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

class "Diana"
local Scriptname,Version,Author,LVersion = "TRUSt in my Diana","v1.0","TRUS","7.23"

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
end

function Diana:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
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
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername .. (TPred and " TPred" or ""))
end

--[[Spells]]
function Diana:LoadSpells()
	Q = {Range = 830, Width = 200, Delay = 0.35, Speed = 1800}
	W = {Range = 200}
	E = {Range = 450}
	R = {Range = 825}
end
function Diana:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end


function Diana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyDiana", name = Scriptname})
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R on Moonlight", value = true})
	self.Menu.Combo:MenuElement({id = "secondR", name = "Second R if kill", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.Combo:MenuElement({id = "rCombo", name = "R>Q combo", key = string.byte("G")})
	self.Menu.Combo:MenuElement({id = "misayaCombo", name = "Misaya combo", key = string.byte("T")})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.Combo:MenuElement({id = "RU"..hero.charName, name = "UseR in rCombo only on: "..hero.charName, value = true})
	end
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({type = MENU, id = "KSMenu", name = "KS Settings"})
	self.Menu.KSMenu:MenuElement({id = "KillStealW", name = "Use W", value = true})
	self.Menu.KSMenu:MenuElement({id = "KillStealR", name = "Use R", value = true})
	
	self.Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	self.Menu.DrawMenu:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.DrawMenu:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	self.Menu.DrawMenu:MenuElement({id = "DrawOnEnemy", name = "Killable text on enemy", value = true})
	self.Menu.DrawMenu:MenuElement({id = "DrawOnHPBar", name = "Damage on hpbar", value = true})
	self.Menu.DrawMenu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	
	self.Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawE", name = "Draw W Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "ERangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "RRangeC", name = "R Range color", color = Draw.Color(0xBF3FBFFF)})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. "" .. (TPred and " TPred" or "")})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function CurrentModes()
	local canmove, canattack
	if _G.SDK then -- ic orbwalker
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
	elseif _G.EOW then -- eternal orbwalker
		canmove = _G.EOW:CanMove() 
		canattack = _G.EOW:CanAttack()
	else -- default orbwalker
		canmove = _G.GOS:CanMove()
		canattack = _G.GOS:CanAttack()
	end
	return canmove, canattack
end

function Diana:MoonlightedEnemy()
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy and myHero.pos:DistanceTo(Hero.pos)<R.Range and Hero.isTargetable and Hero.valid and Hero.visible and self:MoonLighted(Hero) then
			return Hero
		end
	end
end
function Diana:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Diana:MoonLighted(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == "dianamoonlight" then
			return true
		end
	end
	return false
end

function Diana:Tick()
	if myHero.dead then return end
	local combomodeactive = self.Menu.Combo.comboActive:Value()
	local misayacombo = self.Menu.Combo.misayaCombo:Value()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	local harassactive = self.Menu.Harass.harassActive:Value()
	local KillSteal = self.Menu.KSMenu.KillStealW:Value() or self.Menu.KSMenu.KillStealR:Value()
	if KillSteal then 
		local KSDamage = 0
		local KSTarget = nil
		if self:CanCast(_R) then
			KSTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(R.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(R.Range,"AP"))
			if KSTarget then
				KSDamage = KSDamage + getdmg("R",KSTarget,myHero)
			end
		end
		if self:CanCast(_W) then
			if KSDamage == 0 then
				KSTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
				if KSTarget then 
					KSDamage = KSDamage + getdmg("W",KSTarget,myHero)		
					if KSDamage > KSTarget.health then 
						self:CastW()
					end
				end
			else
				KSDamage = KSDamage + getdmg("W",KSTarget,myHero)
				if KSDamage > KSTarget.health then 
					Control.CastSpell(HK_R,KSTarget)
					self:CastW()
				end
			end
		end
	end
	
	if combomodeactive or misayacombo then
		local MoonlightedEnemy = self:MoonlightedEnemy()
		if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
			self:CastQ()
		end
		if self.Menu.Combo.comboUseW:Value() and self:CanCast(_W) then
			self:CastW()
		end
		if self.Menu.Combo.comboUseE:Value() and self:CanCast(_E) then
			self:CastE()
		end
		local RTarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(R.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(R.Range,"AP"))
		local Rdamage = getdmg("R",RTarget,myHero)
		
		if self:CanCast(_R) then
			if misayacombo and self.Menu.Combo.comboUseR:Value() then
				self:CastR(RTarget)
			end
			if MoonlightedEnemy and self.Menu.Combo.comboUseR:Value() then
				self:CastR(MoonlightedEnemy)
			end
			if Rdamage > RTarget.health and self.Menu.Combo.secondR:Value() then
				self:CastR(RTarget)
			end
		end
	elseif (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana) then 
		if self.Menu.Harass.harassUseQ:Value() and self:CanCast(_Q) then
			self:CastQ()
		elseif self.Menu.Harass.harassUseW:Value() and self:CanCast(_W) then
			self:CastW()
		elseif self.Menu.Harass.harassUseE:Value() and self:CanCast(_E) then
			self:CastE()
		end
	end
	
	if self.Menu.Combo.rCombo:Value() then
		local RTarget = self:GetRTarget()
		if self:CanCast(_R) then
			if RTarget then
				Control.CastSpell(HK_R,RTarget)
			end
		else
			if self.Menu.Combo.comboUseQ:Value() and self:CanCast(_Q) then
				self:CastQ(RTarget)
			end
			if self.Menu.Combo.comboUseW:Value() and self:CanCast(_W) then
				self:CastW()
			end
			if self.Menu.Combo.comboUseE:Value() and self:CanCast(_E) then
				self:CastE()
			end
		end
	end
end


function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
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

function Diana:CastSpell(spell,pos)
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
				if (spell == HK_R) then
					Control.KeyDown(HK_TCO)
				end
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				if (spell == HK_R) then
					Control.KeyUp(HK_TCO)
				end
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function Diana:CastQ(target)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) then
		local castpos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay, Q.Width, Q.Range,Q.Speed,myHero.pos,false, "circular")
			if (HitChance > 0) then
				self:CastSpell(HK_Q, castpos)
			end
		else
			castPos = target:GetPrediction(Q.Speed,Q.Delay)
			self:CastSpell(HK_Q, castPos)
		end
	end
end

function Diana:CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and (Game.Timer() - myHero:GetSpellData(_W).castTime > 5) then
		Control.CastSpell(HK_W)
	end
end

function Diana:CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target then
		Control.CastSpell(HK_E)
	end
end


function Diana:CastR(target)
	self:CastSpell(HK_R,target)
end

function Diana:GetRDMG()
	local rdamage = 125 + myHero:GetSpellData(_R).level*175 + 0.5*myHero.ap + 0.1*(myHero.maxHealth - (574.4 + 80*(myHero.levelData.lvl-1)))
	return rdamage
end

function Diana:GetRDMGPve()
	local rdamage = 1000 + 0.5*myHero.ap + 0.1*(myHero.maxHealth - (574.4 + 80*(myHero.levelData.lvl-1)))
	return rdamage
end

local FoodTable = {
	SRU_Baron = "",
	SRU_RiftHerald = "",
	SRU_Dragon_Water = "",
	SRU_Dragon_Fire = "",
	SRU_Dragon_Earth = "",
	SRU_Dragon_Air = "",
	SRU_Dragon_Elder = "",
}

function Diana:GetRTarget()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
	for i, target in pairs(heroeslist) do
		if GetDistance(myHero.pos, target.pos) <= R.Range then
			if self.Menu.Combo["RU"..target.charName] and self.Menu.Combo["RU"..target.charName]:Value() then
				return target
			end
		end
	end
end



function Diana:IsReady(spellSlot)
	
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Diana:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Diana:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Diana:Draw()
	if myHero.dead then return end 
	
	if self.Menu.DrawMenu.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, self.Menu.DrawMenu.QRangeC:Value())
	end
	if self.Menu.DrawMenu.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 3, self.Menu.DrawMenu.WRangeC:Value())
	end
	
	if self.Menu.DrawMenu.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 3, self.Menu.DrawMenu.ERangeC:Value())
	end
	
	if self.Menu.DrawMenu.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 3, self.Menu.DrawMenu.RRangeC:Value())
	end
	
	
	if self:CanCast(_R) then
		if self.Menu.DrawMenu.DrawOnEnemy:Value() then
			local offset = self.Menu.DrawMenu.TextOffset:Value()
			local fontsize = self.Menu.DrawMenu.TextSize:Value()
			local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or self:GetEnemyHeroes()
			for i, target in ipairs(heroeslist) do
				local RDamage = self:CanCast(_R) and getdmg("R",target,myHero) or 0
				local WDamage = self:CanCast(_W) and getdmg("W",target,myHero) or 0
				local QDamage = self:CanCast(_W) and (getdmg("Q",target,myHero) + getdmg("R",target,myHero)) or 0
				local ComboDamage = QDamage + WDamage + RDamage
				if self.Menu.DrawMenu.DrawOnEnemy:Value() then
					if ComboDamage < target.health then
						Draw.Text(math.floor(target.health - RDamage), fontsize, target.pos2D.x, target.pos2D.y+offset,self.Menu.DrawMenu.DrawColor:Value())
					else
						Draw.Text("KILLABLE!", fontsize, target.pos2D.x, target.pos2D.y+offset,self.Menu.DrawMenu.DrawColor:Value())
					end
				end
				if self.Menu.DrawMenu.DrawOnHPBar:Value() then
					local barPos = target.hpBar
					local percentHealthAfterDamage = math.max(0, target.health - ComboDamage) / target.maxHealth
					local xPosEnd = barPos.x + 103 * target.health/target.maxHealth
					local xPosStart = barPos.x + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y, xPosEnd, barPos.y, 10, self.Menu.DrawMenu.DrawColor:Value())
				end
			end
		end
	end
end
function OnLoad()
	Diana()
end