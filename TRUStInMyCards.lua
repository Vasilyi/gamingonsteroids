--[v1.0]]
local Scriptname,Version,Author,LVersion = "TRUSt in my Cards","v1.0","TRUS","7.6"

class "TwistedFate"



function TwistedFate:__init()
	if myHero.charName ~= "TwistedFate" then return end
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("WndMsg", function() self:OnWndMsg() end)
	DelayAction(delayload,5)
end
onetimereset = true
blockattack = false
blockmovement = false
function delayload()
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
		_G.SDK.Orbwalker:OnPreMovement(function(arg) 
			if blockmovement then
				arg.Process = false
			end
		end)
		
		_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
			if blockattack then
				arg.Process = false
			end
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end
local lastpick = 0
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
	self.Menu:MenuElement({id = "UseQ", name = "Use Q",leftIcon=Icons["Q"], key = string.byte("Z")})
	
	
	self.Menu:MenuElement({id = "AutoW", name = "Autopick goldcard on ult", value = true})
	self.Menu:MenuElement({id = "AutoQ", name = "AutoQ on immobile", value = true})
	
	--[[Draw]]
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawRMinimap", name = "Draw R Range on minimap", value = true})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function TwistedFate:Tick()
	if myHero.dead then return end
	local WName = myHero:GetSpellData(_W).name
	if self.Menu.AutoW:Value() and self:HasBuff(myHero, "Gate") then
		
		if (self:CanCast(_W)) and WName == "PickACard" and GetTickCount() > lastpick + 200 and ToSelect == "NONE" then
			ToSelect = "GOLD"
			Control.CastSpell(HK_W)
			lastpick = GetTickCount()
		end
	end
	
	if self:CanCast(_Q) then 
		if self.Menu.AutoQ:Value() then
			local immobiletarget = self:GetImmobileTarget()
			if immobiletarget and self:IsValidTarget(immobiletarget,Q.Range) then
				self:CastQ(immobiletarget)
			end
		end
		if self.Menu.UseQ:Value() then
			self:CastQ()
		end
	end
	
	
	if ((ToSelect == "GOLD" or self.Menu.CardPicker.GoldCard:Value()) and WName == "GoldCardLock")
	or ((ToSelect == "RED" or self.Menu.CardPicker.RedCard:Value()) and WName == "RedCardLock") 
	or ((ToSelect == "BLUE" or self.Menu.CardPicker.BlueCard:Value()) and WName == "BlueCardLock") then
		Control.CastSpell(HK_W)
		ToSelect = "NONE"
	end
	
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}



function EnableMovement()
	--unblock movement
	blockattack = false
	blockmovement = false
	if _G.GOS then
		_G.GOS.BlockAttack = false
		_G.GOS.BlockMovement = false
	end
	onetimereset = true
	castSpell.state = 0
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	
	DelayAction(ReturnCursor,0.05,{pos})
end

function TwistedFate:CastSpell(spell,pos)
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
				blockattack = true
				blockmovement = true
				if _G.GOS then
					_G.GOS.BlockAttack = true
					_G.GOS.BlockMovement = true
				end
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
				Control.mouse_event(MOUSEEVENTF_LEFTUP)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end


--[[CastQ]]
function TwistedFate:CastQ(target)
	local target = target or self:GetTarget(Q.range)
	if target and self:CanCast(_Q) and self:IsValidTarget(target, Q.Range, false, myHero.pos) then
		if target then
			local castPos = target:GetPrediction(Q.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, castPos)
		end
	end
end


function TwistedFate:Draw()
	if myHero.dead then return end
	if self:IsReady(_Q) and self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, Draw.Color(255, 255, 0, 10))
	end
	if self:IsReady(_R) then
		if self.Menu.Draw.DrawRMinimap:Value() then
			Draw.CircleMinimap(myHero.pos, 5500, 3, Draw.Color(255, 255, 0, 10))
		end
		if self.Menu.Draw.DrawR:Value() then
			Draw.Circle(myHero.pos, 5500, 3, Draw.Color(255, 255, 0, 10))
		end
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

function TwistedFate:Stunned(enemy)
	for i = 0, enemy.buffCount do
		local buff = enemy:GetBuff(i);
		if (buff.type == 5 or buff.type == 11 or buff.type == 24) and buff.duration > 0.5 then
			return true
		end
	end
	return false
end

function TwistedFate:IsImmune(unit)
	if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	for i, buff in pairs(self:GetBuffs(unit)) do
		if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then
			return true
		end
	end
	return false
end

function TwistedFate:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
	if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
	if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or self:IsImmune(unit) or (checkTeam and unit.isAlly) then
		return false
	end
	return unit.pos:DistanceTo(from and from.pos or myHero.pos) < range
end

function TwistedFate:GetImmobileTarget()
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


function TwistedFate:GetTarget(range)
	local currenttarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(range,"AP"))
	return currenttarget
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


function TwistedFate:OnWndMsg(key, param)
	local WName = myHero:GetSpellData(_W).name
	if (self:CanCast(_W)) and WName == "PickACard" and GetTickCount() > lastpick + 200 then
		if self.Menu.CardPicker.GoldCard:Value() then
			--PrintChat("gold")
			ToSelect = "GOLD"
			lastpick = GetTickCount()
		elseif self.Menu.CardPicker.RedCard:Value() then
			--PrintChat("red")
			ToSelect = "RED"
			lastpick = GetTickCount()
		elseif self.Menu.CardPicker.BlueCard:Value() then
			--PrintChat("blue")
			ToSelect = "BLUE"
			lastpick = GetTickCount()
		end
		if ToSelect ~= "NONE" then
			Control.CastSpell(HK_W)
		end
	end
end
function OnLoad()
	TwistedFate()
end