local defaults = {
    showPicomenu = true,
    showMicromenu = false,
}

PicoMenuDB = PicoMenuDB or {}

for key, value in pairs(defaults) do
    if PicoMenuDB[key] == nil then
        PicoMenuDB[key] = value
    end
end
