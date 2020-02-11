class "IHateSkillshots"
local Scriptname,Version,Author,LVersion = "IHateSkillshots","v1.7","TRUS","10.3"
if FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
	require 'PremiumPrediction'
	PrintChat("PremiumPrediction library loaded")
end


Champs = {
	["Aphelios"] = {
		[_Q] = { speed = 1850, delay = 250, range = 1450, minionCollisionWidth = 60,circular = false, ignorecol = true},
		[_R] = { speed = 1000, delay = 500, range = 1600, minionCollisionWidth = 110, ignorecol = true}
	},
	
	
	["Senna"] = {
		[_W] = { speed = 1000, delay = 500, range = 1150, minionCollisionWidth = 60,circular = false, ignorecol = false},
	},
	
	["Aatrox"] = {
		[_Q] = { speed = 2000, delay = 600, range = 650, minionCollisionWidth = 250,circular = true, ignorecol = true},
		[_E] = { speed = 1250, delay = 250, range = 1075, minionCollisionWidth = 35, ignorecol = true}
	},
	
	["Ahri"] = {
		[_Q] = { speed = 2500, delay = 250, range = 1000, minionCollisionWidth = 100, ignorecol = true},
		[_E] = { speed = 1550, delay = 250, range = 1000, minionCollisionWidth = 80}
	},
	
	["Amumu"] = {
		[_Q] = { speed = 2000, delay = 250, range = 1100, minionCollisionWidth = 90}
	},
	
	["Anivia"] = {
		[_Q] = { speed = 850, delay = 250, range = 1100, minionCollisionWidth = 110, ignorecol = true}
	},
	
	["Bard"] = {
		[_Q] = { speed = 1600, delay = 250, range = 950, minionCollisionWidth = 60}
	},
	
	["Blitzcrank"] = {
		[_Q] = { delay = 250, range = 1050, minionCollisionWidth = 70, speed = 1800}
	},
	
	["Brand"] = {
		[_Q] = { delay = 250, range = 1100, minionCollisionWidth = 60, speed = 1600},
		[_W] = { delay = 850, range = 900, minionCollisionWidth = 240, speed = math.maxinteger}
	},
	
	["Braum"] = {
		[_Q] = {delay = 250, range = 1050, minionCollisionWidth = 60, speed = 1700},
		[_R] = {delay = 500, range = 1200, minionCollisionWidth = 115, speed = 1400}
	},
	
	["Caitlyn"] = {
		[_Q] = {delay = 625, range = 1300, minionCollisionWidth = 90, speed = 2200, ignorecol = true},
		[_W] = { delay = 600, range = 800, minionCollisionWidth = 80, ignorecol = true,circular = true},
		[_E] = {delay = 125, range = 1000, minionCollisionWidth = 70, speed = 1600}
	},
	
	["Cassiopeia"] = {
		[_Q] = { delay = 750, range = 850, minionCollisionWidth = 150, speed = math.maxinteger,circular = true,ignorecol = true}
	},
	
	
	["Chogath"] = {
		[_Q] = { delay = 1200, range = 950, minionCollisionWidth = 250, speed = math.maxinteger, ignorecol = true,circular = true}
	},
	
	["Corki"] = {
		[_Q] = {delay = 300, range = 825, minionCollisionWidth = 250, speed = 1000, ignorecol = true,circular = true},
		[_R] = {delay = 200, range = 1300, minionCollisionWidth = 40, speed = 2000}
		
	},
	
	["DrMundo"] = {
		[_Q] = { delay = 250, range = 1050, minionCollisionWidth = 60, speed = 2000}
	},
	
	["Ekko"] = {
		[_Q] = {delay = 250, range = 950, minionCollisionWidth = 60, speed = 1650}
	},
	
	["Elise"] = {
		[_E] = {delay = 250, range = 1100, minionCollisionWidth = 55, speed = 1600}
	},
	
	
	
	
	["Ezreal"] = {
		[_Q] = {delay = 250, range = 1200, minionCollisionWidth = 60, speed = 2000},
		[_W] = {delay = 250, range = 1050, minionCollisionWidth = 80, speed = 1600, ignorecol = true},
		[_R] = {delay = 1000, range = 20000, minionCollisionWidth = 160, speed = 2000, ignorecol = true}
	},
	
	["Galio"] = {
		[_Q] = {delay = 250, range = 900, minionCollisionWidth = 200, speed = 1300, ignorecol = true},
		[_E] = {delay = 250, range = 1200, minionCollisionWidth = 120, speed = 1200, ignorecol = true}
		
	},
	
	["Gnar"] = {
		[_Q] = {delay = 250, range = 1125, minionCollisionWidth = 60, speed = 2500, ignorecol = true}
		
	},
	
	
	["Gragas"] = {
		[_Q] = {delay = 250, range = 1100, minionCollisionWidth = 275, speed = 1300,ignorecol = true,circular = true},
		[_E] = {delay = 0, range = 950, minionCollisionWidth = 200, speed = 1200,ignorecol = true,circular = true}
	},
	
	["Graves"] = {
		[_Q] = {delay = 250, range = 808, minionCollisionWidth = 40, speed = 3000,ignorecol = true}
		
	},
	
	["Heimerdinger"] = {
		[_W] = {delay = 250, range = 1500, minionCollisionWidth = 70, speed = 1800, circular = true},
		[_E] = {delay = 250, range = 925, minionCollisionWidth = 100, speed = 1200, ignorecol = true,circular = true}
	},
	["Illaoi"] = {
		[_Q] = {delay = 750, range = 850,
		minionCollisionWidth = 100,ignorecol = true},
		[_E] = {delay = 250, range = 950, minionCollisionWidth = 50, speed = 1900}
	},
	["Janna"] = {
		[_Q] = {delay = 250, range = 1700, minionCollisionWidth = 120, speed = 900,ignorecol = true}
		
	},
	["JarvanIV"] = {
		[_Q] = {delay = 600, range = 770, minionCollisionWidth = 70, speed = math.maxinteger,ignorecol = true}
		
	},
	
	["Jayce"] = {
		[_Q] = {delay = 250, range = 1300, minionCollisionWidth = 70, speed = 1450}
		
	},
	["Jhin"] = {
		[_W] = {delay = 750, range = 2550, minionCollisionWidth = 40, speed = 5000, ignorecol = true}
		
	},
	["Jinx"] = {
		[_W] = {delay = 600, range = 1500, minionCollisionWidth = 60, speed = 3300}
		
	},
	["Kaisa"] = {
		[_W] = {delay = 500, range = 3000, minionCollisionWidth = 100, speed = 1750}
		
	},
	["Kalista"] = {
		[_Q] = {delay = 250, range = 1200, minionCollisionWidth = 40, speed = 1700}
		
	},
	
	["Karma"] = {
		[_Q] = {delay = 250, range = 1050, minionCollisionWidth = 60, speed = 1700}
		
	},
	
	
	["Karthus"] = {
		[_Q] = {delay = 625, range = 875, minionCollisionWidth = 160, speed = math.maxinteger,circular = true,ignorecol = true}
	},
	["Kennen"] = {
		[_Q] = {delay = 125, range = 1050, minionCollisionWidth = 50, speed = 1700}
	},
	
	["Khazix"] = {
		[_W] = {delay = 250, range = 1025, minionCollisionWidth = 73, speed = 1700}
	},
	["KogMaw"] = {
		[_Q] = {delay = 250, range = 1200, minionCollisionWidth = 70, speed = 1650},
		[_E] = {delay = 250, range = 1360, minionCollisionWidth = 120, speed = 1400, ignorecol = true},
		[_R] = {delay = 1200, range = 1800, minionCollisionWidth = 225, speed = math.maxinteger, ignorecol = true}
	},
	
	["Leblanc"] = {
		[_E] = {delay = 250, range = 950, minionCollisionWidth = 70, speed = 1750}
	},
	
	
	["LeeSin"] = {
		[_Q] = {delay = 250, range = 1100, minionCollisionWidth = 65, speed = 1800}
	},
	
	
	["Leona"] = {
		[_E] = {delay = 250, range = 875, minionCollisionWidth = 70, speed = 2000, ignorecol = true}
	},
	
	["Lissandra"] = {
		[_Q] = {delay = 250, range = 700, minionCollisionWidth = 75, speed = 2200, ignorecol = true}
	},
	
	
	["Lucian"] = {
		[_W] = {delay = 250, range = 1000, minionCollisionWidth = 55, speed = 1600}
	},
	
	["Lulu"] = {
		[_Q] = {delay = 250, range = 950, minionCollisionWidth = 60, speed = 1450, ignorecol = true}
	},
	
	["Lux"] = {
		[_Q] = {delay = 250, range = 1300, minionCollisionWidth = 70, speed = 1200},
		[_E] = {delay = 250, range = 1100, minionCollisionWidth = 275, speed = 1300, ignorecol = true,circular = true}
	},
	
	
	
	["Morgana"] = {
		[_Q] = {delay = 250, range = 1300, minionCollisionWidth = 80, speed = 1200}
	},
	
	
	["Nami"] = {
		[_Q] = {delay = 950, range = 1625, minionCollisionWidth = 150, speed = math.maxinteger,ignorecol = true, circular = true}
	},
	
	["Nautilus"] = {
		[_Q] = {delay = 250, range = 1250, minionCollisionWidth = 90, speed = 2000}
	},
	["Nocturne"] = {
		[_Q] = {delay = 250, range = 1125, minionCollisionWidth = 60, speed = 1400,ignorecol = true}
	},
	
	["Nidalee"] = {
		[_Q] = {delay = 250, range = 1500, minionCollisionWidth = 40, speed = 1300},
		[_W] = { delay = 1, range = 800, minionCollisionWidth = 80, ignorecol = true,circular = true}
	},
	
	["Quinn"] = {
		[_Q] = { delay = 313, range = 1050, minionCollisionWidth = 60, speed = 1550}
	},
	["Poppy"] = {
		[_Q] = {delay = 500, range = 430, minionCollisionWidth = 100, speed = math.maxinteger,ignorecol = true}
	},
	
	["Rengar"] = {
		[_E] = {delay = 250, range = 1000, minionCollisionWidth = 70, speed = 1500}
	},
	
	["Rumble"] = {
		[_E] = {delay = 250, range = 950, minionCollisionWidth = 60, speed = 2000}
	},
	
	["Sion"] = {
		[_E] = {delay = 250, range = 800, minionCollisionWidth = 80, speed = 1800,ignorecol = true}
	},
	
	["Soraka"] = {
		[_Q] = {delay = 500, range = 950, minionCollisionWidth = 300, speed = 1750,ignorecol = true,circular = true}
	},
	
	
	["Sivir"] = {
		[_Q] = {delay = 250, range = 1250, minionCollisionWidth = 90, speed = 1350, ignorecol = true}
	},
	
	["Skarner"] = {
		[_E] = {delay = 250, range = 1000, minionCollisionWidth = 70, speed = 1500, ignorecol = true}
	},
	
	["Syndra"] = {
		[_Q] = {delay = 600, range = 800, minionCollisionWidth = 150, speed = math.maxinteger, ignorecol = true, circular = true}
	},
	["Talon"] = {
		[_W] = {delay = 250, range = 800, minionCollisionWidth = 80, speed = 2300, ignorecol = true}
	},
	
	["TahmKench"] = {
		[_Q] = {delay = 250, range = 951, minionCollisionWidth = 90, speed = 2800}
	},
	
	["Thresh"] = {
		[_Q] = {delay = 500, range = 1100, minionCollisionWidth = 70, speed = 1900}
		
	},
	
	
	["TwistedFate"] = {
		[_Q] = {delay = 250, range = 1450, minionCollisionWidth = 40, speed = 1000, ignorecol = true}
	},
	
	
	["Twitch"] = {
		[_W] = {delay = 250, range = 900, minionCollisionWidth = 275, speed = 1400, ignorecol = true,circular = true}
	},
	
	["Urgot"] = {
		[_Q] = {delay = 500, range = 800, minionCollisionWidth = 60, speed = 2000,ignorecol = true,circular = true},
		[_R] = {delay = 850, range = 1600, minionCollisionWidth = 80, speed = 3200,ignorecol = true}
	},
	
	["Veigar"] = {
		[_Q] = { delay = 250, range = 950, minionCollisionWidth = 70, speed = 2000},
		[_W] = {delay = 1350, range = 900, minionCollisionWidth = 225, speed = math.maxinteger,ignorecol = true, circular = true}
	},
	
	["Varus"] = {
		[_Q] = { delay = 250, range = 650, minionCollisionWidth = 70, speed = 2000},
		[_E] = { delay = 250, range = 650, minionCollisionWidth = 250, speed = math.maxinteger,ignorecol = true, circular = true}
	},
	
	["Velkoz"] = {
		[_W] = {delay = 250, range = 1200, minionCollisionWidth = 88, speed = 1700,ignorecol = true},
		[_E] = {delay = 500, range = 800, minionCollisionWidth = 225, speed = 1500,ignorecol = true, circular = true}
	},
	
	["Xerath"] = {
		[_W] = {delay = 700, range = 1000, minionCollisionWidth = 200, speed = math.maxinteger,ignorecol = true, circular = true},
		[_E] = {delay = 200, range = 1150, minionCollisionWidth = 60, speed = 1400}
	},
	
	["Ziggs"] = {
		[_Q] = {delay = 250, range = 850, minionCollisionWidth = 140, speed = 1700}
	},
	["Zilean"] = {
		[_Q] = {delay = 300, range = 900, minionCollisionWidth = 210, speed = 2000, circular = true}
	},
	["Rakan"] = {
		[_Q] = {delay = 250, range = 750, minionCollisionWidth = 65, speed = 1850}
	},
	["Zyra"] = {
		[_E] = {delay = 250, range = 1150, minionCollisionWidth = 70, speed = 1150,ignorecol = true}
	},
	
}

local CollSpell = {}
function IHateSkillshots:__init()
	if Champs[myHero.charName] == nil then
		PrintChat "Hero didnt have skillshots, IHateSkillshots unloaded"
		return
	end
	PrintChat("IHateSkillshots loaded for "..myHero.charName)
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end
str = { [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" }
keybindings = { [_Q] = 0x5A, [_W] = 0x58, [_E] = 0x43, [_R] = 0x56 }
castbuttons = { [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R }

function IHateSkillshots:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "I Hate skillshots : Settings", name = Scriptname})
	
	--[[Skills list]]
	self.Menu:MenuElement({id = "Skillshots", name = "KeyBinds", type = MENU})
	self.Menu:MenuElement({id = "Draw", name = "Drawing", type = MENU})
	for i, spell in pairs(Champs[myHero.charName]) do
		self.Menu.Draw:MenuElement({id = str[i], name = "Draw range"..str[i], value = true})
		self.Menu.Draw:MenuElement({id = "color"..str[i], name = "Color for "..str[i], color = Draw.Color(0xBF3F3FFF)})
		self.Menu.Skillshots:MenuElement({id = str[i], name = "Use"..str[i], key = keybindings[i]})
	end
	if (TPred) then
		self.Menu:MenuElement({id = "TPredDraw", name = "Draw TPred position", value = true})
		self.Menu:MenuElement({id = "Tminchance", name = "TPred Minimal hitchance", value = 1, min = 0, max = 5, step = 1, identifier = ""})
	end
	if (_G.PremiumPrediction:Loaded()) then
		self.Menu:MenuElement({id = "PremPredDraw", name = "Draw PremPrediction position", value = true})
		self.Menu:MenuElement({id = "PremPredminchance", name = "PremPr Minimal hitchance", value = 1, min = 1, max = 100, step = 1, identifier = ""})
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

function IHateSkillshots:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end
function IHateSkillshots:ValidTarget(unit,range,from)
	from = from or myHero.pos
	range = range or math.huge
	return unit and unit.valid and not unit.dead and unit.visible and unit.isTargetable and GetDistanceSqr(unit.pos,from) <= range*range
end

function IHateSkillshots:GetTarget(range)
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

function IHateSkillshots:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	local from = from or myHero.pos
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	return unit.pos:DistanceTo(from) < range
end

function IHateSkillshots:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana <= myHero.mana
end

function IHateSkillshots:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function IHateSkillshots:CanCast(spellSlot)
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

function IHateSkillshots:CastSpell(spell,pos)
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

function IHateSkillshots:Tick()
	for i, spell in pairs(Champs[myHero.charName]) do
		if self.Menu.Skillshots[str[i]]:Value() and self:CanCast(i) then
			local temptarget = self:GetTarget(spell.range)
			if temptarget == nil then return end
			local temppred
			local collisionc = spell.ignorecol and 0 or spell.minionCollisionWidth
			if (_G.PremiumPrediction:Loaded()) then
				local spellData = {speed = spell.speed, range = spell.range, delay = spell.delay/1000, radius = spell.minionCollisionWidth, collision = spell.ignorecol and {} or {"minion"}, type = spell.circular and "circular" or "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, temptarget, spellData)
				if pred.CastPos and pred.HitChance >= self.Menu.PremPredminchance:Value() then
					local castpos = pred.CastPos
					if (not spell.circular) then
						castpos = myHero.pos:Extended(castpos,math.random(100,300))
					end
					self:CastSpell(castbuttons[i],castpos)
				end			
			elseif (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(temptarget, spell.delay/1000, spell.minionCollisionWidth/2, spell.range,spell.speed, myHero.pos,not spell.ignorecol, spell.circular and "circular" or "line")
				if (HitChance >= self.Menu.Tminchance:Value()) then
					if (not spell.circular) then
						castpos = myHero.pos:Extended(castpos,math.random(100,300))
					end
					self:CastSpell(castbuttons[i],castpos)
				end
			else
				temppred = temptarget:GetPrediction(spell.speed,spell.delay/1000)
				if not temppred then return end 
				if collisionc > 0 then
					if _G.Collision then
						local block, list = CollSpell[i]:__GetCollision(myHero, temppred, 5)
						if block then 
							return 
						end							
					elseif (temptarget:GetCollision(spell.minionCollisionWidth,spell.speed,spell.delay)) >0 then
						return 
					end
				end
				if spell.circular then 
					self:CastSpell(castbuttons[i],temppred)
				else
					local newpos = myHero.pos:Extended(temppred,math.random(100,300))
					self:CastSpell(castbuttons[i],newpos)
				end
			end
			
		end
	end
end

function IHateSkillshots:Draw()
	if myHero.dead then return end
	for i, spell in pairs(Champs[myHero.charName]) do
		if self.Menu.Draw[str[i]]:Value() then
			Draw.Circle(myHero.pos, spell.range, 3, self.Menu.Draw["color"..str[i]]:Value())
		end
	end
	if (TPred and self.Menu.TPredDraw:Value()) then
		for i, spell in pairs(Champs[myHero.charName]) do
			if self:CanCast(i) then
				local temptarget = self:GetTarget(spell.range)
				if temptarget == nil then return end
				local temppred
				local collisionc = spell.ignorecol and 0 or spell.minionCollisionWidth	
				local castpos,HitChance, pos = TPred:GetBestCastPosition(temptarget, spell.delay/1000, spell.minionCollisionWidth/2, spell.range,spell.speed, myHero.pos,not spell.ignorecol, spell.circular and "circular" or "line")
				if castpos then
					Draw.Circle(castpos, 60, 3, self.Menu.Draw["color"..str[i]]:Value())
				end
			end
		end
	end
	if (_G.PremiumPrediction:Loaded() and self.Menu.PremPredDraw:Value()) then
		for i, spell in pairs(Champs[myHero.charName]) do
			if self:CanCast(i) then
				local temptarget = self:GetTarget(spell.range)
				if temptarget == nil then return end
				local spellData = {speed = spell.speed, range = spell.range, delay = spell.delay/1000, radius = spell.minionCollisionWidth, collision = spell.ignorecol and {} or {"minion"}, type = spell.circular and "circular" or "linear"}
				local pred = _G.PremiumPrediction:GetPrediction(myHero, temptarget, spellData)
				if pred.CastPos then
					Draw.Circle(pred.CastPos, 60, 3, self.Menu.Draw["color"..str[i]]:Value())
				end
			end
		end
	end
end
function OnLoad()
	IHateSkillshots()
end
