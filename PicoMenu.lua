local BLOCKED_IN_COMBAT = "UI Action Blocked"
local UpdateMicroMenuVisibility
local UpdateQueueEyePosition
local UpdatePicoMenuVisibility

local function IsBlockedInCombat()
    return InCombatLockdown() or UnitAffectingCombat("player") or UnitAffectingCombat("pet")
end

local function ShowBlockedInCombatMessage()
    UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
end

local function IsAddOnLoadedCompat(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    return IsAddOnLoaded and IsAddOnLoaded(name)
end

local function EnsureAddOn(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.LoadAddOn then
        if not C_AddOns.IsAddOnLoaded(name) then
            C_AddOns.LoadAddOn(name)
        end
    elseif UIParentLoadAddOn then
        UIParentLoadAddOn(name)
    end
end

-- Guards against missing functions and keeps the callee's taint from spreading back
-- to us. It does NOT make the call secure: called from a menu callback, fn still runs tainted.
local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return false
    end
    if securecallfunction then
        securecallfunction(fn, ...)
    else
        fn(...)
    end
    return true
end

-- The Spellbook and Talent frames were merged into PlayerSpellsFrame in 11.0, so
-- prefer the tab-targeted PlayerSpellsUtil calls and keep the old globals as a fallback.
local function TogglePlayerSpellsTab(toggleFuncName, frameTab, legacyToggle, ...)
    EnsureAddOn("Blizzard_PlayerSpells")

    if PlayerSpellsUtil then
        if SafeCall(PlayerSpellsUtil[toggleFuncName]) then
            return
        end
        local tab = PlayerSpellsUtil.FrameTabs and PlayerSpellsUtil.FrameTabs[frameTab]
        if tab and SafeCall(TogglePlayerSpellsFrame, tab) then
            return
        end
    end

    if SafeCall(legacyToggle, ...) then
        return
    end

    if PlayerSpellsMicroButton then
        SafeCall(PlayerSpellsMicroButton.Click, PlayerSpellsMicroButton, "LeftButton", true)
    end
end

local function OpenSpellbook()
    TogglePlayerSpellsTab("ToggleSpellBookFrame", "SpellBook", ToggleSpellBook, BOOKTYPE_SPELL)
end

local function OpenTalents()
    TogglePlayerSpellsTab("ToggleClassTalentFrame", "ClassTalents", ToggleTalentFrame)
end

local function OpenProfessions()
    EnsureAddOn("Blizzard_ProfessionsBook")
    SafeCall(ToggleProfessionsBook)
end

local function OpenGreatVault()
    EnsureAddOn("Blizzard_WeeklyRewards")
    SafeCall(WeeklyRewards_ShowUI)
end

local function OpenCalendar()
    EnsureAddOn("Blizzard_Calendar")
    SafeCall(ToggleCalendar)
end

-- Binding hints. An unbound or unknown binding just yields no hint, so a binding
-- name that changes in a future patch degrades quietly instead of erroring.
local function GetBindingHint(bindingName)
    if not bindingName or not GetBindingKey then
        return nil
    end

    local key = GetBindingKey(bindingName)
    if not key or key == "" then
        return nil
    end

    if GetBindingText then
        key = GetBindingText(key, "KEY_") or key
    end
    return key
end

-- Alert sources. Each is wrapped in pcall at the call site: these poke at APIs that
-- Blizzard reshuffles between expansions, and a broken alert must not break the button.
local function HasGreatVaultRewards()
    return C_WeeklyRewards and C_WeeklyRewards.HasAvailableRewards and C_WeeklyRewards.HasAvailableRewards()
end

-- Leftover currency on its own is a false positive: capped and hero talent currencies
-- can sit above zero with nothing left to buy. Confirm a genuinely purchasable node
-- exists, the way Plumber's API.HasAnyPurchasableTraitInSystem does.
local function HasUnspentTalentPoints()
    if not C_ClassTalents or not C_Traits then
        return false
    end

    local configID = C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
    if not configID then
        return false
    end

    local configInfo = C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(configID)
    local treeID = configInfo and configInfo.treeIDs and configInfo.treeIDs[1]
    if not treeID then
        return false
    end

    -- Include staged changes, so points spent but not yet applied still count as spent.
    local currencies = C_Traits.GetTreeCurrencyInfo(configID, treeID, false)
    local unspent = currencies and currencies[1] and currencies[1].quantity or 0
    if unspent <= 0 then
        return false
    end

    for _, nodeID in ipairs(C_Traits.GetTreeNodes(treeID) or {}) do
        local costs = C_Traits.GetNodeCost(configID, nodeID)
        -- Assume a single currency type, as the talent trees do.
        local affordable = (not costs) or (#costs == 0) or (unspent >= costs[1].amount)
        if affordable then
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            for _, entryID in ipairs(nodeInfo and nodeInfo.entryIDs or {}) do
                if C_Traits.CanPurchaseRank(configID, nodeID, entryID) then
                    return true
                end
            end
        end
    end

    return false
end

local alertSources = {
    { label = "Great Vault rewards available", check = HasGreatVaultRewards },
    { label = "Unspent talent points", check = HasUnspentTalentPoints },
}

local function GetActiveAlerts()
    local active = {}
    for _, source in ipairs(alertSources) do
        local ok, result = pcall(source.check)
        if ok and result then
            table.insert(active, source.label)
        end
    end
    return active
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
        binding = "TOGGLECHARACTER0",
        icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
        func = function()
            ToggleCharacter("PaperDollFrame")
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = SPELLBOOK_ABILITIES_BUTTON,
        binding = "TOGGLESPELLBOOK",
        icon = "Interface\\MINIMAP\\TRACKING\\Class",
        func = function()
            if not IsBlockedInCombat() then
                OpenSpellbook()
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
        binding = "TOGGLETALENTS",
        icon = "Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuTalents",
        func = function()
            if not IsBlockedInCombat() then
                OpenTalents()
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        disabled = IsBlockedInCombat,
        fontObject = Game13Font,
    },
    {
        text = TRADE_SKILLS or "Professions",
        binding = "TOGGLEPROFESSIONBOOK",
        icon = "Interface\\ICONS\\Trade_BlackSmithing",
        func = function()
            if not IsBlockedInCombat() then
                OpenProfessions()
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        disabled = IsBlockedInCombat,
        fontObject = Game13Font,
    },
    {
        text = ACHIEVEMENT_BUTTON,
        binding = "TOGGLEACHIEVEMENT",
        icon = "Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuAchievement",
        func = function()
            ToggleAchievementFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = QUESTLOG_BUTTON,
        binding = "TOGGLEQUESTLOG",
        icon = "Interface\\GossipFrame\\ActiveQuestIcon",
        func = function()
            ToggleQuestLog()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = CALENDAR or "Calendar",
        icon = "Interface\\Calendar\\MeetingIcon",
        func = function()
            OpenCalendar()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        isSeparator = true,
    },
    {
        text = COMMUNITIES_FRAME_TITLE,
        binding = "TOGGLEGUILDTAB",
        icon = "Interface\\GossipFrame\\TabardGossipIcon",
        func = function()
            ToggleGuildFrame()
        end,
        notCheckable = true,
        fontObject = Game13Font,
    },
    {
        text = SOCIAL_BUTTON,
        binding = "TOGGLESOCIAL",
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
        binding = "TOGGLEGROUPFINDER",
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
        text = GREAT_VAULT_REWARDS or WEEKLY_REWARDS or "Great Vault",
        icon = "Interface\\ICONS\\INV_Misc_TreasureChest02c",
        func = function()
            if not IsBlockedInCombat() then
                OpenGreatVault()
            else
                ShowBlockedInCombatMessage()
            end
        end,
        notCheckable = true,
        disabled = IsBlockedInCombat,
        fontObject = Game13Font,
    },
    {
        text = RAID,
        icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
        func = function()
            if IsBlockedInCombat() then
                ShowBlockedInCombatMessage()
                return
            end
            -- If our call is the one that loads Blizzard_RaidUI, its secure raid group
            -- buttons are created tainted and later Hide() calls get blocked and blamed
            -- on us. Until Blizzard has loaded it, open Social and let the user click
            -- the Raid tab so the load happens on a secure path.
            if IsAddOnLoadedCompat("Blizzard_RaidUI") then
                ToggleRaidFrame()
            else
                ToggleFriendsFrame()
            end
        end,
        notCheckable = true,
        disabled = IsBlockedInCombat,
        fontObject = Game13Font,
    },
    {
        text = ENCOUNTER_JOURNAL,
        binding = "TOGGLEENCOUNTERJOURNAL",
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
        binding = "TOGGLECOLLECTIONS",
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
        text = SETTINGS,
        icon = "Interface\\Buttons\\UI-OptionsButton",
        notCheckable = true,
        fontObject = Game13Font,
        submenu = {
            {
                text = BATTLEFIELD_MINIMAP,
                binding = "TOGGLEBATTLEFIELDMINIMAP",
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
            {
                text = "Show Pico Menu Button",
                checked = function()
                    return PicoMenuDB.showPicomenu
                end,
                func = function()
                    PicoMenuDB.showPicomenu = not PicoMenuDB.showPicomenu
                    UpdatePicoMenuVisibility()
                    -- Hiding the button hides the only way back to this checkbox.
                    if not PicoMenuDB.showPicomenu then
                        print("|cff00ff00PicoMenu|r: button hidden. Type |cffffff00/pico|r to bring it back.")
                    end
                end,
                keepShownOnClick = true,
                isNotRadio = true,
                notCheckable = false,
                fontObject = Game13Font,
            },
            {
                isSeparator = true,
            },
            {
                text = RELOADUI or "Reload UI",
                icon = "Interface\\ICONS\\INV_Misc_Gear_01",
                func = function()
                    if not IsBlockedInCombat() then
                        ReloadUI()
                    else
                        ShowBlockedInCombatMessage()
                    end
                end,
                notCheckable = true,
                disabled = IsBlockedInCombat,
                fontObject = Game13Font,
            },
        },
    },
}

local picoMenuContextMenu
local lastPicoMenuHideTime = 0

-- Blizzard_PetBattleUI is load-on-demand, so PetBattleFrame is absent until the first pet battle.
local function GetPetBattleMicroButtonFrame()
    return PetBattleFrame and PetBattleFrame.BottomFrame and PetBattleFrame.BottomFrame.MicroButtonFrame
end

UpdateMicroMenuVisibility = function()
    local petBattleMicroButtons = GetPetBattleMicroButtonFrame()
    if PicoMenuDB.showMicromenu then
        if MicroMenu then MicroMenu:Show() end
        if petBattleMicroButtons then petBattleMicroButtons:Show() end
    else
        if MicroMenu then MicroMenu:Hide() end
        if petBattleMicroButtons then petBattleMicroButtons:Hide() end
    end
    UpdateQueueEyePosition()
end

local function GetMenuItemText(item)
    local text = item.text
    if item.icon then
        text = "|T" .. item.icon .. ":0|t " .. text
    end

    -- Read live rather than caching, so rebinding a key is reflected the next time
    -- the menu opens without needing a reload.
    local hint = GetBindingHint(item.binding)
    if hint then
        text = text .. "  |cff808080" .. hint .. "|r"
    end
    return text
end

local function IsItemDisabled(item)
    if type(item.disabled) == "function" then
        return item.disabled()
    end
    return item.disabled == true
end

local AddMenuItems

local function AddMenuItem(description, item)
    if item.isSeparator then
        description:CreateDivider()
    elseif item.isTitle then
        description:CreateTitle(GetMenuItemText(item))
    elseif item.submenu then
        local submenu = description:CreateButton(GetMenuItemText(item))
        AddMenuItems(submenu, item.submenu)
        if IsItemDisabled(item) then
            submenu:SetEnabled(false)
        end
    elseif item.checked then
        local checkbox = description:CreateCheckbox(GetMenuItemText(item), item.checked, item.func)
        if item.keepShownOnClick and MenuResponse and MenuResponse.Refresh then
            checkbox:SetResponse(MenuResponse.Refresh)
        end
        if IsItemDisabled(item) then
            checkbox:SetEnabled(false)
        end
    else
        local button = description:CreateButton(GetMenuItemText(item), item.func)
        if IsItemDisabled(item) then
            button:SetEnabled(false)
        end
    end
end

AddMenuItems = function(description, items)
    for _, item in ipairs(items) do
        AddMenuItem(description, item)
    end
end

local function OpenPicoMenu(anchor)
    if not MenuUtil or not MenuUtil.CreateContextMenu then
        return nil
    end

    local menu
    menu = MenuUtil.CreateContextMenu(anchor, function(_, rootDescription)
        rootDescription:SetTag("PicoMenu")

        AddMenuItems(rootDescription, menuList)
    end)

    menu:SetPoint("BOTTOM", anchor, "TOP", 0, 8)
    menu:HookScript("OnHide", function()
        lastPicoMenuHideTime = GetTime()
    end)
    return menu
end

-- Pico Menu Button
local picoMenu = CreateFrame("Button", "PicoMenuButton", UIParent)
picoMenu:SetFrameStrata("MEDIUM")
picoMenu:SetFrameLevel(150)
picoMenu:Raise()
picoMenu:SetSize(40, 40)
picoMenu:RegisterForClicks("Anyup")
picoMenu:RegisterEvent("PLAYER_LOGIN")
picoMenu:RegisterEvent("PET_BATTLE_OPENING_START")
picoMenu:RegisterEvent("PET_BATTLE_CLOSE")
picoMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
picoMenu:RegisterEvent("WEEKLY_REWARDS_UPDATE")
picoMenu:RegisterEvent("TRAIT_CONFIG_UPDATED")
picoMenu:RegisterEvent("PLAYER_LEVEL_UP")

picoMenu:SetNormalTexture("Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuNormal")
picoMenu:GetNormalTexture():SetSize(40, 40)

picoMenu:SetHighlightTexture("Interface\\AddOns\\PicoMenu\\Media\\picomenu\\picomenuHighlight")
picoMenu:GetHighlightTexture():SetAllPoints(picoMenu:GetNormalTexture())

-- Alert indicator. Hiding the Main Menu also hides Blizzard's own micro button
-- alerts, so surface anything that wants attention on the Pico Menu button itself.
local alertIndicator = picoMenu:CreateTexture(nil, "OVERLAY")
alertIndicator:SetTexture("Interface\\COMMON\\Indicator-Yellow")
alertIndicator:SetSize(14, 14)
alertIndicator:SetPoint("TOPRIGHT", picoMenu, "TOPRIGHT", 1, 1)
alertIndicator:Hide()

local alertPulse = alertIndicator.CreateAnimationGroup and alertIndicator:CreateAnimationGroup()
if alertPulse then
    alertPulse:SetLooping("BOUNCE")
    local fade = alertPulse:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0.3)
    fade:SetDuration(0.9)
    fade:SetSmoothing("IN_OUT")
end

local activeAlerts = {}

local function UpdateAlertIndicator()
    activeAlerts = GetActiveAlerts()

    if #activeAlerts > 0 then
        alertIndicator:Show()
        if alertPulse and not alertPulse:IsPlaying() then
            alertPulse:Play()
        end
    else
        if alertPulse then
            alertPulse:Stop()
        end
        alertIndicator:Hide()
    end
end

local function AnchorToMainBar()
    if not MainActionBar then return end

    picoMenu:SetParent(MainActionBar)
    picoMenu:SetSize(40, 40)
    picoMenu:ClearAllPoints()
    local endCap = MainActionBar.EndCaps and MainActionBar.EndCaps.RightEndCap
    if endCap then
        picoMenu:SetPoint("CENTER", endCap, -15, 0)
    else
        -- Bar art can be disabled, which removes the end caps entirely.
        picoMenu:SetPoint("LEFT", MainActionBar, "RIGHT", 4, 0)
    end
    picoMenu:GetNormalTexture():SetSize(40, 40)
    picoMenu:SetFrameStrata("MEDIUM")
    picoMenu:SetFrameLevel(150)
end

local function AnchorToPetBattleBar()
    local petBattleMicroButtons = GetPetBattleMicroButtonFrame()
    if not petBattleMicroButtons then return end

    picoMenu:SetParent(PetBattleFrame)
    picoMenu:SetSize(50, 50)
    picoMenu:ClearAllPoints()
    picoMenu:SetPoint("CENTER", petBattleMicroButtons, 0, 0)
    picoMenu:GetNormalTexture():SetSize(50, 50)
    picoMenu:SetFrameStrata("MEDIUM")
    picoMenu:SetFrameLevel(150)
end

UpdatePicoMenuVisibility = function()
    if PicoMenuDB.showPicomenu then
        picoMenu:Show()
    else
        picoMenu:Hide()
    end
    UpdateQueueEyePosition()
end

-- Queue Status Button: reposition below PicoMenu when Main Menu is hidden
local queueEyeHooked = false
local queueEyeReanchoring = false
local queueEyeOriginalParent = nil

-- Only adopt the eye when the Main Menu is hidden AND our button is actually on screen,
-- otherwise it would be parented to a hidden frame and disappear with it.
local function ShouldAnchorQueueEye()
    return not PicoMenuDB.showMicromenu and PicoMenuDB.showPicomenu
end

UpdateQueueEyePosition = function()
    local btn = QueueStatusButton or QueueStatusMinimapButton
    if not btn then return end
    if btn:IsProtected() and InCombatLockdown() then return end

    if not queueEyeOriginalParent then
        queueEyeOriginalParent = btn:GetParent()
    end

    queueEyeReanchoring = true
    if ShouldAnchorQueueEye() then
        btn.ignoreFramePositionManager = true
        if btn.SetIgnoreParentScale then btn:SetIgnoreParentScale(true) end
        if btn.SetIgnoreParentAlpha then btn:SetIgnoreParentAlpha(true) end
        btn:SetParent(picoMenu)
        btn:ClearAllPoints()
        btn:SetPoint("TOP", picoMenu, "BOTTOM", 0, 4)
        btn:SetScale(0.5)
        btn:SetFrameStrata(picoMenu:GetFrameStrata())
        btn:SetFrameLevel(picoMenu:GetFrameLevel() + 1)
    else
        btn.ignoreFramePositionManager = nil
        if btn.SetIgnoreParentScale then btn:SetIgnoreParentScale(false) end
        if btn.SetIgnoreParentAlpha then btn:SetIgnoreParentAlpha(false) end
        btn:SetScale(1)
        if queueEyeOriginalParent then
            btn:SetParent(queueEyeOriginalParent)
        end
    end
    queueEyeReanchoring = false

    if not queueEyeHooked then
        queueEyeHooked = true
        hooksecurefunc(btn, "SetPoint", function(self)
            if queueEyeReanchoring then return end
            if ShouldAnchorQueueEye() then
                queueEyeReanchoring = true
                self:ClearAllPoints()
                self:SetPoint("TOP", picoMenu, "BOTTOM", 0, 4)
                queueEyeReanchoring = false
            end
        end)
        hooksecurefunc(btn, "SetParent", function(self)
            if queueEyeReanchoring then return end
            if ShouldAnchorQueueEye() then
                queueEyeReanchoring = true
                self:SetParent(picoMenu)
                self:ClearAllPoints()
                self:SetPoint("TOP", picoMenu, "BOTTOM", 0, 4)
                queueEyeReanchoring = false
            end
        end)
    end
end

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

picoMenu:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("PicoMenu", 1, 1, 1)
    GameTooltip:AddLine("Left-click: Open menu", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:AddLine("Right-click: Game menu", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

    -- Naming the alerts makes the indicator actionable instead of a mystery dot.
    if #activeAlerts > 0 then
        GameTooltip:AddLine(" ")
        for _, label in ipairs(activeAlerts) do
            GameTooltip:AddLine("! " .. label, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b)
        end
    end

    GameTooltip:Show()
end)

picoMenu:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local function Initialize()
    AnchorToMainBar()

    -- Move Ticket Icon
    if HelpOpenWebTicketButton then
        HelpOpenWebTicketButton:ClearAllPoints()
        HelpOpenWebTicketButton:SetPoint("LEFT", picoMenu, "RIGHT", 0, 0)
        HelpOpenWebTicketButton:SetScale(0.8)
        HelpOpenWebTicketButton:SetParent(picoMenu)
    end

    -- Hide MicroButtonAndBagsBar
    UpdateMicroMenuVisibility()
    UpdatePicoMenuVisibility()
    UpdateAlertIndicator()
end

picoMenu:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        Initialize()
    elseif event == "PET_BATTLE_OPENING_START" then
        if picoMenuContextMenu and picoMenuContextMenu:IsShown() then
            picoMenuContextMenu:Close()
        end
        AnchorToPetBattleBar()
        UpdateMicroMenuVisibility()
    elseif event == "PET_BATTLE_CLOSE" then
        if picoMenuContextMenu and picoMenuContextMenu:IsShown() then
            picoMenuContextMenu:Close()
        end
        AnchorToMainBar()
        UpdateMicroMenuVisibility()
    else
        UpdateAlertIndicator()
    end
end)

-- Escape hatch: the button can be hidden from its own menu, so keep a way back.
SLASH_PICOMENU1 = "/pico"
SLASH_PICOMENU2 = "/picomenu"
SlashCmdList["PICOMENU"] = function(msg)
    local command = string.lower(strtrim(msg or ""))

    if command == "alerts" then
        print("|cff00ff00PicoMenu|r: alert sources")
        for _, source in ipairs(alertSources) do
            local ok, result = pcall(source.check)
            local state
            if not ok then
                state = "|cffff0000error|r"
            elseif result then
                state = "|cffffff00ACTIVE|r"
            else
                state = "|cff808080inactive|r"
            end
            print(("  %s: %s"):format(source.label, state))
        end
        return
    end

    if command == "show" then
        PicoMenuDB.showPicomenu = true
    elseif command == "hide" then
        PicoMenuDB.showPicomenu = false
    else
        PicoMenuDB.showPicomenu = not PicoMenuDB.showPicomenu
    end

    UpdatePicoMenuVisibility()
    print(("|cff00ff00PicoMenu|r: button %s. |cffffff00/pico|r toggles, |cffffff00/pico alerts|r shows alert state."):format(
        PicoMenuDB.showPicomenu and "shown" or "hidden"))
end
