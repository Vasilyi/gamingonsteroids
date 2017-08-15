if myHero.charName ~= "Mordekaiser" then return end
require "2DGeometry"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
	require 'Eternal Prediction'
	PrintChat("Eternal Prediction library loaded")
end
require "DamageLib"
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

class "Mordekaiser"
local Scriptname,Version,Author,LVersion = "TRUSt in my Mordekaiser","v0.9","TRUS","7.16"
local passive = true
local lastbuff = 0

function CurrentModes()
	local combomodeactive, harassactive, canmove, canattack, currenttarget
	if _G.SDK then -- ic orbwalker
		combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
		currenttarget = _G.SDK.Orbwalker:GetTarget()
	elseif _G.EOW then -- eternal orbwalker
		combomodeactive = _G.EOW:Mode() == 1
		harassactive = _G.EOW:Mode() == 2
		canmove = _G.EOW:CanMove() 
		canattack = _G.EOW:CanAttack()
		currenttarget = _G.EOW:GetTarget()
	else -- default orbwalker
		combomodeactive = _G.GOS:GetMode() == "Combo"
		harassactive = _G.GOS:GetMode() == "Harass"
		canmove = _G.GOS:CanMove()
		canattack = _G.GOS:CanAttack()
		currenttarget = _G.GOS:GetTarget()
	end
	return combomodeactive, harassactive, canmove, canattack, currenttarget
end

function CurrentTarget(range)
	if _G.SDK then -- ic orbwalker
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.EOW then -- eternal orbwalker
		return _G.EOW:GetTarget(range)
	else -- default orbwalker
		return _G.GOS:GetTarget(range,"AP")
	end
end

function Mordekaiser:__init()
	
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
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end
local EPrediction = {}
--[[Spells]]
function Mordekaiser:LoadSpells()
	Q = {Range = myHero.range}
	W = {Range = 750}
	E = {Range = 650, width = 45, Delay = 0.5, Speed = 1500}
	R = {Range = 850}
	if TYPE_GENERIC then 
		local ESpell = Prediction:SetSpell({range = E.Range, speed = E.Speed, delay = E.Delay, width = E.width}, TYPE_LINE, true)
		EPrediction["W"] = WSpell
	end
end



function Mordekaiser:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyMordekaiser", name = Scriptname})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "UseW", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "UseR", value = true})
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
	
	self.Menu:MenuElement({id = "RMode", name = "R Usage", type = MENU})
	self.Menu.RMode:MenuElement({id = "UseR", name = "Force R key", key = string.byte("G")})

	
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "UseW", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "UseE", value = true})
	self.Menu.HarassMode:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	
	if TYPE_GENERIC then
		self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
	end
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end



function Mordekaiser:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()

	if ((combomodeactive and self.Menu.ComboMode.UseQ:Value()) or (harassactive and self.Menu.HarassMode.UseQ:Value())) and self:CanCast(_Q) and canmove and not canattack then
		Control.CastSpell(HK_Q)
	end
	
	if ((combomodeactive and self.Menu.ComboMode.UseW:Value()) or (harassactive and self.Menu.HarassMode.UseW:Value())) and self:CanCast(_W) then
		self:CastW()
	end
end

function EnableMovement()
	--unblock movement
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
function Mordekaiser:Draw()
	if self.Menu.ComboMode.DrawDamage:Value() then
		for i, hero in pairs(self:GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				--local barYOffset = self.Menu.Draw.HPBarOffset:Value()
				local QDamage = (self:CanCast(_Q) and getdmg("Q",hero,myHero) or 0)
				local WDamage = (self:CanCast(_W) and getdmg("W",hero,myHero) or 0)
				local EDamage = (self:CanCast(_E) and getdmg("E",hero,myHero) or 0)
				local RDamage = (self:CanCast(_R) and getdmg("R",hero,myHero) or 0)
				local damage = QDamage + WDamage + EDamage + RDamage
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
	end
end
function Mordekaiser:UseR()
	if self:CanCast(_R) then 
		local RTarget = CurrentTarget(R.Range)
		if RTarget then
			if self.Menu.RMode.UseRSelf:Value() then
				local countenemys = self:EnemyInRange(R.Range) or 0
				if countenemys >= self.Menu.RMode.UltCount:Value() and myHero.maxHealth * self.Menu.RMode.SelfUltHP:Value() * 0.01 >= myHero.health then
					self:CastSpell(HK_R, myHero.pos)
					return
				end
			end
			local QDamage = (self:CanCast(_Q) and getdmg("Q",RTarget,myHero) or 0)
			local WDamage = (self:CanCast(_W) and getdmg("W",RTarget,myHero) or 0)
			local EDamage = (self:CanCast(_E) and getdmg("E",RTarget,myHero) or 0)
			local RDamage = (self:CanCast(_R) and getdmg("R",RTarget,myHero) or 0)
			local TotalDamage = QDamage + WDamage + EDamage + RDamage
			if TotalDamage > RTarget.health and ((QDamage + WDamage) < RTarget.health) then
				self:CastSpell(HK_R, RTarget.pos)
			end
			
		end
	end
	
	
end

function Mordekaiser:CastSpell(spell,pos)
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


function Mordekaiser:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Mordekaiser:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Mordekaiser:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


function Mordekaiser:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Mordekaiser:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

function OnLoad()
	Mordekaiser()
end