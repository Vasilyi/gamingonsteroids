--[[
This is just a proof of concept script, showing how you can use missiles and particles to your advantage.
A lot of code from the internet has been copied real quick and there could be a better way to actually draw the skillshots path.
--]]

local res = Game.Resolution()

local SkillshotsMenu = MenuElement({type = MENU, id = "SkillshotsMenu", name = "Enemy Skillshot Detector", leftIcon = "http://puu.sh/tpnyM/8fd63aff9a.png"})
SkillshotsMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
SkillshotsMenu:MenuElement({id = "Transparency", name = "Drawing Transparency", value = 80, min = 10, max = 255})

local function DrawLine3D(x,y,z,a,b,c,width,col)
  local p1 = Vector(x,y,z):To2D()
  local p2 = Vector(a,b,c):To2D()
  Draw.Line(p1.x, p1.y, p2.x, p2.y, width, col)
end

local function DrawRectangleOutline(x, y, z, x1, y1, z1, width, col)
  local startPos = Vector(x,y,z)
  local endPos = Vector(x1,y1,z1)
  local c1 = startPos+Vector(Vector(endPos)-startPos):Perpendicular():Normalized()*width
  local c2 = startPos+Vector(Vector(endPos)-startPos):Perpendicular2():Normalized()*width
  local c3 = endPos+Vector(Vector(startPos)-endPos):Perpendicular():Normalized()*width
  local c4 = endPos+Vector(Vector(startPos)-endPos):Perpendicular2():Normalized()*width
  DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,2,col)
  DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,2,col)
  DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,2,col)
  DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,2,col)
end
function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		--if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		--end
	end
	return EnemyHeroes
end


Champs = {
	
	["Aatrox"] = {
		[_E] = { speed = 1250, delay = 0.25, range = 1075, minionCollisionWidth = 35, ignorecol = true}
	},
	
	["Ahri"] = {
		[_Q] = { speed = 2500, delay = 0.25, range = 1000, minionCollisionWidth = 100, ignorecol = true},
		[_E] = { speed = 1550, delay = 0.25, range = 1000, minionCollisionWidth = 80}
	},
	
	["Amumu"] = {
		[_Q] = { speed = 2000, delay = 0.250, range = 1100, minionCollisionWidth = 90}
	},
	
	["Anivia"] = {
		[_Q] = { speed = 850, delay = 0.250, range = 1100, minionCollisionWidth = 110, ignorecol = true}
	},
	
	["Bard"] = {
		[_Q] = { speed = 1600, delay = 0.250, range = 950, minionCollisionWidth = 60}
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
		[_E] = {delay = 125, range = 1000, minionCollisionWidth = 70, speed = 1600}
	},
	
	
	["Corki"] = {
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
		[_E] = {delay = 0, range = 950, minionCollisionWidth = 200, speed = 1200,ignorecol = true}
	},
	
	["Graves"] = {
		[_Q] = {delay = 250, range = 808, minionCollisionWidth = 40, speed = 3000,ignorecol = true}
		
	},
	
	["Heimerdinger"] = {
		[_W] = {delay = 250, range = 1500, minionCollisionWidth = 70, speed = 1800},
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
	
	["Kalista"] = {
		[_Q] = {delay = 250, range = 1200, minionCollisionWidth = 40, speed = 1700}
		
	},
	
	["Karma"] = {
		[_Q] = {delay = 250, range = 1050, minionCollisionWidth = 60, speed = 1700}
		
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
		[_E] = {delay = 250, range = 905, minionCollisionWidth = 70, speed = 2000, ignorecol = true}
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
	},
	
	
	
	["Morgana"] = {
		[_Q] = {delay = 250, range = 1300, minionCollisionWidth = 80, speed = 1200}
	},
	
	
	["Nautilus"] = {
		[_Q] = {delay = 250, range = 1250, minionCollisionWidth = 90, speed = 2000}
	},
	["Nocturne"] = {
		[_Q] = {delay = 250, range = 1125, minionCollisionWidth = 60, speed = 1400,ignorecol = true}
	},
	
	["Nidalee"] = {
		[_Q] = {delay = 250, range = 1500, minionCollisionWidth = 40, speed = 1300},
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
		[_Q] = {delay = 500, range = 950, minionCollisionWidth = 300, speed = 1750,ignorecol = true}
	},
	
	
	["Sivir"] = {
		[_Q] = {delay = 250, range = 1250, minionCollisionWidth = 90, speed = 1350, ignorecol = true}
	},
	
	["Skarner"] = {
		[_E] = {delay = 250, range = 1000, minionCollisionWidth = 70, speed = 1500, ignorecol = true}
	},
	
	["Talon"] = {
		[_W] = {delay = 250, range = 800, minionCollisionWidth = 80, speed = 2300, ignorecol = true}
	},
	
	["TahmKench"] = {
		[_Q] = {delay = 250, range = 951, minionCollisionWidth = 90, speed = 2800}
	},
	

	
	["TwistedFate"] = {
		[_Q] = {delay = 250, range = 1450, minionCollisionWidth = 40, speed = 1000, ignorecol = true}
	},
	
	["Urgot"] = {
		[_Q] = {delay = 125, range = 1000, minionCollisionWidth = 60, speed = 1600},
	},
	
	["Veigar"] = {
		[_Q] = { delay = 250, range = 950, minionCollisionWidth = 70, speed = 2000},
	},
	
	["Velkoz"] = {
		[_W] = {delay = 250, range = 1200, minionCollisionWidth = 88, speed = 1700,ignorecol = true},
	},
	
	["Xerath"] = {
		[_E] = {delay = 200, range = 1150, minionCollisionWidth = 60, speed = 1400}
	},
	
	["Ziggs"] = {
		[_Q] = {delay = 250, range = 850, minionCollisionWidth = 140, speed = 1700}
	},
	["Zilean"] = {
		[_Q] = {delay = 300, range = 900, minionCollisionWidth = 210, speed = 2000}
	},
	["Zyra"] = {
		[_E] = {delay = 250, range = 1150, minionCollisionWidth = 70, speed = 1150,ignorecol = true}
	},
	
}

function OnDraw()
if SkillshotsMenu.Enabled:Value() == false then return end
local drawColor = Draw.Color(SkillshotsMenu.Transparency:Value(),0xFF,0xFF,0xFF);
for i = 1, Game.MissileCount() do
	local missile = Game.Missile(i)
	if missile and (missile.missileData.owner > 0) and (missile.missileData.target == 0) and (missile.missileData.speed > 0) and (missile.missileData.width > 0) and (missile.missileData.range > 0) and missile.isEnemy and (missile.team < 300)  then
		if (res.x*2 >= missile.pos2D.x) and (res.x*-1 <= missile.pos2D.x) and (res.y*2 >= missile.pos2D.y) and (res.y*-1 <= missile.pos2D.y) then --draw skillshots close to our screen, probably we need to exclude global ultimates
			Draw.Circle(missile.pos,missile.missileData.width,drawColor);
			DrawRectangleOutline(missile.missileData.startPos.x,missile.missileData.startPos.y,missile.missileData.startPos.z,missile.missileData.endPos.x,missile.missileData.endPos.y,missile.missileData.endPos.z,missile.missileData.width,drawColor);
			end
		end
	end

	for i, target in ipairs(GetEnemyHeroes()) do
		if target.isChanneling and target.activeSpell and  target.activeSpell.valid then 
		if Champs[target.charName] and Champs[target.charName][target.activeSpellSlot] then
			DrawRectangleOutline(target.activeSpell.startPos.x,target.activeSpell.startPos.y,target.activeSpell.startPos.z,target.activeSpell.placementPos.x,target.activeSpell.placementPos.y,target.activeSpell.placementPos.z,Champs[target.charName][target.activeSpellSlot].minionCollisionWidth or 60,drawColor);
		end
		end
	end

end