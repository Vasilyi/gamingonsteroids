--[v1.0]]
local Scriptname,Version,Author,LVersion = "TRUSt in my Cards","v1.0","TRUS","7.4"

class "TwistedFate"

require('DamageLib')

function TwistedFate:__init()
    if myHero.charName ~= "TwistedFate" then return end
    PrintChat("TRUSt in my Cards "..Version.." - Loaded....")
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("WndMsg", function() self:OnWndMsg() end)
	
end
--[[Spells]]
function TwistedFate:LoadSpells()
    Q = {Range = 1450, width = nil, Delay = 0.25, Radius = 40, Speed = 1000, Collision = false, aoe = false, type = "linear"}
end
--[[Menu Icons]]
local Icons = {
["TFIcon"] = "http://vignette3.wikia.nocookie.net/leagueoflegends/images/f/fb/Twisted_FateSquare.png",
    ["Q"] = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/2/28/Wild_Cards.png",
	["W"] = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/2/2f/Pick_a_Card.png",
    ["Gold"] = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/8/8d/Gold_Card.png",
    ["Red"] = "http://vignette3.wikia.nocookie.net/leagueoflegends/images/9/93/Red_Card.png",
    ["Blue"] = "http://vignette3.wikia.nocookie.net/leagueoflegends/images/d/d9/Blue_Card.png"
}

local ToSelect = "NONE"
local WName = "NONE"

function TwistedFate:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "TRUStinymycards", name = Scriptname, leftIcon=Icons["TFIcon"]})

    --[[Pick a card menu]]
	self.Menu:MenuElement({id = "CardPicker", name = "CardPicker",leftIcon=Icons["W"], type = MENU})
	self.Menu.CardPicker:MenuElement({id = "GoldCard", name = "Gold", leftIcon=Icons["Gold"], key = string.byte(" ")})
		self.Menu.CardPicker:MenuElement({id = "RedCard", name = "Red", leftIcon=Icons["Red"], key = string.byte("T")})
		self.Menu.CardPicker:MenuElement({id = "BlueCard", name = "Blue",leftIcon=Icons["Blue"], key = string.byte("E")})
		self.Menu.CardPicker:MenuElement({id = "UseQ", name = "Use Q",leftIcon=Icons["Q"], key = string.byte("Z")})
    
    --[[Misc]]
    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Menu.Misc:MenuElement({id = "MiscAutoR", name = "Auto R", value = false})
    self.Menu.Misc:MenuElement({id = "MiscMinR", name = "Min. Targets to Auto R", value = 3, min = 1, max = 5})
    self.Menu.Misc:MenuElement({id = "MaxRange", name = "Q Range Limiter", value = 1, min = 0.26, max = 1, step = 0.01, tooltip = "Adjust your Q Range! Recommend = 0.88"})
    self.Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "Min Q.Range = 240 - Max Q.Range = 925", tooltip = "Adjust your Q Range! Recommend = 0.88"})

    --[[Draw]]
    self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Menu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.Menu.Draw:MenuElement({id = "DrawDamage", name = "Draw Damage", value = true})

  self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
  self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
  self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end
--[[Update]]
function TwistedFate:Tick()
    if myHero.dead then return end
     WName = myHero:GetSpellData(_W).name
if (ToSelect == "GOLD" and WName == "GoldCardLock")
or (ToSelect == "RED" and WName == "RedCardLock")
or (ToSelect == "BLUE" and WName == "BlueCardLock") then
Control.CastSpell(HK_W)
ToSelect = "NONE"
end

end

--[[CastQ]]
function TwistedFate:CastQ(target)
    local target = self:GetTarget(Q.range)
    if target and self:CanCast(_Q) and self:IsValidTarget(target, Q.Range, false, myHero.pos) then
    local qTarget = self:GetTarget(Q.Range * self.Menu.Misc.MaxRange:Value())
    if qTarget and target:GetCollision(Q.Range) == 0 then
    local castPos = target:GetPrediction(Q.Delay)
    Control.CastSpell(HK_Q, castPos)
        end
    end
end


function TwistedFate:Draw()
    if myHero.dead then return end
        if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, ""..tostring(Q.Range * self.Menu.Misc.MaxRange:Value()).."", 3, Draw.Color(255, 255, 0, 10))
        end
       
end


function TwistedFate:GetEnemyHeroes()
    self.EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(self.EnemyHeroes, Hero)
        end
    end
    return self.EnemyHeroes
end

function TwistedFate:GetTarget(range)
    local GetEnemyHeroes = self:GetEnemyHeroes()
    local Target = nil
        for i = 1, #GetEnemyHeroes do
        local Enemy = GetEnemyHeroes[i]
        if self:IsValidTarget(Enemy, range, false, myHero.pos) then
            Target   = Enemy
        end
    end
    return Target
end

function TwistedFate:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function TwistedFate:GetBuffs(unit)
    self.T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.T, Buff)
        end
    end
    return self.T
end

function TwistedFate:GetBuffData(unit, buffname)
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.name:lower() == buffname:lower() and Buff.count > 0 then
            return Buff
        end
    end
    return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function TwistedFate:IsRecalling()
    for K, Buff in pairs(self:GetBuffs(myHero)) do
        if Buff.name == "recall" and Buff.duration > 0 then
            return true
        end
    end
    return false
end

function TwistedFate:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function TwistedFate:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function TwistedFate:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function TwistedFate:IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable --[[or self:IsImmune(unit)]] or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from and from or myHero) < range 
end


function TwistedFate:OnWndMsg(key, param)
if (self:CanCast(_W)) and ToSelect == "NONE" then
if self.Menu.CardPicker.GoldCard:Value() then
--PrintChat("gold")
ToSelect = "GOLD"
Control.CastSpell(HK_W)
end
if self.Menu.CardPicker.RedCard:Value() then
--PrintChat("red")
ToSelect = "RED"
Control.CastSpell(HK_W)
end
if self.Menu.CardPicker.BlueCard:Value() then
--PrintChat("blue")
ToSelect = "BLUE"
Control.CastSpell(HK_W)
end
end
end
function OnLoad()
    TwistedFate()
end