local Scriptname,Version,Author,LVersion = "TRUSt in my Twitch","v1.1","TRUS","7.10"
if myHero.charName ~= "Twitch" then return end

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


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

class "Twitch"
require "DamageLib"
local qtarget

function Twitch:__init()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
		_G.SDK.Orbwalker:OnPostAttack(function(arg) 		
			DelayAction(recheckparticle,0.2)
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		_G.GOS:OnAttackComplete(function() 
			DelayAction(recheckparticle,0.2)
		end)
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end

function Twitch:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyTwitch", name = Scriptname})
	self.Menu:MenuElement({id = "UseEKS", name = "Use E on killable", value = true})
	self.Menu:MenuElement({id = "UseERange", name = "Use E on running enemy", value = true})
	self.Menu:MenuElement({id = "MinStacks", name = "Minimal E stacks", value = 2, min = 0, max = 6, step = 5, identifier = ""})
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
	self.Menu:MenuElement({id = "DrawE", name = "Draw Killable with E", value = true})
	self.Menu:MenuElement({id = "DrawColor", name = "Color for Killable circle", color = Draw.Color(0xBF3F3FFF)})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end
function Twitch:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Combo") 
	local harassactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Harass") 
	
	
	if combomodeactive then 
		if self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end	
	end
	
	if self:CanCast(_E) and self.Menu.UseEKS:Value() then
		self:UseEKS()
	end
	
	if (harassactive or combomodeactive) and self.Menu.UseERange:Value() and self:CanCast(_E) then
		self:UseERange()
	end
end

function Twitch:UseERange()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	local target = (_G.SDK and _G.SDK.TargetSelector.SelectedTarget) or (_G.GOS and _G.GOS:GetTarget())
	if target then return end 
	for i, hero in pairs(heroeslist) do
		if stacks[hero.charName] and self:GetStacks(stacks[hero.charName].name) >= self.Menu.MinStacks:Value() then
			
			if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) < 600 then
				return
			end
			
			if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) > 1000 then
				Control.CastSpell(HK_E)
			end
		end
	end
end

function Twitch:GetStacks(str)
	if str:lower():find("twitch_poison_counter_01.troy") then return 1
	elseif str:lower():find("twitch_poison_counter_02.troy") then return 2
	elseif str:lower():find("twitch_poison_counter_03.troy") then return 3
	elseif str:lower():find("twitch_poison_counter_04.troy") then return 4
	elseif str:lower():find("twitch_poison_counter_05.troy") then return 5
	elseif str:lower():find("twitch_poison_counter_06.troy") then return 6
	end
	return 0
end
stacks = {}
function recheckparticle()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	for i = 1, Game.ObjectCount() do
		local object = Game.Object(i)		
		if object then
			for i, hero in pairs(heroeslist) do
				if object.pos:DistanceTo(hero.pos)<200 and object ~= hero then 
					local stacksamount = Twitch:GetStacks(object.name)
					if stacksamount > 0 then
						stacks[hero.charName] = object
					end
				end
			end
		end
	end
	return false
end

function Twitch:GetETarget()
	self.KillableHeroes = {}
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1200)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	local level = myHero:GetSpellData(_E).level
	for i, hero in pairs(heroeslist) do
		if stacks[hero.charName] and self:GetStacks(stacks[hero.charName].name) > 0 then 
			local EDamage = (self:GetStacks(stacks[hero.charName].name) * (({15, 20, 25, 30, 35})[level] + 0.2 * myHero.ap + 0.25 * myHero.bonusDamage)) + ({20, 35, 50, 65, 80})[level]
			local tmpdmg = CalcPhysicalDamage(myHero, hero, EDamage)
			if hero.health and tmpdmg and tmpdmg > hero.health and myHero.pos:DistanceTo(hero.pos)<1200 then
				table.insert(self.KillableHeroes, hero)
			end
		end
	end
	return self.KillableHeroes
end

function Twitch:UseEKS()
	local ETarget = self:GetETarget()
	if #ETarget > 0 then
		Control.KeyDown(HK_E)
		Control.KeyUp(HK_E)
	end
end

function Twitch:Draw()
	if self.Menu.DrawE:Value() then
		local ETarget = self:GetETarget()
		for i, hero in pairs(ETarget) do
			Draw.Circle(hero.pos, 60, 3, self.Menu.DrawColor:Value())
		end
	end
end


function Twitch:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Twitch:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Twitch:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function OnLoad()
	Twitch()
end