local Scriptname,Version,Author,LVersion = "TRUSt in my Viktor","v0.1","TRUS","7.4"

class "Viktor"

function Viktor:__init()
	if myHero.charName ~= "Viktor" then return end
	PrintChat(Scriptname.." "..Version.." - Loaded....")
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("WndMsg", function() self:OnWndMsg() end)
	self:ProcessSpellsLoad()
	
end

local InterruptSpellsList = {
	["Katarina"] = {spell = _R},
	["Galio"] = { spell = _R},
	["FiddleSticks"] = { spell = _R, spell2 = _W},
	["Nunu"] = { spell = _R},
	["Shen"] = { spell = _R},
	["Urgot"] = { spell = _R},
	["Malzahar"] = {spell = _R},
	["Karthus"] = { spell = _R},
	["Pantheon"] = { spell = _R, suppresed = true},
	["Varus"] = { spell = _Q, suppresed = true},
	["Caitlyn"] = { spell = _R, suppresed = true},
	["MissFortune"] = { spell = _R},
	["Warwick"] = { spell = _R, wait = true}
}

local spellslist = {_Q,_W,_E,_R,SUMMONER_1,SUMMONER_2}
lastcallback = {}


function ReturnState(champion,spell)
	lastcallback[champion.charName..spell.name] = false
end

function Viktor:OnProcessSpell(champion,spell)
	if InterruptSpellsList[champion.charName] then
		for i, spell2 in pairs(InterruptSpellsList[champion.charName]) do
			if spell == spell2 then
				self:AutoInterrupt(champion)
			end
		end
	end
end


function Viktor:ProcessSpellsLoad()
	for i, spell in pairs(spellslist) do
		local tempname = myHero.charName
		lastcallback[tempname..myHero:GetSpellData(spell).name] = false
	end
end

function Viktor:ProcessSpellCallback()
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.valid then
			for i, spell in pairs(spellslist) do
				local tempname = Hero.charName
				local spelldata = Hero:GetSpellData(spell)
				if spelldata.castTime > Game.Timer() and 
				not lastcallback[tempname..spelldata.name] then
					self:OnProcessSpell(Hero,spell)
					lastcallback[tempname..spelldata.name] = true
					DelayAction(ReturnState,spelldata.currentCd,{Hero,spelldata})
				end		
			end
		end
	end
end


function Viktor:Tick()
	self:ProcessSpellCallback()
	if 	self.Menu.Flee.FleeActive:Value() then
		self:Flee()
	end
	
	if self.Menu.Harass.HarassActive:Value() then
		self:Harass()
	end
	
	if self.Menu.Combo.comboActive:Value() then
		self:Combo()
	end
	
	
	if self.Menu.RMenu.RSolo.forceR:Value() then
		self:RSolo()
	end
	
	
	if self.Menu.WaveClear.waveActive:Value() then
		self:WaveClear(false)
	end
	
	if self.Menu.WaveClear.jungleActive:Value() then
		self:WaveClear(true)
	end
end

function Viktor:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function Viktor:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Viktor:ClosestEnemy()
	local selected
	local selected2
	local value
	local value2
	for i, _gameHero in ipairs(self:GetEnemyHeroes()) do
		local distance = GetDistance(_gameHero.pos)
		if _gameHero:IsValidTarget(Q.Range) and (not selected or distance < value) then
			selected = _gameHero
			value = distance
		end
		
	end
	
	
	for i, _minion in ipairs(self:GetEnemyMinions()) do
		local distance = GetDistance(_minion.pos)
		if _minion:IsValidTarget(Q.Range) and (not selected2 or distance < value2) then
			selected2 = _minion
			value2 = distance
		end
		
	end
	if value and value2 then
		if value > value2 then 
			return selected2
		else
			return selected
		end
	elseif value and not value2 then
		return selected
	elseif value2 and not value then
		return selected2
	end
end

function Viktor:Flee()
	if self:CanCast(_Q) and (self:HasBuff(myHero,"viktorqaug") or self:HasBuff(myHero,"viktorqeaug") or self:HasBuff(myHero,"viktorqwaug") or self:HasBuff(myHero,"viktorqweaug")) then 
		
		local closestenemy = self:ClosestEnemy()
		if closestenemy and closestenemy.valid then
			self:CastSpell(HK_Q,closestenemy.pos)
		end
	end
end
function Viktor:RSolo()
	local target = TargetSelector()
	if self.Menu.RMenu.RSolo["RU"..target.charName]:Value() then
		self:CastSpell(HK_R,target.pos)
	end
end

function Viktor:UltControl(target)
	if myHero:GetSpellData(_R).name == "viktorchaosstormguide" then
		self:CastSpell(HK_R,target.pos)
	end
end
function Viktor:CalcMagicalDamage(source, target, amount)
	local mr = target.magicResist
	local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)
	
	if mr < 0 then
		value = 2 - 100 / (100 - mr)
	elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
		value = 1
	end
	
	return math.max(0, math.floor(value * amount))
end
function Viktor:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if GetDistance(unit)>range then return false end 
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	return true 
end

function Viktor:GetSpellTarget(range)
	local selected
	
	for i, _gameHero in ipairs(self:GetEnemyHeroes()) do
		local health = _gameHero.health * (100 / self:CalcMagicalDamage(myHero,_gameHero, 100))
		if self:IsValidTarget(_gameHero,range) and (not selected or health < value) then
			selected = _gameHero
			value = health
		end
		
	end
	return selected
end

function Viktor:GetETargets()
	self.innertargets = {}
	self.outertargets = {}
	for i, _gameHero in ipairs(self:GetEnemyHeroes()) do
		if self:IsValidTarget(_gameHero,E.Range) then
			table.insert(self.innertargets, _gameHero)
		elseif self:IsValidTarget(_gameHero,E.MaxRange) then
			table.insert(self.outertargets, _gameHero)
		end
	end
	return self.innertargets,self.outertargets
end
drawpos1 = {0,0,0}
drawpos2 = {0,0,0}
function Viktor:CastE(target)
	local pos1,pos2 = self:CalcEPos(target)
	
	if pos1 and pos2 then 
		drawpos1 = pos1
		drawpos2 = pos2
		--	PrintChat("both pos")
		self:CastESpell(pos1, pos2)
	end
end


function Viktor:CalcEPos(target)
	
	--build tables with targets
	local innertargets, outertargets = self:GetETargets()
	local innerminions = self:GetEnemyMinions(E.Range)
	local outerminions = self:GetEnemyMinions(E.MaxRange)
	local pos1, pos2, sourcepos, startPoint, predictedminion
	local closetopredict = {}
	local firsttargetminion = {}
	-- check if main target in close range
	local inRange = self:IsValidTarget(target,E.Range)
	local startradius = 150
	local closetopredictionhero
	local espeed = E.Speed * 0.90
	local predictmaintarget = target:GetPrediction(espeed, E.Delay)
	if inRange then 
		--prediction in range
		if GetDistance(predictmaintarget) < E.Range then 
			pos1 = predictmaintarget
		else
			pos1 = target.pos
		end
		
		-- Set new sourcePosition
		sourcepos = pos1;
		--get next target
		if #outertargets > 0 then
			for i, outtarg in ipairs(outertargets) do
				-- should be new predict source
				local newpred = outtarg:GetPrediction(espeed, E.Delay)
				if GetDistance(newpred,predictmaintarget) < E.length then
					
					table.insert(closetopredict, outtarg)
				end
			end
		end
		if #innertargets > 0 then
			for i, inntarg in ipairs(innertargets) do
				-- should be new predict source
				local newpred = inntarg:GetPrediction(espeed, E.Delay)
				if GetDistance(newpred,predictmaintarget) < E.length then
					table.insert(closetopredict, inntarg)
				end
			end
		end 
		
		
		if #closetopredict > 0 then
			for i, closetopredicthero in ipairs(closetopredict) do
				local health = closetopredicthero.health * (100 / self:CalcMagicalDamage(myHero,closetopredicthero, 100))
				if (not closetopredictionhero or health < value) and closetopredicthero ~= target then
					closetopredictionhero = closetopredicthero
					value = health
				end
				
			end
		end
		if closetopredictionhero then 
			pos2 = closetopredictionhero:GetPrediction(espeed, E.Delay)
		else
			pos2 = pos1
		end
		
		return pos1,pos2
	else
		-- Get initial start point at the border of cast radius
		startPoint = myHero.pos:Extended(predictmaintarget,E.Range)
		-- potential start target from position
		if #innertargets > 0 then
			for i, innertarg in ipairs(innertargets) do
				-- should be new predict source
				local newpred = innertarg:GetPrediction(espeed, E.Delay)
				if GetDistance(newpred,predictmaintarget) < E.length and GetDistance(newpred)<E.Range then
					table.insert(closetopredict, innertarg)
				end
			end
			
			
			for i, innertarg in ipairs(outertargets) do
				-- should be new predict source
				local newpred = innertarg:GetPrediction(espeed, E.Delay)
				if GetDistance(newpred,predictmaintarget) < E.length and GetDistance(newpred)<E.Range then
					table.insert(closetopredict, innertarg)
				end
			end
			
			
			if #closetopredict > 0 then
				for i, closetopredicthero in ipairs(closetopredict) do
					local health = closetopredicthero.health * (100 / self:CalcMagicalDamage(myHero,closetopredicthero, 100))
					if self:IsValidTarget(closetopredicthero,range) and (not closetopredictionhero or health < value) and closetopredicthero ~= target then
						closetopredictionhero = closetopredicthero
						value = health
					end
					
				end
				
			end
			if closetopredictionhero then 
				pos2 = closetopredictionhero:GetPrediction(espeed, E.Delay)
			else
				return startPoint,predictmaintarget
			end
			
		else
			-- if #innerminions > 0 then
			-- for i, closetopredictminion in ipairs(innerminions) do
			-- if GetDistance(closetopredictminion,predictmaintarget) < E.length then
			-- predictedminion = closetopredictminion
			-- end
			
			-- end
			-- end
			
			
			-- end
			-- if predictedminion then 
			-- pos2 = predictedminion.pos
			-- else
			-- return startPoint,predictmaintarget
			-- end
			return startPoint,predictmaintarget
		end
	end
end

function Viktor:isFacing(source)
	local sourceVector = Vector(source.posTo.x, source.posTo.z)
	local sourcePos = Vector(source.pos.x, source.pos.z)
	sourceVector = (sourceVector-sourcePos):Normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(source)))
	return GetDistance(sourceVector) <= (90000)
end


function Viktor:GetCircularAOECastPosition(unit, delay, radius, range, speed)
	local CastPosition = unit:GetPrediction(speed,delay)
	local points = {}
	
	table.insert(points, CastPosition)
	
	for i, target in ipairs(GetEnemyHeroes()) do
		if target.networkID ~= unit.networkID and self:IsValidTarget(target, range * 1.5) then
			local Position = target:GetPrediction(speed,delay)
			if GetDistance(Position) < (range + radius) then
				table.insert(points, Position)
			end
		end
	end
	
	if #points > 1 then
		--calculate MEC pos
		
		return CastPosition
	end
end
function VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

function Viktor:PredictCastMinionE(tohit, jungle)
	local bestendpos, beststartpos
	local minionCount = 0
	local minimalhit = tohit
	local oldcount = 0 
	local allminions = self:GetEnemyMinions(E.MaxRange)
	local innerminions = self:GetEnemyMinions(E.Range)
	local startpos,endpos
	local pointSegment, pointLine, isOnSegment
	local jungle = jungle
	for i, minion in ipairs(innerminions) do
		if (jungle == true and minion.team == 300) or (jungle == false and minion.team ~= 300) then
			for i2, minion2 in ipairs(allminions) do
				if (jungle == true and minion.team == 300) or (jungle == false and minion.team ~= 300) then
					if minion ~= minion2 and GetDistance(minion.pos,minion2.pos)<E.length then 
						local count = 0
						for i3, minion3 in ipairs(allminions) do
							local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(minion.pos, minion2.pos, minion3.pos)
							if isOnSegment then 
								count = count+1
							end
						end
						if oldcount <= count then
							oldcount = count
							startpos = minion.pos
							endpos = minion2.pos
						end
					end
				end
			end
		end
	end
	if oldcount >= minimalhit then
		self:CastESpell(startpos, endpos)
	end
end
function Viktor:WaveClear(jungle)
	local UseQ = self.Menu.WaveClear.waveUseQ:Value()
	local UseE = self.Menu.WaveClear.waveUseE:Value()
	local MinsAmount = self.Menu.WaveClear.waveNumE:Value()
	local WaveClearMinMana = self.Menu.WaveClear.waveMana:Value()
	if myHero.maxMana * WaveClearMinMana * 0.01 < myHero.mana then
		local QMinions = self:GetEnemyMinions(Q.Range)
		if UseQ and self:CanCast(_Q) then
			local QTarget = self:GetQTarget(jungle)
			if #QTarget > 0 then
				self:CastSpell(HK_Q,QTarget[1].pos)
			end
		end
		if UseE and self:CanCast(_E) then
			self:PredictCastMinionE(MinsAmount,jungle)
		end
	end
end


function Viktor:Combo()
	local UseQ = self.Menu.Combo.comboUseQ:Value()
	local UseW = self.Menu.Combo.comboUseW:Value()
	local UseE = self.Menu.Combo.comboUseE:Value()
	local UseR = self.Menu.Combo.comboUseR:Value()
	local DontAAPassive = self.Menu.Combo.qAuto:Value()
	
	
	if UseQ and self:CanCast(_Q) then
		local qTarget = self:GetSpellTarget(Q.Range)
		if qTarget and qTarget.valid then
			self:CastSpell(HK_Q,qTarget.pos)
		end
	end
	if UseE and self:CanCast(_E) then
		local eTarget = self:GetSpellTarget(DistanceForE)
		if eTarget and eTarget.valid then
			self:CastE(eTarget)
		end
	end
	if UseW and self:CanCast(_W) then
		local wTarget = self:GetSpellTarget(W.Range)
		if wTarget then
			local posw = wTarget:GetPrediction(W.Speed, W.Delay)
			if posw ~= nil then
				if self:isFacing(wTarget,myHero) then
					pw = Vector(posw) - 150 * (Vector(posw) - Vector(myHero)):Normalized()
				else
					pw = Vector(posw) + 150 * (Vector(posw) - Vector(myHero)):Normalized()
				end
				self:CastSpell(HK_W,pw)
			end
		end
	end
	
	
	if UseR and self:CanCast(_R) then
		local Rtargets = self.Menu.RMenu.hitR:Value()
		local rTarget = self:GetSpellTarget(R.Range)
		if self:IsValidTarget(rTarget) then
			local predictpos = rTarget:GetPrediction(R.Speed,R.Delay)
			--local predictpos, amounts = self:GetCircularAOECastPosition(unit, delay, radius, range, speed)
			local amount = self:EnemyInRange(rTarget, R.Radius)
			
			if Rtargets <= amount and myHero:GetSpellData(_R).name ~= "ViktorChaosStormGuide" then
				self:CastSpell(HK_R,predictpos)
			end
		end
	end
end

function Viktor:EnemyInRange(source,radius)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if GetDistance(target,source.pos) < radius then 
			count = count + 1
		end
	end
	return count
end

function Viktor:Harass()
	local UseQ = self.Menu.Harass.harassUseQ:Value()
	local UseE = self.Menu.Harass.harassUseE:Value()
	local DistanceForE = self.Menu.Harass.eDistance:Value()
	local HarassMinMana = self.Menu.Harass.harassMana:Value()
	
	if myHero.maxMana * HarassMinMana * 0.01 < myHero.mana then
		if UseQ and self:CanCast(_Q) then
			local qTarget = self:GetSpellTarget(Q.Range)
			if qTarget and qTarget.valid then
				self:CastSpell(HK_Q,qTarget.pos)
			end
		end
		if UseE and self:CanCast(_E) then
			local eTarget = self:GetSpellTarget(DistanceForE)
			if eTarget and eTarget.valid then
				self:CastE(eTarget)
			end
		end
	end
end

function Viktor:Draw()
	if myHero.dead then return end
	if self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, self.Menu.Draw.QRangeC:Value())
	end
	if self.Menu.Draw.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 3, self.Menu.Draw.WRangeC:Value())
	end
	if self.Menu.Draw.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 3, self.Menu.Draw.ERangeC:Value())
	end
	if self.Menu.Draw.DrawEMax:Value() then
		Draw.Circle(myHero.pos, E.MaxRange, 3, self.Menu.Draw.ERangeC:Value())
	end
	if self.Menu.Draw.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 3, self.Menu.Draw.RRangeC:Value())
	end
	if drawpos1 and drawpos2 then 
		Draw.Circle(drawpos1, 80, 3, self.Menu.Draw.RRangeC:Value())
		Draw.Circle(drawpos2, 80, 3, self.Menu.Draw.RRangeC:Value())
	end
	
end

function Viktor:Stunned(enemy)
	for i = 0, enemy.buffCount do
		local buff = enemy:GetBuff(i);
		if (buff.type == 5 or buff.type == 11 or buff.type == 24) and buff.duration > 0.5 then
			return true
		end
	end
	return false
end

function Viktor:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Viktor:GetImmobileTarget()
	local GetEnemyHeroes = self:GetEnemyHeroes()
	local Target = nil
	for i = 1, #GetEnemyHeroes do
		local Enemy = GetEnemyHeroes[i]
		if Enemy and self:Stunned(Enemy) then
			return Enemy
		end
	end
	return false
end

function Viktor:OnWndMsg(msg,key)
	
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}


function EnableMovement()
	--unblock movement
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	castSpell.state = 0
	DelayAction(EnableMovement,0.05)
end

function SecondPosE(pos)
	Control.SetCursorPos(pos)
	Control.KeyUp(HK_E)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
end


function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end



function Viktor:CastESpell(pos1, pos2)
	local delay = self.Menu.delay:Value()
	local ticker = GetTickCount()
	if castSpell.state == 0 then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			--block movement
			Control.SetCursorPos(pos1)
			Control.KeyDown(HK_E)
			if not self.Menu.smartcast:Value() then
				Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
			end
			DelayAction(SecondPosE,0.05,{pos2})
			DelayAction(ReturnCursor,delay/1000+0.05,{castSpell.mouse})
			castSpell.casting = ticker + delay
		end
	end
end


function Viktor:CastSpell(spell,pos)
	local delay = self.Menu.delay:Value()
	local ticker = GetTickCount()
	if castSpell.state == 0 then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			--block movement
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			DelayAction(LeftClick,delay/1000,{castSpell.mouse})
			castSpell.casting = ticker + delay
		end
	end
end
function Viktor:AutoW()
	if not self.Menu.MiscMenu.autoW:Value() then return end
	local ImmobileEnemy = self:GetImmobileTarget()
	if ImmobileEnemy then
		self:CastSpell(HK_W,ImmobileEnemy.pos)
	end
end
function Viktor:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Viktor:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Viktor:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end
function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	p2 = p2 or myHero.pos
	p1 = p1.x and p1 or p1.pos
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end
function Viktor:AutoInterrupt(target)
	if self.Menu.MiscMenu.wInterrupt:Value() and self:CanCast(_W) and GetDistance(target.pos)<W.Range then
		self:CastSpell(HK_W,target.pos)
	elseif self.Menu.MiscMenu.rInterrupt:Value() and self:CanCast(_R) and GetDistance(target.pos)<R.Range and myHero:GetSpellData(_R).name ~= "ViktorChaosStormGuide" then
		self:CastSpell(HK_R,target.pos)
	end
end
--[[Spells]]
function Viktor:LoadSpells()
	Q = {Range = 665}
	W = {Range = 700, Delay = 0.5, Radius = 300, Speed = math.huge,aoe = true, type = "circular"}
	E = {Range = 525, MaxRange = 1225, length = 700, width = 90, Delay = 0.5, Speed = 1050, type = "linear"}
	R = {Range = 700, width = nil, Delay = 0.25, Radius = 300, Speed = 1000, Collision = false, aoe = false, type = "linear"}
end
--[[Menu Icons]]
local Icons = {
	["ViktorIcon"] = "http://vignette2.wikia.nocookie.net/leagueoflegends/images/a/a3/ViktorSquare.png",
	["Q"] = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/d/d1/Siphon_Power.png",
	["W"] = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/0/07/Gravity_Field.png",
	["E"] = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/1/1a/Death_Ray.png",
	["R"] = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/0/0b/Chaos_Storm.png"
}

function Viktor:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Viktor:GetQTarget(jungle)
	local range = Q.Range
	self.EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and (not range or GetDistance(minion)<range) and ((jungle == true and minion.team == 300) or (jungle == false and minion.team ~= 300)) then
			table.insert(self.EnemyMinions, minion)
		end
	end
	return self.EnemyMinions
end



function Viktor:GetEnemyMinions(range)
	self.EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and (not range or GetDistance(minion)<range) then
			table.insert(self.EnemyMinions, minion)
		end
	end
	return self.EnemyMinions
end

function Viktor:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = Scriptname, name = Scriptname, leftIcon=Icons["ViktorIcon"]})
	
	self.Menu:MenuElement({id = "smartcast", name = "Smartcast E", tooltip = "Check this if you're using smartcasts", value = false, leftIcon=Icons["E"]})
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true, leftIcon=Icons["W"]})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true, leftIcon=Icons["E"]})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true, leftIcon=Icons["R"]})
	self.Menu.Combo:MenuElement({id = "qAuto", name = "Dont AA without passive [WIP]", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true, leftIcon=Icons["E"]})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Mana usage in percent:", value = 30, min = 0, max = 101, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "eDistance", name = "Harass range with E", value = 1000, min = E.Range, max = E.MaxRange, step = 50, identifier = ""})
	self.Menu.Harass:MenuElement({id = "HarassActive", name = "Harass key", key = string.byte("C")})
	
	
	--[[WaveClear]]
	self.Menu:MenuElement({type = MENU, id = "WaveClear", name = "WaveClear Settings"})
	self.Menu.WaveClear:MenuElement({id = "waveUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.WaveClear:MenuElement({id = "waveUseE", name = "Use W", value = true, leftIcon=Icons["E"]})
	self.Menu.WaveClear:MenuElement({id = "waveMana", name = "Mana usage in percent:", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.WaveClear:MenuElement({id = "waveNumE", name = "Minions to hit with E", value = 2, min = 1, max = 10, step = 1, identifier = ""})
	self.Menu.WaveClear:MenuElement({id = "waveActive", name = "WaveClear key", key = string.byte("G")})
	self.Menu.WaveClear:MenuElement({id = "jungleActive", name = "JungleClear key", key = string.byte("G")})
	
	
	--[[LastHit]]
	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Settings [WIP]"})
	self.Menu.LastHit:MenuElement({id = "waveUseQLH", name = "Use Q for lasthit", key = string.byte("A"), leftIcon=Icons["Q"]})
	
	--[[Flee]]
	self.Menu:MenuElement({type = MENU, id = "Flee", name = "Flee Settings"})
	self.Menu.Flee:MenuElement({id = "FleeActive", name = "Flee key", key = string.byte("A")})
	
	--[[MiscMenu]]
	self.Menu:MenuElement({type = MENU, id = "MiscMenu", name = "Misc Settings"})
	self.Menu.MiscMenu:MenuElement({id = "rInterrupt", name = "R to interrupt", value = true, tooltip = "Use R to interrupt dangerous spells", leftIcon=Icons["R"]})
	self.Menu.MiscMenu:MenuElement({id = "wInterrupt", name = "W to interrupt",tooltip = "Use W to interrupt dangerous spells", value = true, leftIcon=Icons["W"]})
	self.Menu.MiscMenu:MenuElement({id = "autoW", name = "Use W to continue CC", value = true, leftIcon=Icons["W"]})
	self.Menu.MiscMenu:MenuElement({id = "miscGapcloser", name = "Use W against gapclosers [WIP]", value = true})
	
	--[[RMenu]]
	self.Menu:MenuElement({type = MENU, id = "RMenu", name = "R config"})
	self.Menu.RMenu:MenuElement({id = "AutoFollowR", name = "Auto Follow R [WIP]", value = true})
	self.Menu.RMenu:MenuElement({id = "hitR", name = "Min R hits: ", value = 1, drop = {"1 target", "2 targets", "3 targets", "4 targets", "5 targets"}})
	self.Menu.RMenu:MenuElement({id = "rTicks", name = "Ultimate ticks to count [WIP]", value = 2, min = 1, max = 14, step = 1, identifier = ""})
	
	
	--[[RSolo]]
	self.Menu.RMenu:MenuElement({type = MENU, id = "RSolo", name = "R one target"})
	self.Menu.RMenu.RSolo:MenuElement({id = "forceR", name = "Force R on target",leftIcon=Icons["R"], key = string.byte("T")})
	self.Menu.RMenu.RSolo:MenuElement({id = "rLastHit", name = "1 target ulti", value = true})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.RMenu.RSolo:MenuElement({id = "RU"..hero.charName, name = "Use R on: "..hero.charName, value = true})
	end
	
	
	
	
	
	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true, leftIcon=Icons["Q"]})
	self.Menu.Draw:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true, leftIcon=Icons["W"]})
	self.Menu.Draw:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true, leftIcon=Icons["E"]})
	self.Menu.Draw:MenuElement({id = "DrawEMax", name = "Draw E Max Range", value = true})
	self.Menu.Draw:MenuElement({id = "ERangeC", name = "E Range color", color = Draw.Color(0x3FBFBFFF)})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true, leftIcon=Icons["R"]})
	self.Menu.Draw:MenuElement({id = "RRangeC", name = "R Range color", color = Draw.Color(0xBF3FBFFF)})
	self.Menu:MenuElement({id = "delay", name = "spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	Viktor()
end