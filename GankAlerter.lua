do

local Scriptname,Version,Author,LVersion = "GankAlerter","v1.0","TRUS","7.9"

class "GankAlerter"

olddistance = {}
oldvisible = {}
starttime = {}
function GankAlerter:__init()
	Callback.Add("Draw", function() self:Draw() end)
end

function GankAlerter:Draw()
	local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes()) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	for i, enemy in pairs(heroeslist) do
		local newdistance = myHero.pos:DistanceTo(enemy.pos)
		--PrintChat(starttime[enemy.charName])
		if starttime[enemy.charName] and (GetTickCount() - starttime[enemy.charName] < 10000) then
			local percentage = newdistance/3000
			if (percentage <= 1) then
				local width = 2 + (percentage * 8)
				Draw.Line(myHero.pos:To2D(),enemy.pos:To2D(), width)
			end
		end
		if newdistance < 3000 and enemy.visible then

			if (olddistance[enemy.charName] and olddistance[enemy.charName] > 3000 and oldvisible[enemy.charName] == false) or (oldvisible[enemy.charName] and GetTickCount() - oldvisible[enemy.charName]  > 10000) then
					--PrintChat(oldvisible[enemy.charName])
				starttime[enemy.charName] = GetTickCount()
			end
		end
		olddistance[enemy.charName] = newdistance
		oldvisible[enemy.charName] = enemy.visible and GetTickCount()
	end
end
function OnLoad()
	GankAlerter()
end

end