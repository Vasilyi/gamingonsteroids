class "Annie"
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 0
local barYOffset = 0
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


function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	SetMovement(true)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Annie:CastSpell(spell,pos)
	local delay = 50
	local ticker = GetTickCount()
	if pos and castSpell.state == 0 and ticker > castSpell.casting then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
		if ticker - castSpell.tick < Game.Latency() then
			--block movement
			SetMovement(false)
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			DelayAction(LeftClick,0.02,{castSpell.mouse})
			castSpell.casting = ticker + 500
		end
	end
end



function Annie:__init()
	self:LoadSpells()
	self:LoadMenu()
	self.Spells = {
		["Fiddlesticks"] = {{Key = _W, Duration = 5, KeyName = "W" },{Key = _R,Duration = 1,KeyName = "R" }},
		["VelKoz"] = {{Key = _R, Duration = 1, KeyName = "R", Buff = "VelkozR" }},
		["Warwick"] = {{Key = _R, Duration = 1,KeyName = "R" , Buff = "warwickrsound"}},
		["MasterYi"] = {{Key = _W, Duration = 4,KeyName = "W", Buff = "Meditate" }},
		["Lux"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Janna"] = {{Key = _R, Duration = 3,KeyName = "R",Buff = "ReapTheWhirlwind" }},
		["Jhin"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Xerath"] = {{Key = _R, Duration = 3,KeyName = "R", SpellName = "XerathRMissileWrapper" }},
		["Karthus"] = {{Key = _R, Duration = 3,KeyName = "R", Buff = "karthusfallenonecastsound" }},
		["Ezreal"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Galio"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "GalioIdolOfDurand" }},
		["Caitlyn"] = {{Key = _R, Duration = 2,KeyName = "R" , Buff = "CaitlynAceintheHole"}},
		["Malzahar"] = {{Key = _R, Duration = 2,KeyName = "R" }},
		["MissFortune"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "missfortunebulletsound" }},
		["Nunu"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "AbsoluteZero" }},
		["TwistedFate"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "Destiny" }},
		["Shen"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "shenstandunitedlock" }},
	}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
			table.insert(self.Allies,hero)
		else
			table.insert(self.Enemies,hero)
		end	
	end	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Annie:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, radius = 290 }
end

function Annie:LoadMenu()
	
	--------- Menu Principal --------------------------------------------------------------
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "The Ripper Series"})
	--------- Annie --------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Ripper", name = "Annie The Ripper"})
	--------- Menu Principal --------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Ripper.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.Combo:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Ripper.Combo:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Ripper.Combo:MenuElement({id = "R", name = "Use R", value = true})
	self.Menu.Ripper.Combo:MenuElement({id = "RS", name = "R just if have stun", value = true,})
	self.Menu.Ripper.Combo:MenuElement({id = "ER", name = "Min enemies to R", value = 2, min = 1, max = 5})
	self.Menu.Ripper.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.Ripper.Combo:MenuElement({id = "burstActive", name = "Burst key", key = string.byte("G")})
	
	--------- Menu LastHit --------------------------------------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.Ripper.LastHit:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.LastHit:MenuElement({id = "SS", name = "Save Stun", value = true})
	self.Menu.Ripper.LastHit:MenuElement({id = "Mana", name = "Min mana to LastHit (%)", value = 40, min = 0, max = 100})
	--------- Menu LaneClear ------------------------------------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Ripper.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Ripper.LaneClear:MenuElement({id = "HW", name = "Min minions hit by W", value = 4, min = 1, max = 7})
	self.Menu.Ripper.LaneClear:MenuElement({id = "SS", name = "Save Stun", value = true})
	self.Menu.Ripper.LaneClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	--------- Menu JungleClear ------------------------------------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Ripper.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Ripper.JungleClear:MenuElement({id = "SS", name = "Save Stun", value = true})
	self.Menu.Ripper.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	--------- Menu Harass ---------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Ripper.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.Harass:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Ripper.Harass:MenuElement({id = "SS", name = "Save Stun", value = false})
	self.Menu.Ripper.Harass:MenuElement({id = "Mana", name = "Min mana to Harass (%)", value = 40, min = 0, max = 100})
	--------- Menu Flee ----------------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "Flee", name = "Flee"})
	self.Menu.Ripper.Flee:MenuElement({id ="Q", name = "Use Q if have stun", value = true})
	self.Menu.Ripper.Flee:MenuElement({id ="W", name = "Use W to stack stun", value = true})
	self.Menu.Ripper.Flee:MenuElement({id ="E", name = "Use E to stack stun", value = true})
	--------- Menu KS -----------------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "KS", name = "Killsteal"})
	self.Menu.Ripper.KS:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Ripper.KS:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Ripper.KS:MenuElement({id = "R", name = "Use R", value = true})	
	--------- Menu Misc -----------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "Misc", name = "Misc"})
	self.Menu.Ripper.Misc:MenuElement({id = "AI", name = "Auto Q interrupter", value = true})
	self.Menu.Ripper.Misc:MenuElement({id = "ES", name = "Auto E passive stack", value = true})
	self.Menu.Ripper.Misc:MenuElement({id = "Mana", name = "Min mana to auto E (%)", value = 40, min = 0, max = 100})
	--------- Menu Drawings --------------------------------------------------------------------
	self.Menu.Ripper:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
	self.Menu.Ripper.Drawings:MenuElement({id = "Q", name = "Draw Q range", value = true})
	self.Menu.Ripper.Drawings:MenuElement({id = "W", name = "Draw W range", value = true})
	self.Menu.Ripper.Drawings:MenuElement({id = "R", name = "Draw R range", value = true})
	self.Menu.Ripper.Drawings:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Ripper.Drawings:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
end

function Annie:Tick()
	local Combo = self.Menu.Ripper.Combo.comboActive:Value()
	local Burst = self.Menu.Ripper.Combo.burstActive:Value()
	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local Harass = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") or (_G.EOWLoaded and EOW:Mode() == "Harass")
	local Flee = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE]) or (_G.GOS and _G.GOS:GetMode() == "Flee") or (_G.EOWLoaded and EOW:Mode() == "Flee")
	if Burst then
		self:Burst()
	elseif Combo then
		self:Combo()
	elseif Clear then
		self:LaneClear()
		self:JungleClear()
	elseif LastHit then
		self:LastQ()
	elseif Harass then
		self:Harass()
	elseif Flee then
		self:Flee()
	end
	self:Misc()
	--self:AutoPilot()
	self:KS()
end

function Annie:GetValidEnemy(range)
	for i = 1,Game.HeroCount() do
		local enemy = Game.Hero(i)
		if enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 1200 then
			return true
		end
	end
	return false
end

function Annie:CountEnemyMinions(range)
	local minionsCount = 0
	for i = 1,Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.range then
			minionsCount = minionsCount + 1
		end
	end
	return minionsCount
end

function Annie:IsValidTarget(unit,range)
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 300000
end

function Annie:StunIsUp()
	if myHero.hudAmmo == myHero.hudMaxAmmo then
		return true
	end
	return false
end

function Annie:TibbersAlive()
	if myHero:GetSpellData(_R).toggleState == 2 then
		return true
	end
	return false
end

function Annie:TibbersCanBeCast()
	if myHero:GetSpellData(_R).toggleState == 1 and self:Ready(_R) then
		return true
	end
	return false
end

function Annie:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end
function Annie:EnemiesAround(pos, range)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local e = Game.Hero(i)
		if e and e.team ~= myHero.team and not e.dead and e.pos:DistanceTo(pos, e.pos) <= 290 then
			Count = Count + 1
		end
	end
	return Count
end

function Annie:Burst()
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	local targetR = (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	if not targetR then return end 
	if targetR and self:Ready(_R) and not self:TibbersAlive() then
		local predpos = targetR:GetPrediction(R.speed,R.delay)
		if predpos and myHero.pos:DistanceTo(predpos) > 600 then
			predpos = myHero.pos:Extended(predpos,600)
		end
		if predpos then
			self:CastSpell(HK_R,predpos)
		end
		
	end
	if target and myHero.pos:DistanceTo(target.pos) < 600 and self:Ready(_W) then
		self:CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
		return
	end
	if target and self:Ready(_Q) then
		self:CastSpell(HK_Q,target)
		return
	end
	
	
	if target and myHero.mana > 100 and myHero.pos:DistanceTo(target.pos) < 600 and self:Ready(_E) and not self:StunIsUp() then
		Control.CastSpell(HK_E)
		return
	end
	
end



function Annie:Combo()
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	local targetR = (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	if not targetR then return end 
	if targetR and self.Menu.Ripper.Combo.R:Value() and self:Ready(_R) and not self:TibbersAlive() then
		local predpos = targetR:GetPrediction(R.speed,R.delay)
		if predpos and myHero.pos:DistanceTo(predpos) > 600 then
			predpos = myHero.pos:Extended(predpos,600)
		end
		if predpos and self:EnemiesAround(predpos, 250) >= self.Menu.Ripper.Combo.ER:Value() then
			if (not self.Menu.Ripper.Combo.RS:Value() 
			or self:StunIsUp()) and ((self:GetDamage(targetR,true,true,true,true) > targetR.health and self:GetDamage(targetR,true,true,false,true) < targetR.health) or (self:StunIsUp() and self:GetDamage(targetR,true,true,true,false) > targetR.health and self:GetDamage(targetR,true,true,false,true) < targetR.health)) then
				self:CastSpell(HK_R,predpos)
			end
		end
	end
	if target and myHero.pos:DistanceTo(target.pos) < 600 and self.Menu.Ripper.Combo.W:Value() and self:Ready(_W) then
		self:CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
		return
	end
	if target and self.Menu.Ripper.Combo.Q:Value() and self:Ready(_Q) then
		self:CastSpell(HK_Q,target)
		return
	end
	
	
	if target and myHero.mana > 100 and myHero.pos:DistanceTo(target.pos) < 600 and self.Menu.Ripper.Combo.E:Value() and self:Ready(_E) and not self:StunIsUp() then
		Control.CastSpell(HK_E)
		return
	end
	
	
end

function Annie:LastQ()
	if self.Menu.Ripper.LastHit.SS:Value() and self:StunIsUp() then return end
	if self.Menu.Ripper.LastHit.Q:Value() == false then return end
	local level = myHero:GetSpellData(_Q).level
	if level == nil or level == 0 then return end
	if self:GetValidMinion(625) == false then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		local Qdamage = (({80, 115, 150, 185, 220})[level] + 0.8 * myHero.ap)
		if self:IsValidTarget(minion,625) and myHero.pos:DistanceTo(minion.pos) < 625 and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LastHit.Mana:Value() / 100 ) and minion.isEnemy then
			if Qdamage >= self:HpPred(minion, 0.5) and self:Ready(_Q) then
				self:CastSpell(HK_Q,minion.pos)
			end
		end
	end
end

function Annie:GetValidMinion(range)
	for i = 1,Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 625 then
			return true
		end
	end
	return false
end

function Annie:HasCC(unit)	
	for i = 0, unit.buffCount do
		local buff = myHero:GetBuff(i);
		if buff.count > 0 then
			if ((buff.type == 5)
			or (buff.type == 8)
			or (buff.type == 9)
			or (buff.type == 10)
			or (buff.type == 11)
			or (buff.type == 21)
			or (buff.type == 22)
			or (buff.type == 24)
			or (buff.type == 28)
			or (buff.type == 29)
			or (buff.type == 31)) then
				return true
			end
		end
	end
	return false
end

function Annie:HpPred(unit, delay)
	if _G.GOS then
		hp = GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Annie:MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 175 then
			Count = Count + 1
		end
	end
	return Count
end

function Annie:LaneClear()
	if self.Menu.Ripper.LaneClear.SS:Value() and self:StunIsUp() then return end
	if self:GetValidMinion(Q.range) == false then return end
	local level = myHero:GetSpellData(_Q).level
	if level == nil or level == 0 then return end
	if self:GetValidMinion(625) == false then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team == 200 then
			local Qdamage = (({80, 115, 150, 185, 220})[level] + 0.8 * myHero.ap)
			if self:IsValidTarget(minion,625) and myHero.pos:DistanceTo(minion.pos) < 625 and self.Menu.Ripper.LaneClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and minion.isEnemy then
				if Qdamage >= self:HpPred(minion, 0.5) and self:Ready(_Q) then
					self:CastSpell(HK_Q,minion.pos)
				end
			end
			if self:IsValidTarget(minion,500) and self:Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.Ripper.LaneClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and minion.isEnemy then
				if self:MinionsAround(minion.pos, 175, 200) >= self.Menu.Ripper.LaneClear.HW:Value() then
					self:CastSpell(HK_W,minion.pos)
				end
			end
		end
	end
end

function Annie:JungleClear()
	if self.Menu.Ripper.JungleClear.SS:Value() and self:StunIsUp() then return end
	if self:GetValidMinion(Q.range) == false then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team == 300 then
			if self:IsValidTarget(minion,625) and myHero.pos:DistanceTo(minion.pos) < 625 and self.Menu.Ripper.JungleClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and self:Ready(_Q) then
				self:CastSpell(HK_Q,minion.pos)
				break
			end
			if self:IsValidTarget(minion,600) and myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.Ripper.JungleClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and self:Ready(_W) then
				self:CastSpell(HK_W,minion.pos)
				break
			end
		end
	end
end

function Annie:GetValidAlly(range)
	for i = 1,Game.HeroCount() do
		local ally = Game.Hero(i)
		if ally.team == myHero.team and ally.valid and ally.pos:DistanceTo(myHero.pos) > 1 then
			return true
		end
	end
	return false
end

function Annie:Harass()
	if self.Menu.Ripper.Harass.SS:Value() and self:StunIsUp() then return end
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	if self:GetValidEnemy(625) == false then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	if self:IsValidTarget(target,625) and myHero.pos:DistanceTo(target.pos) < 625 and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Harass.Mana:Value() / 100) and self.Menu.Ripper.Harass.Q:Value() and self:Ready(_Q) then
		self:CastSpell(HK_Q,target)
	end
	if self:IsValidTarget(target,600) and myHero.pos:DistanceTo(target.pos) < 600 and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Harass.Mana:Value() / 100) and self.Menu.Ripper.Harass.W:Value() and self:Ready(_W) then
		self:CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
	end
end

function Annie:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Annie:Flee()
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	if self:GetValidEnemy(625) == false then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	
	if self:IsValidTarget(target,625) and myHero.pos:DistanceTo(target.pos) < 625 and self:StunIsUp() and self.Menu.Ripper.Flee.Q:Value() and self:Ready(_Q) then
		self:CastSpell(HK_Q,target)
	end
	if self:IsValidTarget(target,600) and myHero.pos:DistanceTo(target.pos) < 600 and not self:StunIsUp() and self.Menu.Ripper.Flee.W:Value() and self:Ready(_W) then
		self:CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
	end
	if self:IsValidTarget(target,725) and myHero.pos:DistanceTo(target.pos) < 725 and not self:StunIsUp() and self.Menu.Ripper.Flee.E:Value() and self:Ready(_E) then
		self:CastSpell(HK_E)
	end
end

function Annie:GetAllyHeroes()
	local _AllyHeroes
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function Annie:KS()
	if self:GetValidEnemy(625) == false then return end
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	
	if self:IsValidTarget(target,625) and myHero.pos:DistanceTo(target.pos) < 625 and self.Menu.Ripper.KS.Q:Value() and self:Ready(_Q) then
		local level = myHero:GetSpellData(_Q).level
		local Qdamage = CalcMagicalDamage(myHero, target, (({80, 115, 150, 185, 220})[level] + 0.8 * myHero.ap))
		if Qdamage >= self:HpPred(target,1) + target.hpRegen * 2 then
			self:CastSpell(HK_Q,target)
		end
	end
	if self:IsValidTarget(target,600) and myHero.pos:DistanceTo(target.pos) < 600 and self.Menu.Ripper.KS.W:Value() and self:Ready(_W) then
		local level = myHero:GetSpellData(_W).level
		local Wdamage = CalcMagicalDamage(myHero, target, (({70, 115, 160, 205, 250})[level] + 0.85 * myHero.ap))
		if 	Wdamage >= self:HpPred(target,1) + target.hpRegen * 2 then
			self:CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
		end
	end
	if self:IsValidTarget(target,600) and myHero.pos:DistanceTo(target.pos) < 600 and self.Menu.Ripper.KS.R:Value() and self:TibbersCanBeCast() then
		local level = myHero:GetSpellData(_R).level
		local Rdamage = CalcMagicalDamage(myHero, target, (({150, 275, 400})[level] + 0.65 * myHero.ap))
		if 	Rdamage >= self:HpPred(target,1) + target.hpRegen * 2 and not self:TibbersAlive() then
			self:CastSpell(HK_R,target:GetPrediction(R.speed,R.delay))
		end
	end
end

function Annie:IsChannelling(unit)
	if not self.Spells[unit.charName] then return false end
	local result = false
	for _, spell in pairs(self.Spells[unit.charName]) do
		if unit:GetSpellData(spell.Key).level > 0 and (unit:GetSpellData(spell.Key).name == spell.SpellName or unit:GetSpellData(spell.Key).currentCd > unit:GetSpellData(spell.Key).cd - spell.Duration or (spell.Buff and self:GotBuff(unit,spell.Buff) > 0)) then
			result = true
			break
		end
	end
	return result
end

function Annie:Misc()
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	if self:Ready(_Q) and self:IsValidTarget(target,625) and self:StunIsUp() and self:IsChannelling(enemy) and self.Menu.Ripper.Misc.AI:Value() then
		self:CastSpell(HK_Q,target)
	end
	if self:Ready(_E) and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Misc.Mana:Value() / 100) and self.Menu.Ripper.Misc.ES:Value() and not self:StunIsUp() then
		self:CastSpell(HK_E)
	end
end

function Annie:AutoPilot()
	if self:TibbersAlive() == false then return end
	if self:GetValidEnemy(650) == false then return end
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(650, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(650,"AP")) or ( _G.EOWLoaded and EOW:GetTarget())
	if self:IsValidTarget(target,650) then
		DelayAction(function()
			self:CastSpell(HK_R,target)
		end, 8)
	end
end

function Annie:Ready(spellSlot)
	return self:CheckMana(spellSlot) and myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Annie:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Annie:GetDamage(target, UseQ, UseW, UseR, CloseRange)
	local currentrange = myHero.pos:DistanceTo(target.pos)
	local QDamage = (UseQ and (not CloseRange or currentrange < 625) and self:Ready(_Q) and getdmg("Q",target,myHero) or 0)
	local WDamage = (UseW and self:Ready(_W) and (not CloseRange or currentrange < 600) and getdmg("W",target,myHero) or 0)
	local RDamage = ((UseR and self:Ready(_R) and myHero:GetSpellData(_R).toggleState ~= 2 and getdmg("R",target,myHero)) or 0)
	return (QDamage + WDamage + RDamage)
end

function Annie:Draw()
	if myHero.dead then return end
	
	for i, hero in pairs(self:GetEnemyHeroes()) do
		local barPos = hero.hpBar
		if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
			--local barYOffset = self.Menu.Draw.HPBarOffset:Value()
			local damage = self:GetDamage(hero,true,true,true,false)
			if damage > hero.health then
				Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
			else
				local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
				local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
				local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
				Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(0xFF00FF00))
			end
		end
	end	
	
	
	if self.Menu.Ripper.Drawings.Q:Value() then Draw.Circle(myHero.pos, Q.range, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value())
	end
	if self.Menu.Ripper.Drawings.W:Value() then Draw.Circle(myHero.pos, W.range, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value())
	end
	if self.Menu.Ripper.Drawings.R:Value() then Draw.Circle(myHero.pos, R.range, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value())
	end
end
Annie()