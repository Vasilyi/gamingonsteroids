--[v1.0]]
local Scriptname,Version,Author,LVersion = "TRUSt in my WardJump","v1.0","TRUS","7.4"

class "WardJump"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7, [_W] = HK_W, [_R] = HK_R }
local _wards = {2045, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 2055}
function WardJump:__init()
	if (myHero.charName == "LeeSin") then
		JumpSlot = _W
	elseif (myHero.charName == "Jax") then
		JumpSlot = _Q
	end
	if (JumpSlot == nil) then
		return
	end
	PrintChat(Scriptname.." "..Version.." - Loaded....")
	self:LoadMenu()
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("WndMsg", function() self:OnWndMsg() end)
end
function WardJump:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function WardJump:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function WardJump:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end


function WardJump:GetInventorySlotItem(itemID, target)
	assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
	local target = target or myHero
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }) do
		if target:GetItemData(j).itemID == itemID and (target:GetSpellData(j).ammo > 0 or target:GetItemData(j).ammo > 0) then return j end
	end
	return nil
end

function WardJump:IsWrongTarget(unit)
	return unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable
end

function WardJump:findWardNearestMouse()
	local closestDistance, closest = math.huge, nil
	for i = 1, Game.ObjectCount() do
		local object = Game.Object(i)
		if object~=nil then
			if object.team ~= TEAM_ENEMY then
				if (myHero.charName ~= "LeeSin" or object.isAlly) then
					if not self:IsWrongTarget(object) and myHero.pos:DistanceTo(object.pos) < 625 then
						local currentDistance = object.pos:DistanceTo(mousePos)
						if currentDistance < closestDistance then
							closestDistance = currentDistance
							closest = object
						end
					end
				end
			end
		end
	end
	return closest, closestDistance
end


local delayedActions, delayedActionsExecuter = {}, nil
function DelayAction(func, delay, args) --delay in seconds
	if not delayedActionsExecuter then
		function delayedActionsExecuter()
			for t, funcs in pairs(delayedActions) do
				if t <= os.clock() then
					for _, f in ipairs(funcs) do f.func(table.unpack(f.args or {})) end
					delayedActions[t] = nil
				end
			end
		end
		Callback.Add("Tick", function() delayedActionsExecuter() end)
	end
	local t = os.clock() + (delay or 0)
	if delayedActions[t] then table.insert(delayedActions[t], { func = func, args = args })
	else delayedActions[t] = { { func = func, args = args } }
	end
end


function jump(pos)
	if myHero.charName ~= "LeeSin" or myHero:GetSpellData(_W).name == "BlindMonkWOne" then
		Control.CastSpell(keybindings[JumpSlot], pos);
	end
end

local lastward = 0
function WardJump:OnWndMsg(key, param)
	
	
	local mouseRadius = self.Menu.mouseradius:Value()
	if self.Menu.JumpKey:Value() and self:CanCast(JumpSlot) and (myHero.charName ~= "LeeSin" or myHero:GetSpellData(_W).name == "BlindMonkWOne") then
		local wardslot = nil
		for t, ids in pairs(_wards) do
			if not wardslot then
				wardslot = self:GetInventorySlotItem(ids)
			end
		end
		if wardslot then
			local ward,dis = self:findWardNearestMouse()
			if ward~=nil and dis~=nil and dis<mouseRadius then
				if myHero.pos:DistanceTo(ward.pos) <=625 then
					Control.CastSpell(keybindings[JumpSlot], ward.pos);
				end
			elseif GetTickCount() > lastward + 200 then
				lastward = GetTickCount()
				if myHero.pos:DistanceTo(mousePos) < 600 then
					Control.CastSpell(keybindings[wardslot], mousePos)
					DelayAction(jump, 0.1, { mousePos })
					DelayAction(jump, 0.2, { mousePos })
				else
					newpos = myHero.pos:Extended(mousePos,600)
					Control.CastSpell(keybindings[wardslot], newpos)
					DelayAction(jump, 0.1, { newpos })
					DelayAction(jump, 0.2, { newpos })
				end
			end
		end
		
	end
end



function WardJump:Draw()
	if not self.Menu.DrawRange:Value() then return end
	Draw.Circle(myHero.pos, 625, 3, Draw.Color(255, 255, 0, 10))
end
function WardJump:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "WardJumper", name = Scriptname})
	self.Menu:MenuElement({id = "JumpKey", name = "Jump key", key = string.byte("G")})
	self.Menu:MenuElement({id = "DrawRange", name = "Draw jump range", value = true})
	self.Menu:MenuElement({id = "mouseradius", name = "Search radius", value = 150, min = 30, max = 400, step = 10, identifier = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function OnLoad()
	WardJump()
end