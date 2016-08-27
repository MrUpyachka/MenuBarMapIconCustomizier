--- Allows you to customize world map button in menu bar
MenuBarMapIconCustomizier = {}
MenuBarMapIconCustomizier.name = "MenuBarMapIconCustomizier"
local buttonPrefix = "ZO_MainMenuCategoryBarButton"
local mapButtonId = 8 -- See index in keyboard/gamepad layout configuration.

local mapButtonName = buttonPrefix .. mapButtonId

-- Just to cache this. And Avoid unnecessary calculation.
local mapButton
local nextButton
local previousButton

function MenuBarMapIconCustomizier.configureNextButton(mapButton, nextButton, previousButton)
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = mapButton:GetAnchor(0)
    local _, _, desiredRelativeTo, _, _, _ = nextButton:GetAnchor(0)
    if desiredRelativeTo ~= previousButton then
        nextButton:SetAnchor(point, previousButton, relativePoint, offsetX, offsetY)
    end
end

function MenuBarMapIconCustomizier.hideMapButton(mapButton, nextButton, previousButton)
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = mapButton:GetAnchor(0)
    if not mapButton:IsHidden() then
        mapButton:SetHidden(true)
    end
end

local function checkButtonsConfigured()
    if mapButton == nil then
        mapButton = GetControl(mapButtonName)
    end
    if nextButton == nil then
        nextButton = GetControl(buttonPrefix .. (mapButtonId + 1))
    end
    if previousButton == nil then
        previousButton = GetControl(buttonPrefix .. (mapButtonId - 1))
    end
    if mapButton == nil then
        return false
    end
    if nextButton == nil or previousButton == nil then
        return false -- Buttons not initialized, stop
    end
    return true
end


local function hideIfNecessary()
    MenuBarMapIconCustomizier.hideMapButton(mapButton, nextButton, previousButton)
    MenuBarMapIconCustomizier.configureNextButton(mapButton, nextButton, previousButton)
end

local function tryHideIfExists()
    if checkButtonsConfigured() then
        hideIfNecessary()
    end
end

local mapButtonCallBackRegistered = false
local nextButtonCallBackRegistered = false
local function tryRegisterOwnCallBack()
    if not mapButtonCallBackRegistered and checkButtonsConfigured() then
        mapButton:SetHandler("OnUpdate", function() MenuBarMapIconCustomizier.hideMapButton(mapButton, nextButton, previousButton) end)
        mapButtonCallBackRegistered = true

    end
    if not nextButtonCallBackRegistered and checkButtonsConfigured() then
        nextButton:SetHandler("OnUpdate", function() MenuBarMapIconCustomizier.configureNextButton(mapButton, nextButton, previousButton) end)
        nextButtonCallBackRegistered = true
    end
    if not nextButtonCallBackRegistered and not mapButtonCallBackRegistered then
        EVENT_MANAGER:UnregisterForUpdate(MenuBarMapIconCustomizier.name)
    end
end

function MenuBarMapIconCustomizier.OnAddOnLoaded(event, addonName)
    -- Filter addon's by name.
    if addonName == MenuBarMapIconCustomizier.name then
        EVENT_MANAGER:RegisterForUpdate(MenuBarMapIconCustomizier.name, 100, tryRegisterOwnCallBack)
        -- EVENT_MANAGER:RegisterForEvent(MenuBarMapIconCustomizier.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, tryHideIfExists)
        -- local fragment = MAIN_MENU_KEYBOARD.categoryBarFragment
        -- fragment:RegisterCallback("StateChange", tryHideIfExists)
        -- addon initialized. No more needs to listen event.
        EVENT_MANAGER:UnregisterForEvent(MenuBarMapIconCustomizier.name, EVENT_ADD_ON_LOADED)
    end
end

-- Registration for handling of ESO API events.
EVENT_MANAGER:RegisterForEvent(MenuBarMapIconCustomizier.name, EVENT_ADD_ON_LOADED, MenuBarMapIconCustomizier.OnAddOnLoaded)
