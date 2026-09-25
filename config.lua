local defaults = {
    showPicomenu = true,
    showMicromenu = false,
    menuScale = 1,
}

local function ApplyDefaults()
    PicoMenuDB = PicoMenuDB or {}

    for key, value in pairs(defaults) do
        if PicoMenuDB[key] == nil then
            PicoMenuDB[key] = value
        end
    end
end

-- SavedVariables load after this file runs and replace PicoMenuDB wholesale, so
-- defaults applied now would be lost for existing users. Apply them again once the
-- saved table is in place, so newly added keys still get a value.
ApplyDefaults()

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addonName)
    if addonName == "PicoMenu" then
        ApplyDefaults()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
