if myHero.charName ~= "Karthus" then return end
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

class "Karthus"
local Scriptname,Version,Author,LVersion = "TRUSt in my Karthus","v1.0","TRUS","7.17"

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
end
if FileExist(COMMON_PATH .. "DamageLib.lua") then
	require 'DamageLib'
end
function Karthus:__init()
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
function Karthus:LoadSpells()
	Q = {Range = 875, Width = 130, Delay = 0.8, Speed = math.huge}
	W = {Range = 1000, Width = 0, Delay = 0.25, Speed = math.huge}
	E = {Range = 425}
end

function Karthus:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyKarthus", name = Scriptname})
	
	--[[Farm]]
	self.Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
	self.Menu.Farm:MenuElement({id = "farmActive", name = "Farm key", key = string.byte("G")})
	if (_G.SDK) then
		self.Menu.Farm:MenuElement({id = "cpuFarm", name = "Prediction farm (CPU INTENSIVE)", value = true})	
	end
	self.Menu.Farm:MenuElement({id = "drawFarm", name = "Draw killable", value = true})
	self.Menu.Farm:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.Farm:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.Farm:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({type = MENU, id = "RMenu", name = "R announce Settings"})
	self.Menu.RMenu:MenuElement({id = "DrawOnEnemy", name = "Killable text on enemy", value = true})
	self.Menu.RMenu:MenuElement({id = "DrawOnMyself", name = "Killable text on my hero", value = true})
	self.Menu.RMenu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.RMenu:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
	self.Menu.RMenu:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. "" .. (TPred and " TPred" or "")})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Karthus:Tick()
	if myHero.dead then return end
	local combomodeactive = self.Menu.Combo.comboActive:Value()
	local farmactive = self.Menu.Farm.farmActive:Value()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	local harassactive = self.Menu.Harass.harassActive:Value()
	if combomodeactive then
		if self.Menu.Combo.comboUseQ:Value() then
			self:CastQ()
		end
		if self.Menu.Combo.comboUseW:Value() then
			self:CastW()
		end
		if self.Menu.Combo.comboUseQ:Value() then
			self:CastE()
		end
	elseif ((harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana) and self.Menu.Harass.harassUseQ:Value()) then
		self:CastQ()
	elseif farmactive then
		self:FindFarmPos()
	end
end

function Karthus:GetEnemyMinions(range)
	if (_G.SDK) then
		return _G.SDK.ObjectManager:GetEnemyMinions(range)
	end
	self.EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and (not range or myHero.pos:DistanceTo(minion.pos)<range) then
			table.insert(self.EnemyMinions, minion)
		end
	end
	return self.EnemyMinions
end
function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end
function Karthus:CheckMultiHit(spot)
	local count = 0
	local minionstable = self:GetEnemyMinions(1300)
	for i, minion in pairs(minionstable) do
		local Position = nil
		if self.Menu.Farm.cpuFarm:Value() then 
			Position, CastPosition = TPred:CalculateTargetPosition(minion, Q.Delay, 0, math.huge, myHero.pos)
		end
		if (not self.Menu.Farm.cpuFarm:Value() or (Position and GetDistance(Position,spot)<Q.Width)) and GetDistance(minion.pos,spot)<Q.Width then 
			count = count + 1
			if (getdmg("Q",minion,myHero)/2*0.8 > (_G.SDK.HealthPrediction:GetPrediction(minion, Q.Delay)) or minion.health) then
				return count,true
			end
		end
	end
	return count, false
end
function Karthus:FindHitSpot(curminion)
	for i = -Q.Width,Q.Width,10 do
		for a = -Q.Width,Q.Width,10 do
			local checkpos = Vector(curminion.pos.x + i, curminion.pos.y, curminion.pos.z + a)
			local count, killable = self:CheckMultiHit(checkpos)
			if count == 0 or killable then
				return checkpos
			end
		end
	end
	return false
end

function Karthus:FindFarmPos()
	local minionstable = self:GetEnemyMinions(1100)
	for i, minion in pairs(minionstable) do
		if (getdmg("Q",minion,myHero)*0.8 > (self.Menu.Farm.cpuFarm:Value() and _G.SDK.HealthPrediction:GetPrediction(minion, Q.Delay)>0 and _G.SDK.HealthPrediction:GetPrediction(minion, Q.Delay) or minion.health)) and myHero:GetSpellData(_Q).ammo == 2 then
			local hitspot = self:FindHitSpot(minion) 
			if hitspot then 
				self:CastSpell(HK_Q,hitspot)
			end
		end
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

function Karthus:CastSpell(spell,pos)
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


function Karthus:GetBuffs()
	self.T = {}
	for i = 0, myHero.buffCount do
		local Buff = myHero:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Karthus:HasDefile()
	for K, Buff in pairs(self:GetBuffs()) do
		if Buff.name:lower() == "karthusdefile" then
			return true
		end
	end
	return false
end

function Karthus:CastQ()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_Q) and myHero:GetSpellData(_Q).ammo == 2 then
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

function Karthus:CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_W) then
		local castpos
		if (TPred) then
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay, W.Width, W.Range,W.Speed,myHero.pos,false)
			if (HitChance > 0) then
				self:CastSpell(HK_W, castpos)
			end
		else
			castPos = target:GetPrediction(W.Speed,W.Delay)
			self:CastSpell(HK_W, castPos)
		end
	end
end

function Karthus:HeroesInRange(source,radius)
	local count = 0
	if not source then return end
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(source) < radius then 
			count = count + 1
		end
	end
	return count
end

--[[CastE]]
function Karthus:CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target and target.type == "AIHeroClient" and self:CanCast(_E) and myHero:GetSpellData(_E).toggleState == 1 then
		Control.CastSpell(HK_E)
	end
	if not target and myHero:GetSpellData(_E).toggleState == 2 then
		Control.CastSpell(HK_E)
	end
end

function Karthus:RCheck()
	
end

function Karthus:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Karthus:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Karthus:GetEnemyHeroes()
	if (_G.SDK) then
		return _G.SDK.ObjectManager:GetEnemyHeroes()
	else
		self.EnemyHeroes = {}
		for i = 1, Game.HeroCount() do
			local Hero = Game.Hero(i)
			if Hero.isEnemy then
				table.insert(self.EnemyHeroes, Hero)
			end
		end
		return self.EnemyHeroes
	end
end
function Karthus:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Karthus:Draw()
	if myHero.dead then return end 
	if self.Menu.Farm.drawFarm:Value() then
		local minionstable = self:GetEnemyMinions(1100)
		local offset = self.Menu.Farm.TextOffset:Value()
		local fontsize = self.Menu.Farm.TextSize:Value()
		for i, minion in pairs(minionstable) do
			if (getdmg("Q",minion,myHero)/2 > minion.health) then
				Draw.Text("2", fontsize, minion.pos2D.x, minion.pos2D.y+offset,self.Menu.Farm.DrawColor:Value())
			elseif (getdmg("Q",minion,myHero) > minion.health) then
				Draw.Text("1", fontsize, minion.pos2D.x, minion.pos2D.y+offset,self.Menu.Farm.DrawColor:Value())
			end
		end
	end
	if 	self:CanCast(_R) then
		local deadlist = "Can kill:"
		if self.Menu.RMenu.DrawOnEnemy:Value() or self.Menu.RMenu.DrawOnMyself:Value() then
			local offset = self.Menu.RMenu.TextOffset:Value()
			local fontsize = self.Menu.RMenu.TextSize:Value()
			for i, target in ipairs(self:GetEnemyHeroes()) do
				local RDamage = getdmg("R",target,myHero)*0.9
				if RDamage > target.health then
					if self.Menu.RMenu.DrawOnEnemy:Value() then
						Draw.Text("killable", fontsize, target.pos2D.x, target.pos2D.y+offset,self.Menu.RMenu.DrawColor:Value())
					end
					if self.Menu.RMenu.DrawOnMyself:Value() then
						deadlist = deadlist .. "\n" .. target.charName
					end
				end
			end
			if self.Menu.RMenu.DrawOnMyself:Value() and deadlist ~= "Can kill:" then
				Draw.Text(deadlist, fontsize, myHero.pos2D.x, myHero.pos2D.y+offset,self.Menu.RMenu.DrawColor:Value())
			end
		end
	end
end
function OnLoad()
Karthus()
end