if myHero.charName ~= "Lissandra" then return end
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

class "Lissandra"
local Scriptname,Version,Author,LVersion = "TRUSt in my Lissandra","v1.0","TRUS","7.14"
local passive = true
local lastbuff = 0


function CurrentTarget(range)
	if _G.SDK then -- ic orbwalker
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	elseif _G.EOW then -- eternal orbwalker
		return _G.EOW:GetTarget(range)
	else -- default orbwalker
		return _G.GOS:GetTarget(range,"AP")
	end
end

function Lissandra:__init()
	
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
function Lissandra:LoadSpells()
	Q = {Range = 725, width = 75, Delay = 0.25, Speed = 2250}
	W = {Range = 440, width = nil, Delay = 0.25, Radius = 60, Speed = math.huge, Collision = false, aoe = false, type = "linear"}
	E = {Range = 1050, width = 110, Delay = 0.25, Speed = 850}
	R = {Range = 550, width = 690, Delay = 0.25, Speed = 800}
	
	if TYPE_GENERIC then 
		local WSpell = Prediction:SetSpell({range = W.Range, speed = W.Speed, delay = W.Delay, width = W.width}, TYPE_LINE, true)
		EPrediction["W"] = WSpell
		local QSpell = Prediction:SetSpell({range = Q.Range, speed = Q.Speed, delay = Q.Delay, width = Q.width}, TYPE_LINE, true)
		EPrediction["Q"] = QSpell
		local QSpell2 = Prediction:SetSpell({range = 825, speed = Q.Speed, delay = Q.Delay, width = Q.width}, TYPE_LINE, true)
		EPrediction["Q2"] = QSpell2
	end
	
end



function Lissandra:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyLissandra", name = Scriptname})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "UseW", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "UseR", value = true})
	self.Menu.ComboMode:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	self.Menu.ComboMode:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
	
	self.Menu:MenuElement({id = "RMode", name = "R Usage", type = MENU})
	self.Menu.RMode:MenuElement({id = "UseR", name = "Force R key", key = string.byte("G")})
	self.Menu.RMode:MenuElement({id = "UseRSelf", name = "Use self ult", value = true})
	self.Menu.RMode:MenuElement({id = "UltCount", name = "Min enemys for SelfR", value = 2, min = 0, max = 5, step = 1, identifier = ""})
	
	
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "UseQ", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseQCreeps", name = "Use Q through creeps", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "UseW", value = true})
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



function Lissandra:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	
	if (self.Menu.ComboMode.UseR:Value() and self.Menu.ComboMode.comboActive:Value()) or self.Menu.RMode.UseR:Value() then
		self:UseR()
	end
	if self.Menu.HarassMode.harassActive:Value() then
		self:Harass()
	end
	if self.Menu.ComboMode.comboActive:Value() then
		self:Combo()
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
function Lissandra:Draw()
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
function Lissandra:UseR()
	if self:CanCast(_R) then 
		local RTarget = CurrentTarget(R.Range)
		if RTarget then
			if self.Menu.RMode.UseRSelf:Value() then
				local countenemys = self:EnemyInRange(R.Range) or 0
				if countenemys >= self.Menu.RMode.UltCount:Value() and myHero.maxHealth * 50 * 0.01 < myHero.health then
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

function Lissandra:CastSpell(spell,pos)
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


function Lissandra:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Lissandra:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Lissandra:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function Lissandra:Combo()
	if self:CanCast(_Q) then 
		local QTarget = CurrentTarget(725)
		if self.Menu.ComboMode.UseQ:Value() and QTarget then
			if TYPE_GENERIC then
				local temppredclose = EPrediction["Q"]:GetPrediction(QTarget, myHero.pos)
				if temppredclose and temppredclose.hitChance > self.Menu.minchance:Value() then
					self:CastSpell(HK_Q,temppredclose.castPos)
				end
			else
				castPos = target:GetPrediction(Q.Speed,Q.Delay)
				local newpos = myHero.pos:Extended(castPos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
		end
	end
	
	if self:CanCast(_W) then 
		local WTarget = CurrentTarget(W.Range)
		if self.Menu.ComboMode.UseW:Value() and WTarget then
			if TYPE_GENERIC then
				local temppred = EPrediction["W"]:GetPrediction(WTarget, myHero.pos)
				if temppred and temppred.hitChance > self.Menu.minchance:Value() then
					Control.CastSpell(HK_W)
				end
			else
				local castPos = target:GetPrediction(W.Speed,W.Delay)
				if castPos then
					Control.CastSpell(HK_W)
				end
			end
		end
		
	end
end
function Lissandra:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Lissandra:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end


function Lissandra:Harass()
	if self:CanCast(_Q) then 
		if self.Menu.HarassMode.UseQCreeps:Value() then
			self:FarQTarget()
		end
		local QTarget = CurrentTarget(725)
		if self.Menu.HarassMode.UseQ:Value() and QTarget then
			if TYPE_GENERIC then
				local temppredclose = EPrediction["Q"]:GetPrediction(QTarget, myHero.pos)
				if temppredclose and temppredclose.hitChance > self.Menu.minchance:Value() then
					self:CastSpell(HK_Q,temppredclose.castPos)
				end
			else
				castPos = target:GetPrediction(Q.Speed,Q.Delay)
				local newpos = myHero.pos:Extended(castPos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
		end
	end
	
	if self:CanCast(_W) then 
		local WTarget = CurrentTarget(W.Range)
		if self.Menu.HarassMode.UseW:Value() and WTarget then
			if TYPE_GENERIC then
				local temppred = EPrediction["W"]:GetPrediction(WTarget, myHero.pos)
				if temppred and temppred.hitChance > self.Menu.minchance:Value() then
					Control.CastSpell(HK_W)
				end
			else
				local castPos = target:GetPrediction(W.Speed,W.Delay)
				if castPos then
					Control.CastSpell(HK_W)
				end
			end
		end
		
	end
end




function Lissandra:FarQTarget()
	local qtarget = CurrentTarget(825)
	if qtarget then
		if myHero.pos:DistanceTo(qtarget.pos)<725 then
			return qtarget
		end
		
		if TYPE_GENERIC then
			PrintChat("Q pred part")
			local temppredclose = EPrediction["Q"]:GetPrediction(qtarget, myHero.pos)
			local temppredfar = EPrediction["Q2"]:GetPrediction(qtarget, myHero.pos)
			if temppredclose and temppredclose.hitChance > self.Menu.minchance:Value() then
				self:CastSpell(HK_Q,temppredclose.castPos)
			end
			
			if temppredfar and temppredfar.castPos and EPrediction["Q2"]:mCollision() > 0 and temppredfar.hitChance > self.Menu.minchance:Value() then
				self:CastSpell(HK_Q,temppredfar.castPos)
			end
		else
			local pos = qtarget:GetPrediction(Q.Speed,Q.Delay)
			if not pos then return false end 
			local minionlist = {}
			if _G.SDK then
				minionlist = _G.SDK.ObjectManager:GetEnemyMinions(725)
			elseif _G.GOS then
				for i = 1, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 725 then
						table.insert(minionlist, minion)
					end
				end
			end
			V = Vector(pos) - Vector(myHero.pos)
			
			Vn = V:Normalized()
			Distance = myHero.pos:DistanceTo(pos)
			tx, ty, tz = Vn:Unpack()
			TopX = pos.x - (tx * Distance)
			TopY = pos.y - (ty * Distance)
			TopZ = pos.z - (tz * Distance)
			
			Vr = V:Perpendicular():Normalized()
			Radius = qtarget.boundingRadius or 65
			tx, ty, tz = Vr:Unpack()
			
			LeftX = pos.x + (tx * Radius)
			LeftY = pos.y + (ty * Radius)
			LeftZ = pos.z + (tz * Radius)
			RightX = pos.x - (tx * Radius)
			RightY = pos.y - (ty * Radius)
			RightZ = pos.z - (tz * Radius)
			
			Left = Point(LeftX, LeftY, LeftZ)
			Right = Point(RightX, RightY, RightZ)
			Top = Point(TopX, TopY, TopZ)
			Poly = Polygon(Left, Right, Top)
			
			for i, minion in pairs(minionlist) do
				toPoint = Point(minion.pos.x, minion.pos.y,minion.pos.z)
				if Poly:__contains(toPoint) then
					self:CastSpell(HK_Q,minion.pos)
				end
			end
		end
		return false 
	end
end


function OnLoad()
	Lissandra()
end