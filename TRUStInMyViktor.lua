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
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "qAuto", name = "Dont autoattack without passive", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	
		--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "harassMana", name = "Mana usage in percent:", value = 30, min = 0, max = 100, identifier = "%", leftIcon = "http://puu.sh/rUZPt/da7fadf9d1.png"})
	self.Menu.Harass:MenuElement({id = "eDistance", name = "Harass range with E", value = 1000, min = E.Range, max = E.MaxRange, step = 50, identifier = ""})
	
	
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
		self.Menu.RSolo:MenuElement({id = "RU" + hero.ChampionName, name = "Use R on: " + hero.ChampionName, value = true})
	end
	
	
	-- { "1 target", "2 targets", "3 targets", "4 targets", "5 targets" })
	self.Menu.RMenu:MenuElement({id = "rTicks", name = "Ultimate ticks to count", value = 2, min = 1, max = 14, step = 1, identifier = ""})
	
	
	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawEMax", name = "Draw E Max Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	Viktor()
end