local Scriptname,Version,Author,LVersion = "TRUSt in my Viktor","v1.0","TRUS","7.4"

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
	{ charName = "Katarina", spell = _R},
	{ charName = "Galio", spell = _R},
	{ charName = "FiddleSticks", spell = _R},
	{ charName = "FiddleSticks", spell = _W},
	{ charName = "Nunu", spell = _R},
	{ charName = "Shen", spell = _R},
	{ charName = "Urgot", spell = _R},
	{ charName = "Malzahar",spell = _R},
	{ charName = "Karthus", spell = _R},
	{ charName = "Pantheon",spell = _R, suppresed = true},
	{ charName = "Varus", spell = _Q, suppresed = true},
	{ charName = "Caitlyn", spell = _R, suppresed = true},
	{ charName = "MissFortune", spell = _R},
	{ charName = "Warwick", spell = _R, wait = true}
}

local spellslist = {_Q,_W,_E,_R,SUMMONER_1,SUMMONER_2}
lastcallback = {}


function ReturnState(champion,spell)
	lastcallback[champion.charName..spell.name] = false
end

function Viktor:OnProcessSpell(champion,spell)
	PrintChat(champion.charName.." casted: "..spell.name)
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
					self:OnProcessSpell(Hero,spelldata)
					lastcallback[tempname..spelldata.name] = true
					DelayAction(ReturnState,spelldata.currentCd,{Hero,spelldata})
				end		
			end
		end
	end
end
function Viktor:Tick()
	self:ProcessSpellCallback()
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

function Viktor:AutoInterrupt()
	if self.Menu.MiscMenu.wInterrupt:Value() and self:CanCast(_W) then
		
	elseif self.Menu.MiscMenu.rInterrupt:Value() and self:CanCast(_R) then
		
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
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	Viktor()
end