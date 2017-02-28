class "IHateCC"
local Scriptname,Version,Author,LVersion = "IHateCC","v1.0","TRUS","7.4"
local function GrabSummSpell(summName)
  local retval = 0;
  local spellName = myHero:GetSpellData(SUMMONER_1).name;
  if spellName == summName then
    retval = SUMMONER_1;
  else
    local spellName = myHero:GetSpellData(SUMMONER_2).name;
    if spellName == summName then
      retval = SUMMONER_2;
    end
  end
  return retval
end
keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [_W] = HK_W, [_R] = HK_R }

function IHateCC:__init()
  self:LoadMenu()
  Callback.Add("Tick", function() self:Tick() end)
end

function IHateCC:LoadMenu()
  self.IHateCCMenu = MenuElement({type = MENU, id = "IHateCCMenu", name = Scriptname, leftIcon = "http://vignette4.wikia.nocookie.net/leagueoflegends/images/f/f9/Quicksilver_Sash_item.png"})
  self.IHateCCMenu:MenuElement({id = "CCTypes", name = "Control to cleanse", type = MENU})
  self.IHateCCMenu.CCTypes:MenuElement({id = "STUNS", name = "STUNS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "SILENCE", name = "SILENCE", value = false})
  self.IHateCCMenu.CCTypes:MenuElement({id = "TAUNTS", name = "TAUNTS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "FEARS", name = "FEARS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "CHARMS", name = "CHARMS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "BLINDS", name = "BLINDS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "ROOTS", name = "ROOTS", value = false})
  self.IHateCCMenu.CCTypes:MenuElement({id = "DISARMS", name = "DISARMS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "SLOWS", name = "SLOWS", value = false})
  self.IHateCCMenu.CCTypes:MenuElement({id = "SUPPRESS", name = "SUPPRESS", value = true})
  self.IHateCCMenu.CCTypes:MenuElement({id = "Exhaust", name = "Exhaust", value = true})
  self.IHateCCMenu:MenuElement({id = "duration", name = "Min CC duration", value = 1.5, min = 0, max = 3, step = 0.1, identifier = ""})

  self.IHateCCMenu:MenuElement({id = "Enabled", name = "Always enabled", value = false})
  self.IHateCCMenu:MenuElement({id = "HKEnabled", name = "Enable when keypressed", key = 32})

  cleanseslotS = GrabSummSpell("SummonerBoost")
  if myHero.charName == "Gangplank" then
    cleanseslotS2 = _W
  elseif myHero.charName == "Olaf" then
    cleanseslotS2 = _R
  else
    cleanseslotS2 = nil
  end

end


function IHateCC:GetInventorySlotItem(itemID, target)
  assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
  local target = target or myHero
  for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7 }) do
    if target:GetItemData(j).itemID == itemID then return j end
  end
  return nil
end



function IHateCC:UseCleanse(cleanseslot)
  Control.CastSpell(keybindings[cleanseslot]);
end
function IHateCC:IsReady(spellSlot)
  return myHero:GetSpellData(spellSlot).currentCd == 0
end

function IHateCC:Tick()
  cleanseslotS = self:GetInventorySlotItem(3140) or self:GetInventorySlotItem(3139);
  if self.IHateCCMenu.Enabled:Value() == false and self.IHateCCMenu.HKEnabled:Value() == false then return end
  if cleanseslotS2 and self:IsReady(cleanseslotS2) then
    cleanseslot = cleanseslotS2

  elseif cleanseslotS and self:IsReady(cleanseslotS) then
    cleanseslot = cleanseslotS
  else
    cleanseslot = nil
    return
  end

  for i = 0, 63 do
    local buff = myHero:GetBuff(i);
    if buff.count > 0 then
      if buff.duration>=self.IHateCCMenu.duration:Value() then
        if ((buff.type == 5 and self.IHateCCMenu.CCTypes.STUNS:Value())
        or 	(buff.type == 7 and  self.IHateCCMenu.CCTypes.SILENCE:Value())
        or (buff.type == 8 and  self.IHateCCMenu.CCTypes.TAUNTS:Value())
        or (buff.type == 21 and  self.IHateCCMenu.CCTypes.FEARS:Value())
        or (buff.type == 22 and  self.IHateCCMenu.CCTypes.CHARMS:Value())
        or (buff.type == 25 and  self.IHateCCMenu.CCTypes.BLINDS:Value())
        or (buff.type == 11 and  self.IHateCCMenu.CCTypes.ROOTS:Value())
        or (buff.type == 24 and  self.IHateCCMenu.CCTypes.SUPPRESS:Value())
        or (buff.type == 10 and  self.IHateCCMenu.CCTypes.SLOWS:Value())) then
          self:UseCleanse(cleanseslot)
        elseif buff.name == "SummonerExhaust" and self.IHateCCMenu.CCTypes.Exhaust:Value() then
          self:UseCleanse(cleanseslot)
        end
      end
    end
  end
end

function OnLoad()
  IHateCC()
end