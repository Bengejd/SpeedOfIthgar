local _, core = ...;
local _G = _G;
local L = core.L;

local SOI = {}

SOI_UpdateInterval = 1; -- How often the OnUpdate code will run (in seconds)
SOI_TimeSinceLastUpdate = 0;

SOI.success = '66FF00 ';
SOI.warning = 'EBC934';
SOI.error = 'E71D36';

-- Generic event handler that handles all of the game events & directs them.
-- This is the FIRST function to run on load triggered registered events at bottom of file
function SOI_OnEvent(self, event, arg1, ...)
    local SIMPLE_EVENT_FUNCS = {
        ['ADDON_LOADED']=function() -- The addon finished loading, most things should be available.
            SOI_OnInitialize(event, arg1)
            return SOI_UnregisterEvent(self, event)
        end,
    }
    if SIMPLE_EVENT_FUNCS[event] then SIMPLE_EVENT_FUNCS[event]() end
end

-- event function that happens when the addon is initialized.
function SOI_OnInitialize(event, name)
    if (name ~= "SpeedOfIthgar") then return end

    local SOI_Frame = CreateFrame("frame", "SOIFrame")
    SOI_Frame:SetWidth(100);
    SOI_Frame:SetHeight(50);
    SOI_Frame:SetPoint("BottomLeft", UIParent)
    SOI_Frame:EnableMouse(true);
    SOI_Frame:SetMovable(true);
    SOI_Frame:RegisterForDrag("LeftButton")

    SOI.fps = SOI_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    SOI.fps:SetPoint("LEFT")
    SOI.fps:SetText(" ")

    local title = SOI_Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", SOI_Frame, "TOP")
    title:SetText("Speed Of Ithgar")

    SOI_Frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    SOI_Frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    C_Timer.NewTicker(0.5, SOI_OnUpdate)
end

function SOI_OnUpdate(self, elapsed)
    local fps =  math.floor(GetFramerate())
    local _, _, lagHome, lagWorld = GetNetStats()

    local function getTextColor(speed)
        if speed <= 100 then return SOI.success
        elseif speed > 100 and speed < 175 then return SOI.warning
        elseif speed >= 175 then return SOI.error
        end
    end

    local function getFPSColor(speed)
        if speed < 25 then return SOI.error
        elseif speed >= 25 and speed < 50 then return SOI.warning
        elseif speed >= 50 then return SOI.success
        end
    end

    local fpsText = "|cff" .. "ffffff" .. "FPS:" .. "|r"
    local homeText = "|cff" .. "ffffff" .. "Home:" .. "|r"
    local worldText = "|cff" .. "ffffff" .. "World:" .. "|r"

    local speedText = "|cff" .. getFPSColor(fps) .. fps .. "|r"
    local worldLag = "|cff" .. getTextColor(lagWorld) .. math.floor(lagWorld) .. "|r"
    local homeLag = "|cff" .. getTextColor(lagHome) .. math.floor(lagHome) .. "|r"

    local seperator = "|cff" .. "ffffff" .. " | " .. "|r"

    SOI.fps:SetText(fpsText .. speedText .. seperator .. homeText .. homeLag .. seperator .. worldText .. worldLag);
end


function SOI_UnregisterEvent(self, event)
    self:UnregisterEvent(event);
end

local events = CreateFrame("Frame", "EventsFrame");

local eventNames = {
    "ADDON_LOADED",
}

for _, eventName in pairs(eventNames) do
    events:RegisterEvent(eventName);
end
events:SetScript("OnEvent", SOI_OnEvent); -- calls the above OnEvent function to determine what to do with the event


