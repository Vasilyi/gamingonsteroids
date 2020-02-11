class "TargetSpell"
local Scriptname,Version,Author,LVersion = "Simple TargetSpell","v1.1","TRUS","10.3"

function TargetSpell:__init()
	Champs = {
		["Alistar"] = { slot = _W, range = myHero:GetSpellData(_W).range},
		["Anivia"] = { slot = _E, range = 650},
		["Annie"] = { slot = _Q, range = 625},
		["Akali"] = { slot = _Q, range = 600},
		["Brand"] = { slot = _E, range = 625},
		["Fizz"] = { slot = _Q, range = 550},
		["Fiddlesticks"] = { slot = _Q, range = 575},
		["Gangplank"] = { slot = _Q, range = 625},
		["Jax"] = { slot = _Q, range = 700},
		["Janna"] = { slot = _W, range = myHero:GetSpellData(_W).range},
		["Kayle"] = { slot = _Q, range = 650},
		["Katarina"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Kassadin"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Khazix"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["LeBlanc"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Malzahar"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Malphite"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Nunu"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Olaf"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Pantheon"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Quinn"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Shaco"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Singed"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Swain"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Talon"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Teemo"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Vladimir"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Warwick"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Yasuo"] = { slot = _Q, range = 475},
	}
	if Champs[myHero.charName] == nil then
		PrintChat "Hero didnt have TargetSpells, TargetSpell unloaded"
		return
	end
	
	PrintChat("TargetSpell loaded for "..myHero.charName)
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end
str = { [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" }
strauto = { [_Q] = "AutoQ", [_W] = "AutoW", [_E] = "AutoE", [_R] = "AutoR" }
keybindings = { [_Q] = 0x5A, [_W] = 0x58, [_E] = 0x43, [_R] = 0x56 }
castbuttons = { [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R }

function TargetSpell:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TargetSpells : Settings", name = Scriptname})
	
	--[[Skills list]]
	self.Menu:MenuElement({id = "TargetSpells", name = "KeyBinds", type = MENU})
	self.Menu:MenuElement({id = "Draw", name = "Drawing", type = MENU})
	local tempspell = Champs[myHero.charName]
	self.Menu.Draw:MenuElement({id = str[tempspell.slot], name = "Draw range"..str[tempspell.slot], value = true})
	self.Menu.Draw:MenuElement({id = "color"..str[tempspell.slot], name = "Color for "..str[tempspell.slot], color = Draw.Color(0xBF3F3FFF)})
	self.Menu.TargetSpells:MenuElement({id = str[tempspell.slot], name = "Use"..str[tempspell.slot], key = keybindings[tempspell.slot]})
	self.Menu.TargetSpells:MenuElement({id = strauto[tempspell.slot], name = "Auto"..str[tempspell.slot], key = 0x0, toggle = true})
	
	
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	
	
end

function GetDistanceSqr(p1, p2)
	assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
	p2 = p2 or myHero.pos
	
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end

function TargetSpell:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end
function TargetSpell:ValidTarget(unit,range,from)
	from = from or myHero.pos
	range = range or math.huge
	return unit and unit.valid and not unit.dead and unit.visible and unit.isTargetable and GetDistanceSqr(unit.pos,from) <= range*range
end

function TargetSpell:GetTarget(range)
	local range = range + myHero.boundingRadius
	local selected
	for i, _gameHero in ipairs(self:GetEnemyHeroes()) do
		local range = range + _gameHero.boundingRadius
		local distance = GetDistanceSqr(_gameHero.pos)
		if self:ValidTarget(_gameHero,range) and (not selected or distance < value) then
			selected = _gameHero
			value = distance
		end
		
	end
	return selected
end

function TargetSpell:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	local from = from or myHero.pos
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	return unit.pos:DistanceTo(from) < range
end

function TargetSpell:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana <= myHero.mana
end

function TargetSpell:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function TargetSpell:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}


function EnableMovement()
	--unblock movement
	if _G.SDK then 
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	else
		_G.GOS.BlockAttack = false
		_G.GOS.BlockMovement = false
	end
	castSpell.state = 0
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

function TargetSpell:CastSpell(spell,pos)
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
				if _G.SDK then 
					_G.SDK.Orbwalker:SetMovement(false)
					_G.SDK.Orbwalker:SetAttack(false)
				else
					_G.GOS.BlockAttack = true
					_G.GOS.BlockMovement = true
				end
				Control.SetCursorPos(pos)
				Control.KeyDown(HK_TCO)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				Control.KeyUp(HK_TCO)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function TargetSpell:Tick()
if myHero.dead then return end 
	local tempspell = Champs[myHero.charName]
	if (self.Menu.TargetSpells[str[tempspell.slot]]:Value() or self.Menu.TargetSpells[strauto[tempspell.slot]]:Value()) and self:CanCast(tempspell.slot) then
		local temptarget = self:GetTarget(tempspell.range)
		if temptarget then
			self:CastSpell(castbuttons[tempspell.slot],temptarget)
		end
	end
	
end

function TargetSpell:Draw()
	if myHero.dead then return end
	local tempspell = Champs[myHero.charName]
	if self.Menu.Draw[str[tempspell.slot]]:Value() then
		Draw.Circle(myHero.pos, tempspell.range, 3, self.Menu.Draw["color"..str[tempspell.slot]]:Value())
	end
	
end
function OnLoad()
	TargetSpell()
end
