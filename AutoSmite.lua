local mapID = Game.mapID;
if mapID ~= SUMMONERS_RIFT then
	return
end

local SmiteMenu = MenuElement({type = MENU, id = "SmiteMenu", name = "Auto Smite & Markers", leftIcon = "http://puu.sh/rPsnZ/a05d0f19a8.png"})
SmiteMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
SmiteMenu:MenuElement({type = MENU, id = "SmiteMarker", name = "Smite Marker Minions"})
SmiteMenu.SmiteMarker:MenuElement({id = "Enabled", name = "Enabled", value = true})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkBaron", name = "Mark Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkHerald", name = "Mark Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkDragon", name = "Mark Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkBlue", name = "Mark Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkRed", name = "Mark Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkGromp", name = "Mark Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkWolves", name = "Mark Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkRazorbeaks", name = "Mark Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkKrugs", name = "Mark Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
SmiteMenu.SmiteMarker:MenuElement({id = "MarkCrab", name = "Mark Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
SmiteMenu:MenuElement({type = MENU, id = "AutoSmiter", name = "Auto Smite Minions"})
SmiteMenu.AutoSmiter:MenuElement({id = "Enabled", name = "Toggle Enable Key", key = string.byte("M"), toggle = true})
SmiteMenu.AutoSmiter:MenuElement({id = "DrawSTS", name = "Draw Smite Toggle State", value = true})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteBaron", name = "Smite Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteHerald", name = "Smite Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteDragon", name = "Smite Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteBlue", name = "Smite Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteRed", name = "Smite Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteGromp", name = "Smite Gromp", value = false, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteWolves", name = "Smite Wolves", value = false, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteRazorbeaks", name = "Smite Razorbeaks", value = false, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteKrugs", name = "Smite Krugs", value = false, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
SmiteMenu.AutoSmiter:MenuElement({id = "SmiteCrab", name = "Smite Crab", value = false, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
SmiteMenu:MenuElement({type = MENU, id = "AutoSmiterH", name = "Auto Smite Heroes"})
SmiteMenu.AutoSmiterH:MenuElement({id = "Enabled", name = "Enabled", value = true, leftIcon = "http://puu.sh/rTVac/7ed9f87157.png"})


local MarkTable = {
	SRU_Baron = "MarkBaron",
	SRU_RiftHerald = "MarkHerald",
	SRU_Dragon_Water = "MarkDragon",
	SRU_Dragon_Fire = "MarkDragon",
	SRU_Dragon_Earth = "MarkDragon",
	SRU_Dragon_Air = "MarkDragon",
	SRU_Dragon_Elder = "MarkDragon",
	SRU_Blue = "MarkBlue",
	SRU_Red = "MarkRed",
	SRU_Gromp = "MarkGromp",
	SRU_Murkwolf = "MarkWolves",
	SRU_Razorbeak = "MarkRazorbeaks",
	SRU_Krug = "MarkKrugs",
	Sru_Crab = "MarkCrab",
}

local SmiteTable = {
	SRU_Baron = "SmiteBaron",
	SRU_RiftHerald = "SmiteHerald",
	SRU_Dragon_Water = "SmiteDragon",
	SRU_Dragon_Fire = "SmiteDragon",
	SRU_Dragon_Earth = "SmiteDragon",
	SRU_Dragon_Air = "SmiteDragon",
	SRU_Dragon_Elder = "SmiteDragon",
	SRU_Blue = "SmiteBlue",
	SRU_Red = "SmiteRed",
	SRU_Gromp = "SmiteGromp",
	SRU_Murkwolf = "SmiteWolves",
	SRU_Razorbeak = "SmiteRazorbeaks",
	SRU_Krug = "SmiteKrugs",
	Sru_Crab = "SmiteCrab",
}

local SmiteNames = {'SummonerSmite','S5_SummonerSmiteDuel','S5_SummonerSmitePlayerGanker','S5_SummonerSmiteQuick','ItemSmiteAoE'};
local SmiteDamage = {390 , 410 , 430 , 450 , 480 , 510 , 540 , 570 , 600 , 640 , 680 , 720 , 760 , 800 , 850 , 900 , 950 , 1000};
local mySmiteSlot = 0;
--20+8*GetLevel(myHero) 


local function GetSmite(smiteSlot)
	local returnVal = 0;
	local spellName = myHero:GetSpellData(smiteSlot).name;
	for i = 1, 5 do
		if spellName == SmiteNames[i] then
			returnVal = smiteSlot
		end
	end
	return returnVal;
end

function OnLoad()
	mySmiteSlot = GetSmite(SUMMONER_1);
	if mySmiteSlot == 0 then
		mySmiteSlot = GetSmite(SUMMONER_2);
	end
end

local function DrawSmiteableMinion(type,minion)
	if not type or not SmiteMenu.SmiteMarker[type] then
		return
	end
	if SmiteMenu.SmiteMarker[type]:Value() then
		if minion.pos2D.onScreen then
			Draw.Circle(minion.pos,minion.boundingRadius,6,Draw.Color(0xFF00FF00));
		end
	end
end

local function AutoSmiteMinion(type,minion)
	if not type or not SmiteMenu.AutoSmiter[type] then
		return
	end
	if SmiteMenu.AutoSmiter[type]:Value() then
		if minion.pos2D.onScreen then
			if mySmiteSlot == SUMMONER_1 then
				Control.CastSpell(HK_SUMMONER_1,minion)
			else
				Control.CastSpell(HK_SUMMONER_2,minion)
			end
		end
	end
end


function OnDraw()
if myHero.alive == false then return end
	if SmiteMenu.Enabled:Value() and (mySmiteSlot > 0) then
		if SmiteMenu.AutoSmiter.DrawSTS:Value() then
			local myKey = SmiteMenu.AutoSmiter.Enabled:Key();
			if SmiteMenu.AutoSmiter.Enabled:Value() then
				if myKey > 0 then Draw.Text("AutoSmite Enabled ".."["..string.char(SmiteMenu.AutoSmiter.Enabled:Key()).."]",18,myHero.pos2D.x-70,myHero.pos2D.y+70,Draw.Color(255, 30, 230, 30)) end;
				else
				if myKey > 0 then Draw.Text("AutoSmite Disabled ".."["..string.char(SmiteMenu.AutoSmiter.Enabled:Key()).."]",18,myHero.pos2D.x-70,myHero.pos2D.y+70,Draw.Color(255, 230, 30, 30)) end;
				end
			end
		if SmiteMenu.SmiteMarker.Enabled:Value() or SmiteMenu.AutoSmiter.Enabled:Value() then 
			local SData = myHero:GetSpellData(mySmiteSlot);
			for i = 1, Game.MinionCount() do
				minion = Game.Minion(i);
				if minion and minion.valid and (minion.team == 300) and minion.visible then
					if minion.health <= SmiteDamage[myHero.levelData.lvl] then
						local minionName = minion.charName;
						if SmiteMenu.SmiteMarker.Enabled:Value() then
							DrawSmiteableMinion(MarkTable[minionName], minion);
						end
						if SmiteMenu.AutoSmiter.Enabled:Value() then
							if mySmiteSlot > 0 then
								if SData.level > 0 then
									if (SData.ammo > 0 and SData.currentCd == 0) then
										if minion.distance <= (500+myHero.boundingRadius+minion.boundingRadius) then
											AutoSmiteMinion(SmiteTable[minionName], minion);
										end
									end
								end
							end
						end
					end
				end
			end
		end
		if SmiteMenu.AutoSmiterH.Enabled:Value() then
			local smiteDmg = 20+8*myHero.levelData.lvl;
			local SData = myHero:GetSpellData(mySmiteSlot);
			if SData.name == SmiteNames[3] then
				if SData.level > 0 then
					if (SData.ammo > 0 and SData.currentCd == 0) then
						for i = 1, Game.HeroCount() do
							hero = Game.Hero(i);
							if hero and hero.valid and hero.visible and hero.isEnemy and (hero.distance <= (500+myHero.boundingRadius+hero.boundingRadius)) and (hero.health <= smiteDmg) then
								if mySmiteSlot == SUMMONER_1 then
									Control.CastSpell(HK_SUMMONER_1,hero)
								else
									Control.CastSpell(HK_SUMMONER_2,hero)
								end
							end
						end
					end
				end
			end
		end
	end
end


--PrintChat("Smite manager by Feretorix loaded.")