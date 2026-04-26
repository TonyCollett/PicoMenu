local BLOCKED_IN_COMBAT = "UI Action Blocked"
local UpdateMicroMenuVisibility

local function IsBlockedInCombat()
    return InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")
end

local function ShowBlockedInCombatMessage()
    UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
end

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
            if not IsBlockedInCombat() then
                ToggleSpellBook(BOOKTYPE_SPELL)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        disabled = IsBlockedInCombat,
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
        isSeparator = true,
    },
    {
        text = COMMUNITIES_FRAME_TITLE,
        icon = "Interface\\GossipFrame\\TabardGossipIcon",
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
            PVEFrame_ToggleFrame("ChallengesFrame", nil)
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
    }, {
    isSeparator = true,
},
    {
        text = HOUSING_DASHBOARD_FRAMETITLE,
        icon = "Interface\\GossipFrame\\BinderGossipIcon",
        func = function()
            if not IsBlockedInCombat() then
                HousingMicroButton:Click()
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        isSeparator = true,
    },
    {
        text = MOUNTS,
        icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
        func = function()
            if not IsBlockedInCombat() then
                ToggleCollectionsJournal(1)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = PETS,
        icon = "Interface\\ICONS\\Tracking_WildPet",
        func = function()
            if not IsBlockedInCombat() then
                ToggleCollectionsJournal(2)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = TOY_BOX,
        icon = "Interface\\MINIMAP\\TRACKING\\Reagents",
        func = function()
            if not IsBlockedInCombat() then
                ToggleCollectionsJournal(3)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = HEIRLOOMS,
        icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
        func = function()
            if not IsBlockedInCombat() then
                ToggleCollectionsJournal(4)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = WARDROBE,
        icon = "Interface\\Icons\\INV_Chest_Cloth_17",
        func = function()
            if not IsBlockedInCombat() then
                ToggleCollectionsJournal(5)
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        isSeparator = true,
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
            StoreMicroButton:Click()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        isSeparator = true,
    },
    {
        text = BATTLEFIELD_MINIMAP,
        -- colorCode = "|cff999999",
        checked = function()
            return BattlefieldMapFrame and BattlefieldMapFrame:IsShown()
        end,
        func = function()
            ToggleBattlefieldMap()
        end,
        keepShownOnClick = true,
        isNotRadio = true,
        notCheckable = false,
        fontObject = Game13Font,
    },
    {
        text = "Show Main Menu",
        checked = function()
            return PicoMenuDB.showMicromenu
        end,
        func = function()
            PicoMenuDB.showMicromenu = not PicoMenuDB.showMicromenu
            UpdateMicroMenuVisibility()
        end,
        keepShownOnClick = true,
        isNotRadio = true,
        notCheckable = false,
        fontObject = Game13Font,
    },
}

local picoMenuContextMenu
local lastPicoMenuHideTime = 0

UpdateMicroMenuVisibility = function()
    if PicoMenuDB.showMicromenu then
        MicroMenu:Show()
        PetBattleFrame.BottomFrame.MicroButtonFrame:Show()
    else
        MicroMenu:Hide()
        PetBattleFrame.BottomFrame.MicroButtonFrame:Hide()
    end
end

local function GetMenuItemText(item)
    if item.icon then
        return "|T" .. item.icon .. ":0|t " .. item.text
    end
    return item.text
end

local function IsItemDisabled(item)
    if type(item.disabled) == "function" then
        return item.disabled()
    end
    return item.disabled == true
end

local function OpenPicoMenu(anchor)
    if not MenuUtil or not MenuUtil.CreateContextMenu then
        return nil
    end

    local menu
    menu = MenuUtil.CreateContextMenu(anchor, function(_, rootDescription)
        rootDescription:SetTag("PicoMenu")

        for _, item in ipairs(menuList) do
            if item.isSeparator then
                rootDescription:CreateDivider()
            elseif item.isTitle then
                rootDescription:CreateTitle(GetMenuItemText(item))
            elseif item.checked then
                local checkbox = rootDescription:CreateCheckbox(GetMenuItemText(item), item.checked, item.func)
                if item.keepShownOnClick and MenuResponse and MenuResponse.Refresh then
                    checkbox:SetResponse(MenuResponse.Refresh)
                end
                if IsItemDisabled(item) then
                    checkbox:SetEnabled(false)
                end
            else
                local button = rootDescription:CreateButton(GetMenuItemText(item), item.func)
                if IsItemDisabled(item) then
                    button:SetEnabled(false)
                end
            end
        end
    end)

    menu:SetPoint("BOTTOM", anchor, "TOP", 0, 8)
    menu:HookScript("OnHide", function()
        lastPicoMenuHideTime = GetTime()
    end)
    return menu
end

-- Pico Menu Button
local picoMenu = CreateFrame("Button", nil, MainActionBar)
picoMenu:SetFrameStrata("MEDIUM")
picoMenu:SetFrameLevel(150)
picoMenu:Raise()
picoMenu:SetSize(40, 40)
picoMenu:SetPoint("CENTER", MainActionBar.EndCaps.RightEndCap, -15, 0)
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
        self.menuWasOpenOnMouseDown = picoMenuContextMenu and picoMenuContextMenu:IsShown()
    end

    GameTooltip:Hide()
end)

picoMenu:SetScript("OnMouseUp", function(self, button)
    self:GetNormalTexture():ClearAllPoints()
    self:GetNormalTexture():SetPoint("CENTER")

    if not self:IsMouseOver() then
        self.menuWasOpenOnMouseDown = false
        return
    end

    if button == "LeftButton" then
        local justClosed = (GetTime() - lastPicoMenuHideTime) < 0.1
        if self.menuWasOpenOnMouseDown or justClosed then
            if picoMenuContextMenu and picoMenuContextMenu:IsShown() then
                picoMenuContextMenu:Close()
            end
        elseif picoMenuContextMenu and picoMenuContextMenu:IsShown() then
            picoMenuContextMenu:Close()
        else
            picoMenuContextMenu = OpenPicoMenu(self)
        end
    else
        if not GameMenuFrame:IsVisible() then
            ShowUIPanel(GameMenuFrame)
        else
            HideUIPanel(GameMenuFrame)
        end
    end

    self.menuWasOpenOnMouseDown = false
end)

picoMenu:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

picoMenu:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "PicoMenu" then
            UpdateMicroMenuVisibility()
        end
    elseif event == "PET_BATTLE_OPENING_START" then
        if picoMenuContextMenu and picoMenuContextMenu:IsShown() then
            picoMenuContextMenu:Close()
        end
        picoMenu:SetParent(PetBattleFrame)
        picoMenu:SetSize(50, 50)
        picoMenu:SetPoint("CENTER", PetBattleFrame.BottomFrame.MicroButtonFrame, 0, 0)
        picoMenu:GetNormalTexture():SetSize(50, 50)
        picoMenu:SetFrameStrata("MEDIUM")
        picoMenu:SetFrameLevel(150)
        UpdateMicroMenuVisibility()
    elseif event == "PET_BATTLE_CLOSE" then
        if picoMenuContextMenu and picoMenuContextMenu:IsShown() then
            picoMenuContextMenu:Close()
        end
        picoMenu:SetParent(MainActionBar)
        picoMenu:SetSize(40, 40)
        picoMenu:SetPoint("CENTER", MainActionBar.EndCaps.RightEndCap, -15, 0)
        picoMenu:GetNormalTexture():SetSize(40, 40)
        picoMenu:SetFrameStrata("MEDIUM")
        picoMenu:SetFrameLevel(150)
        UpdateMicroMenuVisibility()
    end
end)

-- Move Ticket Icon
HelpOpenWebTicketButton:ClearAllPoints()
HelpOpenWebTicketButton:SetPoint("LEFT", picoMenu, "RIGHT", 0, 0)
HelpOpenWebTicketButton:SetScale(0.8)
HelpOpenWebTicketButton:SetParent(picoMenu)

-- Hide MicroButtonAndBagsBar
UpdateMicroMenuVisibility()
