local CAMenu = MenuElement({type = MENU, id = "CAMenu", name = "CD Tracker", leftIcon = "http://puu.sh/rGodn/41bac3be46.png"})
CAMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
CAMenu:MenuElement({type = MENU, id = "SpellTracker", name = "Spell Tracker", leftIcon = "http://puu.sh/rGqMW/ae5ae40702.png"})
CAMenu.SpellTracker:MenuElement({id = "fontsize", name = "Font size", value = 20, min = 4, max = 40, step = 1, identifier = ""})
CAMenu.SpellTracker:MenuElement({id = "Xpos", name = "XPos", value = 90, min = -500, max = 500, step = 1, identifier = ""})
CAMenu.SpellTracker:MenuElement({id = "Ypos", name = "YPos", value = 0, min = -500, max = 500, step = 1, identifier = ""})
CAMenu.SpellTracker:MenuElement({id = "ShowCD", name = "Show cd numbers", key = string.byte("E")})
CAMenu.SpellTracker:MenuElement({id = "Enabled", name = "Enabled", value = true})
CAMenu.SpellTracker:MenuElement({id = "TEnemies", name = "Track Enemies", value = true, leftIcon = "http://puu.sh/rGoYt/5c99e94d8a.png"})
CAMenu.SpellTracker:MenuElement({id = "TAllies", name = "Track Allies", value = true, leftIcon = "http://puu.sh/rGoYo/0e0e445743.png"})
CAMenu.SpellTracker:MenuElement({id = "TrackTrinket", name = "Track Trinket", value = true, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.12.1/img/item/3340.png"})



local mapID = Game.mapID;
ExpGain = {0,280,660,1140,1720,2400,3180,4060,5040,6120,7300,8580,9960,11440,13020,14700,16480,18360}; --summonersift, feel free for treeline or abyss


local summonerSprites = {};
local XposX = 90;
local YposY = 0;

summonerSprites[1] = { Sprite("SpellTracker\\1.png"), "SummonerBarrier" }
summonerSprites[2] = { Sprite("SpellTracker\\2.png"), "SummonerBoost" }
summonerSprites[3] = { Sprite("SpellTracker\\3.png"), "SummonerDot" }
summonerSprites[4] = { Sprite("SpellTracker\\4.png"), "SummonerExhaust" }
summonerSprites[5] = { Sprite("SpellTracker\\5.png"), "SummonerFlash" }
summonerSprites[6] = { Sprite("SpellTracker\\6.png"), "SummonerHaste" }
summonerSprites[7] = { Sprite("SpellTracker\\7.png"), "SummonerHeal" }
summonerSprites[8] = { Sprite("SpellTracker\\8.png"), "SummonerSmite" }
summonerSprites[9] = { Sprite("SpellTracker\\9.png"), "SummonerTeleport" }
summonerSprites[10] = { Sprite("SpellTracker\\10.png"), "S5_SummonerSmiteDuel" }
summonerSprites[11] = { Sprite("SpellTracker\\11.png"), "S5_SummonerSmitePlayerGanker" }
summonerSprites[12] = { Sprite("SpellTracker\\12.png"), "SummonerPoroRecall" }
summonerSprites[13] = { Sprite("SpellTracker\\13.png"), "SummonerPoroThrow" }


local function GetSpriteByName(name)
	for i, summonerSprite in pairs(summonerSprites) do
		if summonerSprite[2] == name then
			return summonerSprite[1];
		end
	end
end


local function DrawSpellTracking(type, hero)
	if not CAMenu.SpellTracker[type] then
		return
	end
	if not CAMenu.SpellTracker[type]:Value() then
		return
	end
	
	if hero.pos2D.onScreen then
		local XposX = CAMenu.SpellTracker.Xpos:Value()
		local YposY = CAMenu.SpellTracker.Ypos:Value()
		local fontsize = CAMenu.SpellTracker.fontsize:Value()
		local shownumbers = CAMenu.SpellTracker.ShowCD:Value()
		Draw.Rect(hero.pos2D.x-XposX-5-1,hero.pos2D.y+YposY+3+12-1, 118+2 , 12+2 ,Draw.Color(0x7A000000)); --whole bar
		
		Draw.Rect(hero.pos2D.x-XposX+3+27*0,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xAA000000)); --spell bars
		Draw.Rect(hero.pos2D.x-XposX+3+27*1,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xAA000000));
		Draw.Rect(hero.pos2D.x-XposX+3+27*2,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xAA000000));
		Draw.Rect(hero.pos2D.x-XposX+3+27*3,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xAA000000));
		
		Draw.Rect(hero.pos2D.x-XposX-5+121-1,hero.pos2D.y+YposY+3+12-1, 33+2 , 12+2 ,Draw.Color(0x7A00005A)); --whole bar
		Draw.Rect(hero.pos2D.x-XposX+121,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xAA000000)); --spell bars
		local QData = hero:GetSpellData(_Q);
		if QData.level > 0 then
			for z = 1, QData.level do
				Draw.Rect(hero.pos2D.x-XposX+27*0+z*5-1,hero.pos2D.y+YposY+3+21, 1 , 2 ,Draw.Color(0xFFFFFF00));
			end
			if QData.ammoCurrentCd > 0 then
				if QData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+3+27*0,hero.pos2D.y+YposY+3+16, 23 - ((QData.ammoCurrentCd / QData.ammoCd) * 23) ,4,Draw.Color(0xFFFF7F00));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*0,hero.pos2D.y+YposY+3+16, 23 - ((QData.ammoCurrentCd / QData.ammoCd) * 23) ,4,Draw.Color(0xFFFF0000));
				end
			else
				if QData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(QData.currentCd).."|", fontsize, hero.pos2D.x-XposX+3+27*0, hero.pos2D.y+YposY+3+16, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+3+27*0,hero.pos2D.y+YposY+3+16, 23 - ((QData.currentCd / QData.cd) * 23) ,4,Draw.Color(0xFFFF0000));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*0,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xFF00FF00));
				end;
			end
		end
		local WData = hero:GetSpellData(_W);
		if WData.level > 0 then
			for z = 1, WData.level do
				Draw.Rect(hero.pos2D.x-XposX+27*1+z*5-1,hero.pos2D.y+YposY+3+21, 1 , 2 ,Draw.Color(0xFFFFFF00));
			end
			if WData.ammoCurrentCd > 0 then
				if WData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+3+27*1,hero.pos2D.y+YposY+3+16, 23 - ((WData.ammoCurrentCd / WData.ammoCd) * 23) ,4,Draw.Color(0xFFFF7F00));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*1,hero.pos2D.y+YposY+3+16, 23 - ((WData.ammoCurrentCd / WData.ammoCd) * 23) ,4,Draw.Color(0xFFFF0000));
				end
			else
				if WData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(WData.currentCd).."|", fontsize, hero.pos2D.x-XposX+3+27*1, hero.pos2D.y+YposY+3+16, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+3+27*1,hero.pos2D.y+YposY+3+16, 23 - ((WData.currentCd / WData.cd) * 23) ,4,Draw.Color(0xFFFF0000));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*1,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xFF00FF00));
				end;
			end;
		end
		local EData = hero:GetSpellData(_E);
		if EData.level > 0 then
			for z = 1, EData.level do
				Draw.Rect(hero.pos2D.x-XposX+27*2+z*5-1,hero.pos2D.y+YposY+3+21, 1 , 2 ,Draw.Color(0xFFFFFF00));
			end
			if EData.ammoCurrentCd > 0 then
				if EData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+3+27*2,hero.pos2D.y+YposY+3+16, 23 - ((EData.ammoCurrentCd / EData.ammoCd) * 23) ,4,Draw.Color(0xFFFF7F00));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*2,hero.pos2D.y+YposY+3+16, 23 - ((EData.ammoCurrentCd / EData.ammoCd) * 23) ,4,Draw.Color(0xFFFF0000));
				end
			else
				if EData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(EData.currentCd).."|", fontsize, hero.pos2D.x-XposX+3+27*2, hero.pos2D.y+YposY+3+16, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+3+27*2,hero.pos2D.y+YposY+3+16, 23 - ((EData.currentCd / EData.cd) * 23) ,4,Draw.Color(0xFFFF0000));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*2,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xFF00FF00));
				end;
			end;
		end
		local RData = hero:GetSpellData(_R);
		if RData.level > 0 then
			for z = 1, RData.level do
				Draw.Rect(hero.pos2D.x-XposX+27*3+z*5-1,hero.pos2D.y+YposY+3+21, 1 , 2 ,Draw.Color(0xFFFFFF00));
			end
			if RData.ammoCurrentCd > 0 then
				if RData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+3+27*3,hero.pos2D.y+YposY+3+16, 23 - ((RData.ammoCurrentCd / RData.ammoCd) * 23) ,4,Draw.Color(0xFFFF7F00));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*3,hero.pos2D.y+YposY+3+16, 23 - ((RData.ammoCurrentCd / RData.ammoCd) * 23) ,4,Draw.Color(0xFFFF0000));
				end
			else
				if RData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(RData.currentCd).."|", fontsize, hero.pos2D.x-XposX+3+27*3, hero.pos2D.y+YposY+3+16, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+3+27*3,hero.pos2D.y+YposY+3+16, 23 - ((RData.currentCd / RData.cd) * 23) ,4,Draw.Color(0xFFFF0000));
				else
					Draw.Rect(hero.pos2D.x-XposX+3+27*3,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xFF00FF00));
				end;
			end;
		end
		local TData = hero:GetSpellData(ITEM_7);
		if TData.level > 0 then
			if TData.ammoCurrentCd > 0 then
				if TData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+121,hero.pos2D.y+YposY+3+16, 23 - ((TData.ammoCurrentCd / TData.ammoCd) * 23) ,4,Draw.Color(0xFFFFAD00));
				else
					Draw.Rect(hero.pos2D.x-XposX+121,hero.pos2D.y+YposY+3+16, 23 - ((TData.ammoCurrentCd / TData.ammoCd) * 23) ,4,Draw.Color(0xFFFF0000));
				end
			else
				if TData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(TData.currentCd).."|", fontsize, hero.pos2D.x-XposX+121, hero.pos2D.y+YposY+3+16, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+121,hero.pos2D.y+YposY+3+16, 23 - ((TData.currentCd / TData.cd) * 23) ,4,Draw.Color(0xFFFF0000));
				else
					Draw.Rect(hero.pos2D.x-XposX+121,hero.pos2D.y+YposY+3+16,23,4,Draw.Color(0xFF00FF00));
				end;
			end;
		end
		local DData = hero:GetSpellData(SUMMONER_1);
		if DData.level > 0 then
			local SpellYOffset = 0;
			if DData.ammoCurrentCd > 0 then
				if DData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+120+33-1, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFFAD00));
				else
					Draw.Rect(hero.pos2D.x-XposX+120+33-1, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFF0000));
				end
				SpellYOffset = math.max( (228 - math.ceil((DData.ammoCurrentCd / DData.ammoCd) * 20) * 12) ,0);
			else
				if DData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(DData.currentCd).."|", fontsize, hero.pos2D.x-XposX+120+33+35, hero.pos2D.y+YposY+3, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+120+33-1, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFF0000));
					SpellYOffset = math.max( (228 - math.ceil((DData.currentCd / DData.cd) * 20) * 12) ,0);
				else
					Draw.Rect(hero.pos2D.x-XposX+120+33-1, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFF00FF00));
					SpellYOffset = 228;
				end;
			end;
			local SprIdx1 = GetSpriteByName(DData.name);
			if SprIdx1 ~= nil then
				local sprCut = {x = 0, y = SpellYOffset, w = 12, h = SpellYOffset+12}
				SprIdx1:Draw(sprCut, hero.pos2D.x-XposX+120+33, hero.pos2D.y+YposY+3+12);
			end
		end
		local FData = hero:GetSpellData(SUMMONER_2);
		if FData.level > 0 then
			local SpellYOffset = 0;
			if FData.ammoCurrentCd > 0 then
				if FData.ammo > 0 then
					Draw.Rect(hero.pos2D.x-XposX+120+33-1+16, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFFAD00));
				else
					Draw.Rect(hero.pos2D.x-XposX+120+33-1+16, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFF0000));
				end
				SpellYOffset = math.max( (228 - math.ceil((FData.ammoCurrentCd / FData.ammoCd) * 20) * 12) ,0);
			else
				if FData.currentCd > 0 then
					if shownumbers then 
						Draw.Text(math.floor(FData.currentCd).."|", fontsize, hero.pos2D.x-XposX+120+33+75, hero.pos2D.y+YposY+3, Draw.Color(0xFFFF7F00))
					end
					Draw.Rect(hero.pos2D.x-XposX+120+33-1+16, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFFFF0000));
					SpellYOffset = math.max( (228 - math.ceil((FData.currentCd / FData.cd) * 20) * 12) ,0);
				else
					Draw.Rect(hero.pos2D.x-XposX+120+33-1+16, hero.pos2D.y+YposY+3+12-1,14,14,Draw.Color(0xFF00FF00));
					SpellYOffset = 228;
				end;
			end;
			local SprIdx2 = GetSpriteByName(FData.name);
			if SprIdx2 ~= nil then
				local sprCut = {x = 0, y = SpellYOffset, w = 12, h = SpellYOffset+12}
				--DrawSprite(SprIdx2, hero.pos2D.x-XposX+120+33+16, hero.pos2D.y+YposY+3+12, 0, SpellYOffset, 12, SpellYOffset+12, 0xffFFFFFF);
				SprIdx2:Draw(sprCut, hero.pos2D.x-XposX+120+33+16, hero.pos2D.y+YposY+3+12);
			end
		end
	end
end


function OnDraw()
	ProcessSpellCallback()
	if CAMenu.Enabled:Value() then
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
			if hero.alive and hero.visible then
				if CAMenu.SpellTracker.Enabled:Value() then
					if hero.pos2D.onScreen then
						DrawSpellTracking(hero.isEnemy and "TEnemies" or hero.isAlly and "TAllies" or "noidea", hero);
					end
				end
			end
		end
	end
end


local spellslist = {SUMMONER_1,SUMMONER_2}
lastcallback = {}

function ReturnState(champion,spell)
	lastcallback[champion.charName..spell.name] = false
end

function OnProcessSpell(champion,spell)
	seconds = Game.Timer()+spell.cd
	hours = string.format("%02.f", math.floor(seconds/3600));
	mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
	secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
	result = mins..":"..secs
	PrintChat(champion.charName.." : "..spell.name.." : "..result)
end

function ProcessSpellsLoad()
	for i, spell in pairs(spellslist) do
		local tempname = myHero.charName
		lastcallback[tempname..myHero:GetSpellData(spell).name] = false
	end
end

function ProcessSpellCallback()
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.valid then
			for i, spell in pairs(spellslist) do
				local tempname = Hero.charName
				local spelldata = Hero:GetSpellData(spell)
				if spelldata.castTime > Game.Timer() and 
				not lastcallback[tempname..spelldata.name] then
					OnProcessSpell(Hero,spelldata)
					lastcallback[tempname..spelldata.name] = true
					DelayAction(ReturnState,spelldata.currentCd,{Hero,spelldata})
				end		
			end
		end
	end
end

function OnLoad()
	ProcessSpellsLoad()
end