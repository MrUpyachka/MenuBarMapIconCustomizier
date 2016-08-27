--- Allows you to customize world map button in menu bar
MenuBarMapIconCustomizier = {}
MenuBarMapIconCustomizier.name = "MenuBarMapIconCustomizier"
local buttonPrefix = "ZO_MainMenuCategoryBarButton"
local mapButtonId = 8 -- See index in keyboard/gamepad layout configuration.

local mapButtonName = buttonPrefix .. mapButtonId

-- Just to cache this. And Avoid unnecessary calculation.
local mapButton
local nextButton

-- Use this if there an issue with sorting.
local function getNextButtonFor(buttonName)
	local targetButton = GetControl(buttonName)
	for i = 1, 30 do
		local button = GetControl(buttonPrefix .. i)
		if button ~= nil then 
			local isValidAnchor, point, relativeTo = button:GetAnchor(0)
			if relativeTo == targetButton then
				return button
			end
		end
	end
	return nil
end

function MenuBarMapIconCustomizier.hideMapButton(mapButton, nextButton)
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = mapButton:GetAnchor(0)
	local previousButton = relativeTo
	nextButton:SetAnchor(point, previousButton, relativePoint, offsetX, offsetY)
	mapButton:SetHidden(true)
end

local function tryHideIfExists()
	if mapButton == nil then -- Find only if necessary.
		mapButton = GetControl(mapButtonName)
	end
	if nextButton == nil then -- Find only if necessary.
		nextButton = GetControl(buttonPrefix .. (mapButtonId + 1))
	end

	if mapButton == nil then
		return nil
	elseif nextButton == nil then
		nextButton = getNextButtonFor(mapButtonName)
	end
	if nextButton == nil then
		return nil -- Buttons not initialized, stop
	end
	MenuBarMapIconCustomizier.hideMapButton(mapButton, nextButton)
end

function MenuBarMapIconCustomizier.OnAddOnLoaded(event, addonName)
    -- Filter addon's by name.
    if addonName == MenuBarMapIconCustomizier.name then
		-- Here we have a question. Is there an event that Ingame menu appears (inventory/map/others...)
		-- EVENT_MANAGER:RegisterForUpdate(MenuBarMapIconCustomizier.name, 100, tryHideIfExists)
		-- EVENT_MANAGER:RegisterForEvent(MenuBarMapIconCustomizier.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, tryHideIfExists)
		local fragment = MAIN_MENU_KEYBOARD.categoryBarFragment
		fragment:RegisterCallback("StateChange", tryHideIfExists)
		-- addon initialized. No more needs to listen event.
        EVENT_MANAGER:UnregisterForEvent(MenuBarMapIconCustomizier.name, EVENT_ADD_ON_LOADED)
    end
end
-- Registration for handling of ESO API events.
EVENT_MANAGER:RegisterForEvent(MenuBarMapIconCustomizier.name, EVENT_ADD_ON_LOADED, MenuBarMapIconCustomizier.OnAddOnLoaded)
