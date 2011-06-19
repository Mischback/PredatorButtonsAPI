--[[
		PREDATOR BUTTONS API
		
		This addon wants to be understood as a ActionButton-framework.
		The addon itsself handles the functionality of the buttons (which are taken from the default UI)
		and handles the buttons positions in your UI.
		
		The look and feel of the addons can be adjusted by a layout.
]]
PredatorButtons = {}

local ADDON_NAME, ns = ...
local _
local skin = {}

local settings = ns.settings
local lib = ns.lib

-- ########################################################################################################

-- ########################################################################################################

	--[[ VOID SetActiveSkin(skinTable)

	]]
	function PredatorButtons:SetActiveSkin(skinTable)
		table.wipe(skin)
		if ( skinTable.tex ) then
			skin.tex = skinTable.tex
			if ( not skinTable.tex.normal ) then
				skin.tex.normal = settings.defaultSkin.tex.normal
			end
			if ( not skinTable.tex.pushed ) then
				skin.tex.pushed = settings.defaultSkin.tex.pushed
			end
			if ( not skinTable.tex.highlight ) then
				skin.tex.highlight = settings.defaultSkin.tex.highlight
			end
			if ( not skinTable.tex.checked ) then
				skin.tex.checked = settings.defaultSkin.tex.checked
			end
		else
			skin.tex = settings.defaultSkin.tex
		end
		if ( skinTable.showHotKey ) then
			skin.showHotKey = true
		else
			skin.showHotKey = false
		end
		if ( skinTable.HotKeySettings ) then
			skin.HotKeySettings = skinTable.HotKeySettings
		else
			skin.HotKeySettings = settings.defaultSkin.HotKeySettings
		end
		if ( skinTable.showCount ) then
			skin.showCount = true
		else
			skin.showCount = false
		end
		if ( skinTable.CountSettings ) then
			skin.CountSettings = skinTable.CountSettings
		else
			skin.CountSettings = settings.defaultSkin.CountSettings
		end
		if ( skinTable.showName ) then
			skin.showName = true
		else
			skin.showName = false
		end
		if ( skinTable.NameSettings ) then
			skin.NameSettings = skinTable.NameSettings
		else
			skin.NameSettings = settings.defaultSkin.NameSettings
		end
		if ( skinTable.overrideFunc ) then
			skin.overrideFunc = skinTable.overrideFunc
		end
	end

	--[[ VOID ApplySkin(bar)
		
	]]
	function PredatorButtons:ApplySkin(bar)
		local parent = _G[settings.static.BarName[bar]]
		local i
		if ( bar ~= 'TotemBar' ) then
			for i = 1, PredatorButtonsSettings[bar].buttons do
				lib.StyleButton(_G[settings.static.ButtonPrefix[bar]..i],
					skin.tex.normal, 
					skin.tex.pushed, 
					skin.tex.highlight, 
					skin.tex.checked, 
					skin.showHotKey,
					skin.HotKeySettings,
					skin.showCount,
					skin.CountSettings,
					skin.showName,
					skin.NameSettings,
					skin.overrideFunc)
			end
		else
			lib.debugging('styling TotemBar')
			lib.StyleTotemSlotButton(_G['MultiCastSlotButton1'])
			lib.StyleTotemSlotButton(_G['MultiCastSlotButton2'])
			lib.StyleTotemSlotButton(_G['MultiCastSlotButton3'])
			lib.StyleTotemSlotButton(_G['MultiCastSlotButton4'])

			_G['MultiCastSummonSpellButtonHighlight']:Hide()
			_G['MultiCastSummonSpellButtonHighlight'].Show = lib.noop
			lib.StyleButton(_G['MultiCastSummonSpellButton'],
				skin.tex.normal, 
				skin.tex.pushed, 
				skin.tex.highlight, 
				skin.tex.checked, 
				skin.showHotKey,
				skin.HotKeySettings,
				skin.showCount,
				skin.CountSettings,
				skin.showName,
				skin.NameSettings,
				skin.overrideFunc)

			_G['MultiCastRecallSpellButtonHighlight']:Hide()
			_G['MultiCastRecallSpellButtonHighlight'].Show = lib.noop
			lib.StyleButton(_G['MultiCastRecallSpellButton'],
				skin.tex.normal, 
				skin.tex.pushed, 
				skin.tex.highlight, 
				skin.tex.checked, 
				skin.showHotKey,
				skin.HotKeySettings,
				skin.showCount,
				skin.CountSettings,
				skin.showName,
				skin.NameSettings,
				skin.overrideFunc)

			for i = 1, 12 do
				_G['MultiCastActionButton'..i].overlayTex:Hide()
				_G['MultiCastActionButton'..i].overlayTex.Show = lib.noop
				lib.StyleButton(_G['MultiCastActionButton'..i],
					skin.tex.normal, 
					skin.tex.pushed, 
					skin.tex.highlight, 
					skin.tex.checked, 
					skin.showHotKey,
					skin.HotKeySettings,
					skin.showCount,
					skin.CountSettings,
					skin.showName,
					skin.NameSettings,
					skin.overrideFunc)
			end
		end
	end

-- ########################################################################################################

local PB = CreateFrame('Frame', nil, UIParent)
PB:RegisterEvent('ADDON_LOADED')
PB:SetScript('OnEvent', function(self, event, addon)
	if ( addon ~= ADDON_NAME ) then return end

	if ( not PredatorButtonsSettings ) then
		PredatorButtonsSettings = settings.CreateDefaults()
	end

	_, settings.playerClass = UnitClass('player')

	local i, j

	local PB_AB = lib.CreateBar('ActionBar')
	PB_AB:RegisterEvent('PLAYER_LOGIN')
	PB_AB:RegisterEvent('KNOWN_CURRENCY_TYPES_UPDATE')
	PB_AB:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	PB_AB:RegisterEvent('BAG_UPDATE')
	PB_AB:SetScript('OnEvent', function(self, event, ...)
		if ( event == 'PLAYER_LOGIN' ) then
			local i, button, list
			for i = 1, settings.static.NumButtons['ActionBar'] do
				button = _G[settings.static.ButtonPrefix['ActionBar']..i]
				button:SetParent(self)
				self:SetFrameRef('ActionButton'..i, button)
			end
			self:Execute([[
				list = table.new()
				for i = 1, 12 do
					table.insert(list, self:GetFrameRef('ActionButton'..i))
				end
			]])
			self:SetAttribute('_onstate-page', [[
				for i, button in ipairs(list) do
					button:SetAttribute('actionpage', tonumber(newstate))
				end
			]])
			RegisterStateDriver(self, 'page', lib.GetActionBarPage())
		else
				MainMenuBar_OnEvent(self, event, ...)		-- BLIZZARD
		end
	end)

	local PB_MBBL = lib.CreateBar('MultiBarBottomLeft')
	_G['MultiBarBottomLeft']:SetParent(PB_MBBL)

	local PB_MBBR = lib.CreateBar('MultiBarBottomRight')
	_G['MultiBarBottomRight']:SetParent(PB_MBBR)

	local PB_MBR = lib.CreateBar('MultiBarRight')
	_G['MultiBarRight']:SetParent(PB_MBR)

	local PB_MBL = lib.CreateBar('MultiBarLeft')
	_G['MultiBarLeft']:SetParent(PB_MBL)

	local PB_PB = lib.CreateBar('PetBar')
	_G['PetActionBarFrame']:SetParent(PB_PB)

	local PB_SB = lib.CreateBar('StanceBar')
	for i = 1, settings.static.NumButtons['StanceBar'] do
		_G[settings.static.ButtonPrefix['StanceBar']..i]:SetParent(PB_SB)
	end
	hooksecurefunc('ShapeshiftBar_Update', lib.PredatorButtonsShapeshiftUpdate)

	if ( settings.playerClass == 'SHAMAN' ) then
		local PB_TB = lib.CreateTotemBar()
	end

	lib.HideBlizzard()

	SLASH_PREDATORBUTTONS1, SLASH_PREDATORBUTTONS2 = '/predatorbuttons', '/pb'
	SlashCmdList['PREDATORBUTTONS'] = lib.SlashCmdHandler

	lib.debugging('loaded successfully!')

end)