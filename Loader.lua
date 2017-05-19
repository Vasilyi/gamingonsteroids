function smitecheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("Smite") or
	myHero:GetSpellData(SUMMONER_2).name:find("Smite") or
	myHero.charName == "Nunu" or
	myHero.charName == "Chogath" then
		return true
	else
		return false
	end
end

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if not Hero.isEnemy then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function EnemyExist(enemy)
	for i, target in pairs(GetEnemyHeroes()) do
		if target.charName == enemy then
			return true
		end
	end
	return false
end

function AllyExist(ally)
	for i, target in pairs(GetAllyHeroes()) do
		if target.charName == ally then
			return true
		end
	end
	return false
end
function Error(a)
	print(a)
end

function FileExist(path)
    assert(type(path) == "string", "FileExist: wrong argument types (<string> expected for path)")
    local file = io.open(path, "r")
    if file then file:close() return true else return false end
end

function OnLoad()

	scriptToLoad =
	{
		{ file = "LoadScripts\\IHateSkillshots.lua", load = true },
		{ file = "LoadScripts\\SkillDetector.lua", load = true },
		{ file = "LoadScripts\\IHateCC.lua", load = true },
		{ file = "LoadScripts\\GankAlerter.lua", load = true },
		{ file = "LoadScripts\\CDTrack.lua", load = true },
		{ file = "LoadScripts\\WardAwareness.lua", load = true },
		{ file = "LoadScripts\\Minimaphack.lua", load = true },
		{ file = "LoadScripts\\JungleTimers.lua", load = true },
		{ file = "LoadScripts\\RecallTrack.lua", load = true },
		{ file = "LoadScripts\\Autosmite.lua", load = (smitecheck() == true) },
		{ file = "LoadScripts\\TRUStInMyViktor.lua", load = (myHero.charName == "Viktor") },
		{ file = "LoadScripts\\TRUStInMyCards.lua", load = (myHero.charName == "TwistedFate") },
		{ file = "LoadScripts\\TRUStInMyMarksman.lua", load = (myHero.charName == "Ashe" or myHero.charName == "Ezreal" or myHero.charName == "Lucian" or myHero.charName == "Caitlyn" or myHero.charName == "Twitch" or myHero.charName == "KogMaw" or myHero.charName == "Kalista") },
	}
	--[[ 		Code		]]
	for i,script in ipairs(scriptToLoad) do
		if script.load and FileExist(SCRIPT_PATH..script.file)  then
			dofile(SCRIPT_PATH..script.file)
		end
	end
end
