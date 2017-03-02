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



function Viktor:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymycards", name = Scriptname, leftIcon=Icons["TFIcon"]})
	
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	Viktor()
end