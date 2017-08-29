local Scriptname,Version,Author,LVersion = "TRUSt in my WardJump","v1.1","TRUS","7.17"

class "WardJump"
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6,[ITEM_7] = HK_ITEM_7, [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R }
local _wards = {2045, 2049, 2050, 2301, 2302, 2303, 3340, 3361, 3362, 3711, 1408, 1409, 1410, 1411, 2043, 2055}
function WardJump:__init()
	if (myHero.charName == "LeeSin") then
		JumpSlot = _W
	elseif (myHero.charName == "Jax") then
		JumpSlot = _Q
	elseif (myHero.charName == "Katarina") then
		JumpSlot = _E
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
	for i = 1, Game.WardCount() do
		local object = Game.Ward(i)
		if object~=nil then
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
	for i = 1, Game.MinionCount() do
		local object = Game.Minion(i)
		if object~=nil then
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
	
	for i = 1, Game.HeroCount() do
		local object = Game.Hero(i)
		if object~=nil then
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
	return closest, closestDistance
end

function WardJump:Cast(spell,pos)
	Control.SetCursorPos(pos)
	Control.KeyDown(spell)
	Control.KeyUp(spell)
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
					self:Cast(keybindings[JumpSlot], ward.pos);
				end
			elseif GetTickCount() > lastward + 200 then
				lastward = GetTickCount()
				if myHero.pos:DistanceTo(mousePos) < 600 then
					self:Cast(keybindings[wardslot], mousePos)
					self:Cast(keybindings[JumpSlot], mousePos)
				else
					newpos = myHero.pos:Extended(mousePos,600)
					self:Cast(keybindings[wardslot], newpos)
					self:Cast(keybindings[JumpSlot], newpos)
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