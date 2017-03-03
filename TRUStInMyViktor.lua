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
		PrintChat(distance)
		if _minion:IsValidTarget(Q.Range) and (not selected2 or distance < value2) then
			selected2 = _minion
			value2 = distance
		end
		
	end
	if value and value2 then
		if value > value2 then 
			return selected2
		else
			return selected1
		end
	elseif value and not value2 then
		return selected1
	elseif value2 and not value then
		PrintChat("LOL")
		return selected2
	end
end

function Viktor:Flee()
	if self:CanCast(_Q) and self:HasBuff(myHero,"viktorqeaug") or self:HasBuff(myHero,"viktorqeaug") or self:HasBuff(myHero,"viktorqwaug") or self:HasBuff(myHero,"viktorqweaug") then 
		local closestenemy = self:ClosestEnemy()
		if closestenemy and closestenemy.valid then
			self:CastSpell(HK_Q,closestenemy.pos)
		end
	end
end
function Viktor:RSolo(target)
	if self.Menu.RSolo["RU"..target.charName]:Value() then
		self:CastSpell(HK_R,target.pos)
	end
end

function Viktor:UltControl(target)
	if myHero:GetSpellData(_R).name == "viktorchaosstormguide" then
		self:CastSpell(HK_R,target.pos)
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


function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	castSpell.state = 0
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Viktor:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
		end
		if castSpell.state == 1 then
			if ticker - castSpell.tick < Game.Latency() then
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + delay
			end
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
	
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end
function Viktor:AutoInterrupt(target)
	if self.Menu.MiscMenu.wInterrupt:Value() and self:CanCast(_W) and GetDistance(target.pos)<W.Range then
		self:CastSpell(HK_W,target.pos)
	elseif self.Menu.MiscMenu.rInterrupt:Value() and self:CanCast(_R) and GetDistance(target.pos)<R.Range and myHero:GetSpellData(_R).name ~= "viktorchaosstormguide" then
		self:CastSpell(HK_R,target.pos)
	end
end
--[[Spells]]
function Viktor:LoadSpells()
	Q = {Range = 665}
	W = {Range = 700, Delay = 0.5, Radius = 300, Speed = math.huge,aoe = true, type = "circular"}
	E = {Range = 525, MaxRange = 1225, length = 700, width = 90, Delay = 0.5, Speed = 1050, type = "linear"}
	R = {Range = 700, width = nil, Delay = 0.25, Radius = 40, Speed = 1000, Collision = false, aoe = false, type = "linear"}
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


function Viktor:GetEnemyMinions()
	self.EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy then
			table.insert(self.EnemyMinions, minion)
		end
	end
	return self.EnemyMinions
end

function Viktor:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = Scriptname, name = Scriptname, leftIcon=Icons["ViktorIcon"]})
	
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true, leftIcon=Icons["W"]})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true, leftIcon=Icons["E"]})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true, leftIcon=Icons["R"]})
	self.Menu.Combo:MenuElement({id = "qAuto", name = "Dont autoattack without passive", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use W", value = true, leftIcon=Icons["E"]})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Mana usage in percent:", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.Harass:MenuElement({id = "eDistance", name = "Harass range with E", value = 1000, min = E.Range, max = E.MaxRange, step = 50, identifier = ""})
	
	
	--[[WaveClear]]
	self.Menu:MenuElement({type = MENU, id = "WaveClear", name = "WaveClear Settings"})
	self.Menu.WaveClear:MenuElement({id = "waveUseQ", name = "Use Q", value = true, leftIcon=Icons["Q"]})
	self.Menu.WaveClear:MenuElement({id = "waveUseE", name = "Use W", value = true, leftIcon=Icons["E"]})
	self.Menu.WaveClear:MenuElement({id = "waveMana", name = "Mana usage in percent:", value = 30, min = 0, max = 100, identifier = "%"})
	self.Menu.WaveClear:MenuElement({id = "waveNumE", name = "Minions to hit with E", value = 2, min = 1, max = 10, step = 1, identifier = ""})
	self.Menu.WaveClear:MenuElement({id = "waveActive", name = "WaveClear key", key = string.byte("G")})
	self.Menu.WaveClear:MenuElement({id = "jungleActive", name = "JungleClear key", key = string.byte("G")})
	
	
	--[[LastHit]]
	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "LastHit Settings"})
	self.Menu.LastHit:MenuElement({id = "waveUseQLH", name = "Use Q for lasthit", key = string.byte("A"), leftIcon=Icons["Q"]})
	
	--[[Flee]]
	self.Menu:MenuElement({type = MENU, id = "Flee", name = "Flee Settings"})
	self.Menu.Flee:MenuElement({id = "FleeActive", name = "Flee key", key = string.byte("A")})
	
	--[[MiscMenu]]
	self.Menu:MenuElement({type = MENU, id = "MiscMenu", name = "Misc Settings"})
	self.Menu.MiscMenu:MenuElement({id = "rInterrupt", name = "R to interrupt", value = true, tooltip = "Use R to interrupt dangerous spells", leftIcon=Icons["R"]})
	self.Menu.MiscMenu:MenuElement({id = "wInterrupt", name = "W to interrupt",tooltip = "Use W to interrupt dangerous spells", value = true, leftIcon=Icons["W"]})
	self.Menu.MiscMenu:MenuElement({id = "autoW", name = "Use W to continue CC", value = true, leftIcon=Icons["W"]})
	self.Menu.MiscMenu:MenuElement({id = "miscGapcloser", name = "Use W against gapclosers", value = true})
	
	--[[RMenu]]
	self.Menu:MenuElement({type = MENU, id = "RMenu", name = "R config"})
	self.Menu.RMenu:MenuElement({id = "AutoFollowR", name = "Auto Follow R", value = true})
	-- { "1 target", "2 targets", "3 targets", "4 targets", "5 targets" })
	self.Menu.RMenu:MenuElement({id = "rTicks", name = "Ultimate ticks to count", value = 2, min = 1, max = 14, step = 1, identifier = ""})
	
	--[[RSolo]]
	self.Menu:MenuElement({type = MENU, id = "RSolo", name = "R one target"})
	self.Menu.RSolo:MenuElement({id = "forceR", name = "Force R on target",leftIcon=Icons["R"], key = string.byte("T")})
	self.Menu.RSolo:MenuElement({id = "rLastHit", name = "1 target ulti", value = true})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.RSolo:MenuElement({id = "RU"..hero.charName, name = "Use R on: "..hero.charName, value = true})
	end
	
	
	
	
	-- { "1 target", "2 targets", "3 targets", "4 targets", "5 targets" })
	self.Menu.RMenu:MenuElement({id = "rTicks", name = "Ultimate ticks to count", value = 2, min = 1, max = 14, step = 1, identifier = ""})
	
	
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
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	Viktor()
end