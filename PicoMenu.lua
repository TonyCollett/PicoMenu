local _ = ...

    -- Pico Menu Dropdown

local BLOCKED_IN_COMBAT = "UI Action Blocked"

local menuFrame = CreateFrame("Frame", "picomenuDropDownMenu", MainMenuBar.EndCaps, "UIDropDownMenuTemplate")

local menuList = {
    {
        text = MAINMENU_BUTTON,
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = CHARACTER_BUTTON,
        icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
        func = function()
            ToggleCharacter("PaperDollFrame")
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = SPELLBOOK_ABILITIES_BUTTON,
        icon = "Interface\\MINIMAP\\TRACKING\\Class",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleSpellBook(BOOKTYPE_SPELL)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        disabled = (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))),
        fontObject = Game13Font,
    },
    {
        text = TALENTS,
        icon = "Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuTalents",
        func = function()
            ToggleTalentFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = ACHIEVEMENT_BUTTON,
        icon = "Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuAchievement",
        func = function()
            ToggleAchievementFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = QUESTLOG_BUTTON,
        icon = "Interface\\GossipFrame\\ActiveQuestIcon",
        func = function()
            ToggleQuestLog()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = "                               ",
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = COMMUNITIES_FRAME_TITLE,
        icon = "Interface\\GossipFrame\\TabardGossipIcon",
        arg1 = IsInGuild("player"),
        func = function()
            ToggleGuildFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = SOCIAL_BUTTON,
        icon = "Interface\\FriendsFrame\\PlusManz-BattleNet",
        func = function()
            ToggleFriendsFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = PLAYER_V_PLAYER,
        icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
        func = function()
            TogglePVPUI()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = DUNGEONS_BUTTON,
        icon = "Interface\\LFGFRAME\\BattleNetWorking0",
        func = function()
            ToggleLFDParentFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = CHALLENGES,
        icon = "Interface\\BUTTONS\\UI-GroupLoot-DE-Up",
        func = function()
            PVEFrame_ToggleFrame("ChallengesFrame",nil)
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = RAID,
        icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
        func = function()
            ToggleRaidFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = ENCOUNTER_JOURNAL,
        icon = "Interface\\MINIMAP\\TRACKING\\Profession",
        func = function()
            ToggleEncounterJournal(1)
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = "                               ",
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = MOUNTS,
        icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleCollectionsJournal(1)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = PETS,
        icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleCollectionsJournal(2)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = TOY_BOX,
        icon = "Interface\\MINIMAP\\TRACKING\\Reagents",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleCollectionsJournal(3)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = HEIRLOOMS,
        icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleCollectionsJournal(4)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    
    {
        text = WARDROBE,
        icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
        func = function()
            if not (InCombatLockdown() or (UnitAffectingCombat("player") or UnitAffectingCombat("pet"))) then
                ToggleCollectionsJournal(5)
            else
                UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = "                               ",
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = GM_EMAIL_NAME,
        icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
        func = function()
            ToggleHelpFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = BLIZZARD_STORE,
        icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
        func = function()
            ToggleStoreUI()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = "                               ",
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = BATTLEFIELD_MINIMAP,
        -- colorCode = "|cff999999",
        func = function()
            ToggleBattlefieldMap()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
}

local addonMenuTable = {
    {
        text = "                               ",
        isTitle = true,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {   text = ADDONS,
        hasArrow = true,
        notCheckable = true,
        fontObject = Game13Font,
        menuList = {
            {
                text = ADDONS,
                isTitle = true,
                notCheckable = true,
                fontObject = Game13Font,
            },
        }
    }
}

-- Pico Menu Button
local picoMenu = CreateFrame("Button", nil, MainMenuBar)
picoMenu:SetFrameStrata("MEDIUM")
picoMenu:SetFrameLevel(150)
picoMenu:Raise()
picoMenu:SetSize(40, 40)
picoMenu:SetPoint("CENTER", MainMenuBar.EndCaps.RightEndCap, -15, 0)
picoMenu:RegisterForClicks("Anyup")
picoMenu:RegisterEvent("ADDON_LOADED")
picoMenu:RegisterEvent("PET_BATTLE_OPENING_START")
picoMenu:RegisterEvent("PET_BATTLE_CLOSE")

picoMenu:SetNormalTexture("Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuNormal")
picoMenu:GetNormalTexture():SetSize(40, 40)

picoMenu:SetHighlightTexture("Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuHighlight")
picoMenu:GetHighlightTexture():SetAllPoints(picoMenu:GetNormalTexture())

picoMenu:SetScript("OnMouseDown", function(self, button)
    self:GetNormalTexture():ClearAllPoints()
    self:GetNormalTexture():SetPoint("CENTER", 1, -1)
    
    if button == "LeftButton" then
        if self:IsMouseOver() then
            if DropDownList1:IsShown() then
                DropDownList1:Hide()
            else
                EasyMenu(menuList, menuFrame, self, 30, 200, "MENU", 5)
            end
        end
    else
        if self:IsMouseOver() then
            if not GameMenuFrame:IsVisible() then
                ShowUIPanel(GameMenuFrame)
            else
                HideUIPanel(GameMenuFrame)
            end
        end
    end

    GameTooltip:Hide()
end)

picoMenu:SetScript("OnMouseUp", function(self)
    self:GetNormalTexture():ClearAllPoints()
    self:GetNormalTexture():SetPoint("CENTER")
end)

picoMenu:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

picoMenu:SetScript("OnEvent", function(self, event, ...)
    if event == "PET_BATTLE_OPENING_START" then
        picoMenu:SetParent(PetBattleFrame)
        picoMenu:SetSize(50, 50)
        picoMenu:SetPoint("CENTER", PetBattleFrame.BottomFrame.MicroButtonFrame, 0, 0)
        picoMenu:GetNormalTexture():SetSize(50, 50)
        picoMenu:SetFrameStrata("MEDIUM")
        picoMenu:SetFrameLevel(150)
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint("LEFT", picoMenu, "RIGHT", 0, 0)
    elseif event == "PET_BATTLE_CLOSE" then
        picoMenu:SetParent(MainMenuBar)
        picoMenu:SetSize(40, 40)
        picoMenu:SetPoint("CENTER", MainMenuBar.EndCaps.RightEndCap, -15, 0)
        picoMenu:GetNormalTexture():SetSize(40, 40)
        picoMenu:SetFrameStrata("MEDIUM")
        picoMenu:SetFrameLevel(150)
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint("BOTTOM", picoMenu, "TOP", 0, 0)
    end
end)

-- Move Ticket Icon
HelpOpenWebTicketButton:ClearAllPoints()
HelpOpenWebTicketButton:SetPoint("LEFT", picoMenu, "RIGHT", 0, 0)
HelpOpenWebTicketButton:SetScale(0.8)
HelpOpenWebTicketButton:SetParent(picoMenu)

-- Hide MicroButtonAndBagsBar
MicroMenu:Hide()
PetBattleFrame.BottomFrame.MicroButtonFrame:Hide()

-- Move QueueStatusButton
QueueStatusButton:ClearAllPoints()
QueueStatusButton:SetParent(picoMenu)
QueueStatusButton:SetPoint("BOTTOM", picoMenu, "TOP", 0, 0)
QueueStatusButton:SetScale(0.8)
QueueStatusButton:SetFrameStrata("MEDIUM")
QueueStatusButton:SetFrameLevel(150)
