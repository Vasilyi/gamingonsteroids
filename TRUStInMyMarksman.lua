require "2DGeometry"
if myHero.charName == "Ashe" then
	--[v1.0]]
	local Scriptname,Version,Author,LVersion = "TRUSt in my Ashe","v1.0","TRUS","7.6"
	class "Ashe"
	function Ashe:__init()
		
		PrintChat("TRUSt in my Ashe "..Version.." - Loaded....")
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		
		
		if _G.SDK then
			_G.SDK.Orbwalker:OnPreMovement(function(arg) 
				if blockmovement then
					arg.Process = false
				end
			end)
			
			_G.SDK.Orbwalker:OnPostAttack(function() 
				self:CastQ()
			end)
			
			_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
				if blockattack then
					arg.Process = false
				end
			end)
		else
			PrintChat("This script support IC Orbwalker only")
			
		end
	end
	onetimereset = true
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
		
		for i, target in ipairs(_G.SDK.ObjectManager:GetEnemyHeroes(range)) do
			if target.networkID ~= unit.networkID then
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
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Ashe:Tick()
		if myHero.dead or not _G.SDK then return end
		local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		local harassmodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
		if combomodeactive and self.Menu.UseWCombo:Value() and _G.SDK.Orbwalker:CanMove() then
			self:CastW()
		end
		if harassmodeactive and self.Menu.UseWHarass:Value() and _G.SDK.Orbwalker:CanMove() then
			self:CastW()
		end
	end
	
	
	local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
	
	
	
	function EnableMovement()
		--unblock movement
		blockattack = false
		blockmovement = false
		onetimereset = true
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
		if self:CanCast(_Q) and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and self.Menu.UseQCombo:Value() then
			Control.CastSpell(HK_Q)
		end
	end
	
	
	function Ashe:CastW(target)
		if not _G.SDK then return end
		local target = _G.SDK.Orbwalker:GetTarget() or _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
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
end

if myHero.charName == "Lucian" then
	--[v1.0]]
	local Scriptname,Version,Author,LVersion = "TRUSt in my Lucian","v1.0","TRUS","7.6"
	
	class "Lucian"
	
	local passive = true
	local lastbuff = 0
	function Lucian:__init()
		PrintChat("TRUSt in my Lucian "..Version.." - Loaded....")
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		
		
		if _G.SDK then
			_G.SDK.Orbwalker:OnPreMovement(function(arg) 
				if blockmovement then
					arg.Process = false
				end
			end)
			
			
			_G.SDK.Orbwalker:OnPostAttack(function() 
				passive = false 
				--PrintChat("passive removed")
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				if combomodeactive and _G.SDK.Orbwalker:CanMove() and Game.Timer() > lastbuff - 3.5 then 
					if self:CanCast(_E) and self.Menu.UseE:Value() and _G.SDK.Orbwalker:GetTarget() then
						self:CastSpell(HK_E,mousePos)
						return
					end
				end
			end)
			
			_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
				if blockattack then
					arg.Process = false
				end
			end)
		else
			PrintChat("This script support IC Orbwalker only")
			
		end
	end
	onetimereset = true
	blockattack = false
	blockmovement = false
	
	local lastpick = 0
	
	--[[Spells]]
	function Lucian:LoadSpells()
		Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
	end
	
	
	
	function Lucian:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyLucian", name = Scriptname})
		self.Menu:MenuElement({id = "UseQ", name = "UseQ", value = true})
		self.Menu:MenuElement({id = "UseW", name = "UseW", value = true})
		self.Menu:MenuElement({id = "UseE", name = "UseE", value = true})
		self.Menu:MenuElement({id = "UseQHarass", name = "Harass with Q", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Lucian:GetBuffs(unit)
		self.T = {}
		for i = 0, unit.buffCount do
			local Buff = unit:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function Lucian:HasBuff(unit, buffname)
		for K, Buff in pairs(self:GetBuffs(unit)) do
			if Buff.name:lower() == buffname:lower() then
				return Buff.expireTime
			end
		end
		return false
	end
	
	function Lucian:Tick()
		if myHero.dead or not _G.SDK then return end
		
		local buffcheck = self:HasBuff(myHero,"lucianpassivebuff")
		if buffcheck and buffcheck ~= lastbuff then
			lastbuff = buffcheck
			--PrintChat("Passive added : "..Game.Timer().." : "..lastbuff)
			passive = true
		end
		local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
		
		local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
		if harassactive and self.Menu.UseQHarass:Value() and self:CanCast(_Q) then self:Harass() end 
		
		
		if combomodeactive and _G.SDK.Orbwalker:CanMove() and Game.Timer() > lastbuff - 3 then 
			if self:CanCast(_E) and self.Menu.UseE:Value() and _G.SDK.Orbwalker:GetTarget() then
				self:CastSpell(HK_E,mousePos)
				return
			end
			if self:CanCast(_Q) and self.Menu.UseQ:Value() and _G.SDK.Orbwalker:GetTarget() then
				self:CastQ(_G.SDK.Orbwalker:GetTarget())
				return
			end
			if self:CanCast(_W) and self.Menu.UseW:Value() and _G.SDK.Orbwalker:GetTarget() then
				self:CastW(_G.SDK.Orbwalker:GetTarget())
				return
			end
			
			
		end
		
		if myHero.activeSpell and myHero.activeSpell.valid and 
		(myHero.activeSpell.name == "LucianQ" or myHero.activeSpell.name == "LucianW") then
			passive = true
			--PrintChat("found passive1")
		end
		
		
	end
	
	
	local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
	
	
	
	function EnableMovement()
		--unblock movement
		blockattack = false
		blockmovement = false
		onetimereset = true
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
	
	function Lucian:CastSpell(spell,pos)
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
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	
	--[[CastQ]]
	function Lucian:CastQ(target)
		if not _G.SDK then return end
		if target and self:CanCast(_Q) and passive == false then
			self:CastSpell(HK_Q, target.pos)
		end
	end
	
	--[[CastQ]]
	function Lucian:CastW(target)
		if not _G.SDK then return end
		if target and self:CanCast(_W) and passive == false then
			self:CastSpell(HK_W, target.pos)
		end
	end
	
	
	function Lucian:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Lucian:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Lucian:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	
	function Lucian:Harass()
		local temptarget = self:FarQTarget()
		if temptarget then
			self:CastSpell(HK_Q,temptarget.pos)
		end
	end
	
	
	
	
	function Lucian:FarQTarget()
		local qtarget = _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		if qtarget then
			local qdelay = 0.4 - myHero.levelData.lvl*0.01
			local pos = qtarget:GetPrediction(math.huge,qdelay)
			if not pos then return false end 
			minionlist = _G.SDK.ObjectManager:GetEnemyMinions(500)
			
			V = Vector(pos) - Vector(myHero.pos)
			
			Vn = V:Normalized()
			Distance = myHero.pos:DistanceTo(pos)
			tx, ty, tz = Vn:Unpack()
			TopX = pos.x - (tx * Distance)
			TopY = pos.y - (ty * Distance)
			TopZ = pos.z - (tz * Distance)
			
			Vr = V:Perpendicular():Normalized()
			Radius = qtarget.boundingRadius or 65
			tx, ty, tz = Vr:Unpack()
			
			LeftX = pos.x + (tx * Radius)
			LeftY = pos.y + (ty * Radius)
			LeftZ = pos.z + (tz * Radius)
			RightX = pos.x - (tx * Radius)
			RightY = pos.y - (ty * Radius)
			RightZ = pos.z - (tz * Radius)

			Left = Point(LeftX, LeftY, LeftZ)
			Right = Point(RightX, RightY, RightZ)
			Top = Point(TopX, TopY, TopZ)
			Poly = Polygon(Left, Right, Top)
			
			for i, minion in pairs(minionlist) do
				toPoint = Point(minion.pos.x, minion.pos.y,minion.pos.z)
				if Poly:__contains(toPoint) then
					return minion
				end
			end
		end
		return false 
	end
	
	
	function OnLoad()
		Lucian()
	end
	
end


if myHero.charName == "Caitlyn" then
	--[v1.0]]
	local Scriptname,Version,Author,LVersion = "TRUSt in my Caitlyn","v1.0","TRUS","7.6"
	
	class "Caitlyn"
	
	local qtarget
	
	function Caitlyn:__init()
		
		PrintChat("TRUSt in my Caitlyn "..Version.." - Loaded....")
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		
		
		if _G.SDK then
			_G.SDK.Orbwalker:OnPreMovement(function(arg) 
				if blockmovement then
					arg.Process = false
				end
			end)
			
			
			_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
				if blockattack then
					arg.Process = false
				end
			end)
		else
			PrintChat("This script support IC Orbwalker only")
			
		end
	end
	onetimereset = true
	blockattack = false
	blockmovement = false
	
	local lastpick = 0
	--[[Spells]]
	function Caitlyn:LoadSpells()
		Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000}
		E = {Range = 800, width = nil, Delay = 0.25, Radius = 80, Speed = 1600}
	end
	
	function Caitlyn:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyCaitlyn", name = Scriptname})
		self.Menu:MenuElement({id = "UseEQ", name = "UseEQ", key = string.byte("X")})
		self.Menu:MenuElement({id = "autoW", name = "Use W on cc", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Caitlyn:Tick()
		if myHero.dead or not _G.SDK then return end
		local useEQ = self.Menu.UseEQ:Value()
		if self:CanCast(_Q) and self:CanCast(_E) and useEQ then
			self:CastE(_G.SDK.Orbwalker:GetTarget())
		end
		if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "CaitlynEntrapment" and self:CanCast(_Q) and useEQ then
			Control.CastSpell(HK_Q,qtarget)
		end
		self:AutoW()
	end
	
	
	local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
	
	
	function ReturnCursor(pos)
		blockmovement = false
		blockattack = false 
		Control.SetCursorPos(pos)
		castSpell.state = 0
		
	end
	
	function LeftClick(pos)
		DelayAction(ReturnCursor,0.01,{pos})
	end
	
	function Caitlyn:Stunned(enemy)
		for i = 0, enemy.buffCount do
			local buff = enemy:GetBuff(i);
			if (buff.type == 5 or buff.type == 11 or buff.type == 24) and buff.duration > 0.5 then
				return true
			end
		end
		return false
	end
	
	function Caitlyn:AutoW()
		if not self.Menu.autoW:Value() then return end
		local ImmobileEnemy = self:GetImmobileTarget()
		if ImmobileEnemy and myHero.pos:DistanceTo(ImmobileEnemy.pos)<800 and (not LastW or LastW:DistanceTo(ImmobileEnemy.pos)>60) then
			LastW = ImmobileEnemy.pos
			self:CastSpell(HK_W,ImmobileEnemy.pos)
		end
	end
	
	function Caitlyn:CastSpell(spell,pos)
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
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker
				end
			end
		end
	end
	
	
	function Caitlyn:GetImmobileTarget()
		local GetEnemyHeroes = _G.SDK.ObjectManager:GetEnemyHeroes(800)
		local Target = nil
		for i = 1, #GetEnemyHeroes do
			local Enemy = GetEnemyHeroes[i]
			if Enemy and self:Stunned(Enemy) then
				return Enemy
			end
		end
		return false
	end
	
	function QCombo(pos)
		Control.SetCursorPos(pos)
		Control.KeyDown(HK_Q)
		Control.KeyUp(HK_Q)
	end
	
	function Caitlyn:CastCombo(pos)
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				--block movement
				blockmovement = true
				blockattack = true
				Control.SetCursorPos(pos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
				DelayAction(QCombo,0.01,{pos})
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker
			end
		end
	end
	
	
	--[[CastEQ]]
	function Caitlyn:CastE(target)
		if not _G.SDK then return end
		local target = target or _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		if target and target:GetCollision(E.Radius,E.Speed,E.Delay) == 0 then
			local castPos = target:GetPrediction(E.Speed, E.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastCombo(newpos)
			qtarget = newpos
		end
	end
	
	
	function Caitlyn:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Caitlyn:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Caitlyn:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function OnLoad()
		Caitlyn()
	end
	
end

if myHero.charName == "Ezreal" then
	--[v1.0]]
	local Scriptname,Version,Author,LVersion = "TRUSt in my Ezreal","v1.0","TRUS","7.6"
	
	class "Ezreal"
	
	
	
	function Ezreal:__init()
		
		PrintChat("TRUSt in my Ezreal "..Version.." - Loaded....")
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		
		
		if _G.SDK then
			_G.SDK.Orbwalker:OnPreMovement(function(arg) 
				if blockmovement then
					arg.Process = false
				end
			end)
			
			_G.SDK.Orbwalker:OnPostAttack(function() 
				self:CastQ(_G.SDK.Orbwalker:GetTarget())
			end)
			
			_G.SDK.Orbwalker:OnPreAttack(function(arg) 		
				if blockattack then
					arg.Process = false
				end
			end)
		else
			PrintChat("This script support IC Orbwalker only")
			
		end
	end
	onetimereset = true
	blockattack = false
	blockmovement = false
	
	local lastpick = 0
	--[[Spells]]
	function Ezreal:LoadSpells()
		Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
	end
	
	function Ezreal:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyEzreal", name = Scriptname})
		self.Menu:MenuElement({id = "UseQ", name = "UseQ", key = string.byte("V")})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Ezreal:Tick()
		if myHero.dead or not _G.SDK then return end
		
		if self:CanCast(_Q) and self.Menu.UseQ:Value() and (_G.SDK.Orbwalker:CanMove() or not _G.SDK.Orbwalker:GetTarget()) then
			self:CastQ()
		end
		
		
	end
	
	
	local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
	
	
	
	function EnableMovement()
		--unblock movement
		blockattack = false
		blockmovement = false
		onetimereset = true
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
	
	function Ezreal:CastSpell(spell,pos)
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
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	
	--[[CastQ]]
	function Ezreal:CastQ(target)
		if not _G.SDK then return end
		local target = target or _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		if target and target.type == "AIHeroClient" and self:CanCast(_Q) and self.Menu.UseQ:Value() and target:GetCollision(Q.Radius,Q.Speed,Q.Delay) == 0 then
			local castPos = target:GetPrediction(Q.Speed,Q.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, newpos)
		end
	end
	
	
	function Ezreal:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Ezreal:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Ezreal:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	function OnLoad()
		Ezreal()
	end
end