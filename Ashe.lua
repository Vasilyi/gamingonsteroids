local Scriptname,Version,Author,LVersion = "TRUSt in my Ashe","v1.1","TRUS","7.6"
if myHero.charName ~= "Ashe" then return end

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}


function GetInventorySlotItem(itemID)
	assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
	for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
		if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
	end
	return nil
end

function UseBotrk()
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
	if target then 
		local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
		if botrkitem then
			Control.CastSpell(keybindings[botrkitem],target.pos)
		end
	end
end

class "Ashe"
function Ashe:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"
		_G.SDK.Orbwalker:OnPreMovement(function(arg) 
			if blockmovement then
				arg.Process = false
			end
		end)
		
		_G.SDK.Orbwalker:OnPostAttack(function() 
			local combomodeactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") 
			local harassactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") 
			if (combomodeactive or harassactive) and self.Menu.UseQCombo:Value() then
				self:CastQ()
			end
		end)
		
		_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
			if blockattack then
				arg.Process = false
			end
		end)
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
		
	else
		orbwalkername = "Orbwalker not found"
		
	end
	PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
end
blockattack = false
blockmovement = false

local lastpick = 0
--[[Spells]]
function Ashe:LoadSpells()
	W = {Range = 1200, width = nil, Delay = 0.25, Radius = 30, Speed = 900}
end


function GetConeAOECastPosition(unit, delay, angle, range, speed, from)
	range = range and range - 4 or 20000
	radius = 1
	from = from and Vector(from) or Vector(myHero.pos)
	angle = angle * math.pi / 180
	
	local CastPosition = unit:GetPrediction(speed,delay)
	local points = {}
	local mainCastPosition = CastPosition
	
	table.insert(points, Vector(CastPosition) - Vector(from))
	
	local function CountVectorsBetween(V1, V2, points)
		local result = 0	
		local hitpoints = {} 
		for i, test in ipairs(points) do
			local NVector = Vector(V1):CrossP(test)
			local NVector2 = Vector(test):CrossP(V2)
			if NVector.y >= 0 and NVector2.y >= 0 then
				result = result + 1
				table.insert(hitpoints, test)
			elseif i == 1 then
				return -1 --doesnt hit the main target
			end
		end
		return result, hitpoints
	end
	
	local function CheckHit(position, angle, points)
		local direction = Vector(position):Normalized()
		local v1 = position:Rotated(0, -angle / 2, 0)
		local v2 = position:Rotated(0, angle / 2, 0)
		return CountVectorsBetween(v1, v2, points)
	end
	local enemyheroestable = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(range)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
	for i, target in ipairs(enemyheroestable) do
		if target.networkID ~= unit.networkID and myHero.pos:DistanceTo(target.pos) < range then
			CastPosition = target:GetPrediction(speed,delay)
			if from:DistanceTo(CastPosition) < range then
				table.insert(points, Vector(CastPosition) - Vector(from))
			end
		end
	end
	
	local MaxHitPos
	local MaxHit = 1
	local MaxHitPoints = {}
	
	if #points > 1 then
		
		for i, point in ipairs(points) do
			local pos1 = Vector(point):Rotated(0, angle / 2, 0)
			local pos2 = Vector(point):Rotated(0, - angle / 2, 0)
			
			local hits, points1 = CountVectorsBetween(pos1, pos2, points)
			--
			if hits >= MaxHit then
				
				MaxHitPos = C1
				MaxHit = hits
				MaxHitPoints = points1
			end
			
		end
	end
	
	if MaxHit > 1 then
		--Center the cone
		local maxangle = -1
		local p1
		local p2
		for i, hitp in ipairs(MaxHitPoints) do
			for o, hitp2 in ipairs(MaxHitPoints) do
				local cangle = Vector():AngleBetween(hitp2, hitp) 
				if cangle > maxangle then
					maxangle = cangle
					p1 = hitp
					p2 = hitp2
				end
			end
		end
		
		
		return Vector(from) + range * (((p1 + p2) / 2)):Normalized(), MaxHit
	else
		return mainCastPosition, 1
	end
end



function Ashe:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyAshe", name = Scriptname})
	self.Menu:MenuElement({id = "UseWCombo", name = "UseW in combo", value = true})
	self.Menu:MenuElement({id = "UseQCombo", name = "UseQ in combo", value = true})
	self.Menu:MenuElement({id = "UseWHarass", name = "UseW in Harass", value = true})
	self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Ashe:Tick()
	if myHero.dead or (not _G.SDK and not _G.GOS) then return end
	local combomodeactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") 
	local harassactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") 
	local canmove = (_G.SDK and _G.SDK.Orbwalker:CanMove()) or (_G.GOS and _G.GOS:CanMove())
	local canattack = (_G.SDK and _G.SDK.Orbwalker:CanAttack()) or (_G.GOS and _G.GOS:CanAttack())
	local currenttarget = (_G.SDK and _G.SDK.Orbwalker:GetTarget()) or (_G.GOS and _G.GOS:GetTarget())
	if combomodeactive and self.Menu.UseWCombo:Value() and canmove and not canattack then
		self:CastW()
	end
	if combomodeactive and self.Menu.UseQCombo:Value() and currenttarget and canmove and not canattack then
		self:CastQ()
	end
	if harassmodeactive and self.Menu.UseWHarass:Value() and canmove and not canattack then
		self:CastW()
	end
end


local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}



function EnableMovement()
	--unblock movement
	blockattack = false
	blockmovement = false
	if _G.GOS then
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

function Ashe:CastSpell(spell,pos)
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
				blockattack = true
				blockmovement = true
				if _G.GOS then
					_G.GOS.BlockAttack = blockattack
					_G.GOS.BlockMovement = blockmovement
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


function Ashe:CastQ()
	if self:CanCast(_Q) then
		Control.CastSpell(HK_Q)
	end
end


function Ashe:CastW(target)
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AD"))
	if target and self:CanCast(_W) and target:GetCollision(W.Radius,W.Speed,W.Delay) == 0 then
		local getposition = self:GetWPos(target)
		if getposition then
			self:CastSpell(HK_W,getposition)
		end
	end
end


function Ashe:GetWPos(unit)
	if unit then
		local temppos = GetConeAOECastPosition(unit, W.Delay, 45, W.Range, W.Speed)
		if temppos then 
			local newpos = myHero.pos:Extended(temppos,math.random(100,300))
			return newpos
		end
	end
	
	return false
end

function Ashe:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Ashe:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Ashe:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function OnLoad()
	Ashe()
end