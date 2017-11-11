class "TargetSpell"
local Scriptname,Version,Author,LVersion = "Simple TargetSpell","v1.0","TRUS","7.22"

function TargetSpell:__init()
	if Champs[myHero.charName] == nil then
		PrintChat "Hero didnt have TargetSpells, TargetSpell unloaded"
		return
	end
	
	Champs = {
		["Alistar"] = { slot = _W, range = myHero:GetSpellData(_W).range},
		["Anivia"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Annie"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Akali"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Brand"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Fiddlesticks"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Gangplank"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Janna"] = { slot = _W, range = myHero:GetSpellData(_W).range},
		["Kayle"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Kassadin"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["KhaZix"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["LeBlanc"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Malzahar"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Nunu"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Olaf"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Pantheon"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Shaco"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Swain"] = { slot = _E, range = myHero:GetSpellData(_E).range},
		["Teemo"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Vladimir"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Warwick"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
		["Yasuo"] = { slot = _Q, range = myHero:GetSpellData(_Q).range},
	}
	
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
	for i, spell in pairs(Champs[myHero.charName]) do
		self.Menu.Draw:MenuElement({id = str[i], name = "Draw range"..str[i], value = true})
		self.Menu.Draw:MenuElement({id = "color"..str[i], name = "Color for "..str[i], color = Draw.Color(0xBF3F3FFF)})
		self.Menu.TargetSpells:MenuElement({id = str[i], name = "Use"..str[i], key = keybindings[i]})
		self.Menu.TargetSpells:MenuElement({id = strauto[i], name = "Auto"..str[i], key = castbuttons[i], toggle = true})
	end
	
	
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
	local selected
	for i, _gameHero in ipairs(self:GetEnemyHeroes()) do
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
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function TargetSpell:Tick()
	for i, spell in pairs(Champs[myHero.charName]) do
		if (self.Menu.TargetSpells[str[i]]:Value() or self.Menu.TargetSpells[strauto[i]]:Value()) and self:CanCast(i) then
			local temptarget = self:GetTarget(spell.range)
			if temptarget then
				self:CastSpell(castbuttons[i],temptarget)
			end
		end
	end
end

function TargetSpell:Draw()
	if myHero.dead then return end
	for i, spell in pairs(Champs[myHero.charName]) do
		if self.Menu.Draw[str[i]]:Value() then
			Draw.Circle(myHero.pos, spell.range, 3, self.Menu.Draw["color"..str[i]]:Value())
		end
	end
end
function OnLoad()
	TargetSpell()
end