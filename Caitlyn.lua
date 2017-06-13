if myHero.charName ~= "Caitlyn" then return end

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

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

function CurrentModes()
	local combomodeactive, harassactive, canmove, canattack, currenttarget
	if _G.SDK then -- ic orbwalker
		combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
		canmove = _G.SDK.Orbwalker:CanMove()
		canattack = _G.SDK.Orbwalker:CanAttack()
		currenttarget = _G.SDK.TargetSelector:GetTarget()
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

function GetInventorySlotItem(itemID)
	assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
		if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
	end
	return nil
end

function UseBotrk()
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
	if target then 
		local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
		if botrkitem then
			Control.CastSpell(keybindings[botrkitem],target.pos)
		end
	end
end

class "Caitlyn"
local Scriptname,Version,Author,LVersion = "TRUSt in my Caitlyn","v1.6","TRUS","7.11"
require "DamageLib"
local qtarget
if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
	require 'Eternal Prediction'
	PrintChat("Eternal Prediction library loaded")
end
local EPrediction = {}
local LastW
function Caitlyn:__init()
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
onetimereset = true
blockattack = false
blockmovement = false

local lastpick = 0
--[[Spells]]
function Caitlyn:LoadSpells()
	Q = {Range = 1190, Width = 90, Delay = 0.625, Radius = 60, Speed = 2000}
	E = {Range = 800, Width = 70, Delay = 0.125, Radius = 80, Speed = 1600}
	
	if TYPE_GENERIC then
		local QSpell = Prediction:SetSpell({range = Q.Range, speed = Q.Speed, delay = Q.Delay, width = Q.Width}, TYPE_LINE, true)
		EPrediction[_Q] = QSpell
		local ESpell = Prediction:SetSpell({range = E.Range, speed = E.Speed, delay = Q.Delay, width = Q.Width}, TYPE_LINE, true)
		EPrediction[_E] = ESpell
	end
end

function Caitlyn:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyCaitlyn", name = Scriptname})
	self.Menu:MenuElement({id = "UseUlti", name = "Use R", tooltip = "On killable target which is on screen", key = string.byte("R")})
	self.Menu:MenuElement({id = "UseEQ", name = "UseEQ", key = string.byte("X")})
	self.Menu:MenuElement({id = "autoW", name = "Use W on cc", value = true})
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
	self.Menu:MenuElement({id = "DrawR", name = "Draw Killable with R", value = true})
	self.Menu:MenuElement({id = "DrawColor", name = "Color for Killable circle", color = Draw.Color(0xBF3F3FFF)})
	
	if TYPE_GENERIC then
		self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
	end
	
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Caitlyn:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
	if combomodeactive and self.Menu.UseBOTRK:Value() then
		UseBotrk()
	end
	
	local useEQ = self.Menu.UseEQ:Value()
	
	if self.Menu.UseUlti:Value() and self:CanCast(_R) then
		self:UseR()
	end
	
	if self:CanCast(_Q) and self:CanCast(_E) and useEQ and currenttarget then
		self:CastE(currenttarget)
	end
	
	if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "CaitlynEntrapment" and self:CanCast(_Q) and useEQ then
		Control.CastSpell(HK_Q,qtarget)
	end
	if self:CanCast(_W) then
		self:AutoW()
	end
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	SetMovement(true)
end

function LeftClick(pos)
	DelayAction(ReturnCursor,0.01,{pos})
end

function Caitlyn:GetRTarget()
	self.KillableHeroes = {}
	local RRange = ({2000, 2500, 3000})[myHero:GetSpellData(_R).level]
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(RRange)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	for i, hero in pairs(heroeslist) do
		local RDamage = getdmg("R",hero,myHero,1)
		if hero.health and RDamage and RDamage > hero.health and hero.pos2D.onScreen and myHero.pos:DistanceTo(hero.pos) < RRange then
			table.insert(self.KillableHeroes, hero)
		end
	end
	return self.KillableHeroes
end

function Caitlyn:UseR()
	local RTarget = self:GetRTarget()
	if #RTarget > 0 then
		Control.SetCursorPos(RTarget[1].pos)
		Control.KeyDown(HK_R)
		Control.KeyUp(HK_R)
	end
end

function Caitlyn:Draw()
	if self.Menu.DrawR:Value() then
		local RTarget = self:GetRTarget()
		for i, hero in pairs(RTarget) do
			Draw.Circle(hero.pos, 60, 3, self.Menu.DrawColor:Value())
		end
	end
end

function Caitlyn:Stunned(enemy)
	for i = 0, enemy.buffCount do
		local buff = enemy:GetBuff(i);
		if (buff.type == 5 or buff.type == 11 or buff.type == 24) and buff.duration > 0.5 and buff.name ~= "caitlynyordletrapdebuff" then
			return true
		end
	end
	return false
end

function Caitlyn:AutoW()
	if not self.Menu.autoW:Value() then return end
	local ImmobileEnemy = self:GetImmobileTarget()
	if ImmobileEnemy and myHero.pos:DistanceTo(ImmobileEnemy.pos)<800 and (not LastW or LastW:DistanceTo(ImmobileEnemy.pos)>60) then
		LastW = ImmobileEnemy.pos
		self:CastSpell(HK_W,ImmobileEnemy.pos)
	end
end

function Caitlyn:CastSpell(spell,pos)
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
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker
			end
		end
	end
end


function Caitlyn:GetImmobileTarget()
	local GetEnemyHeroes = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(800)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	for i = 1, #GetEnemyHeroes do
		local Enemy = GetEnemyHeroes[i]
		if Enemy and self:Stunned(Enemy) and myHero.pos:DistanceTo(Enemy.pos) < 800 then
			return Enemy
		end
	end
	return false
end



function Caitlyn:CastCombo(pos)
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
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			Control.KeyDown(HK_Q)
			Control.KeyUp(HK_Q)
			DelayAction(LeftClick,delay/1000,{castSpell.mouse})
			castSpell.casting = ticker
		end
	end
end


--[[CastEQ]]
function Caitlyn:CastE(target)
	if not _G.SDK and not _G.GOS then return end
	local castpos
	if TYPE_GENERIC then
		castPos = EPrediction[_E]:GetPrediction(target, myHero.pos)
		if castPos.hitChance >= self.Menu.minchance:Value() and EPrediction[_E]:mCollision() == 0 then
			local newpos = myHero.pos:Extended(castPos.castPos,math.random(100,300))
			self:CastCombo(newpos)
			qtarget = newpos
		end
	elseif target:GetCollision(Q.Radius,Q.Speed,Q.Delay) == 0 then
		castPos = target:GetPrediction(Q.Speed,Q.Delay)
		local newpos = myHero.pos:Extended(castPos,math.random(100,300))
		self:CastCombo(newpos)
		qtarget = newpos
	end
end


function Caitlyn:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Caitlyn:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Caitlyn:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function OnLoad()
	Caitlyn()
end