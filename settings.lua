--[[
		PREDATOR BUTTONS API
		
		This addon wants to be understood as a ActionButton-framework.
		The addon itsself handles the functionality of the buttons (which are taken from the default UI)
		and handles the buttons positions in your UI.
		
		The look and feel of the addons can be adjusted by a layout.
]]

local _, ns = ...

-- ########################################################################################################

	local settings = {
		['playerClass'] = nil,
		['static'] = {
			['BarName'] = {
				['ActionBar'] = 'PredatorButtonsActionBar',
				['MultiBarBottomLeft'] = 'PredatorButtonsMultiBarBottomLeft',
				['MultiBarBottomRight'] = 'PredatorButtonsMultiBarBottomRight',
				['MultiBarRight'] = 'PredatorButtonsMultiBarRight',
				['MultiBarLeft'] = 'PredatorButtonsMultiBarLeft',
				['PetBar'] = 'PredatorButtonsPetBar',
				['StanceBar'] = 'PredatorButtonsStanceBar',
				['TotemBar'] = 'PredatorButtonsTotemBar'
			},
			['NumButtons'] = {
				['ActionBar'] = NUM_ACTIONBAR_BUTTONS,
				['MultiBarBottomLeft'] = NUM_MULTIBAR_BUTTONS,
				['MultiBarBottomRight'] = NUM_MULTIBAR_BUTTONS,
				['MultiBarRight'] = NUM_MULTIBAR_BUTTONS,
				['MultiBarLeft'] = NUM_MULTIBAR_BUTTONS,
				['PetBar'] = NUM_PET_ACTION_SLOTS,
				['StanceBar'] = NUM_SHAPESHIFT_SLOTS,
				['TotemBar'] = 6
			},
			['ButtonPrefix'] = {
				['ActionBar'] = 'ActionButton',
				['MultiBarBottomLeft'] = 'MultiBarBottomLeftButton',
				['MultiBarBottomRight'] = 'MultiBarBottomRightButton',
				['MultiBarRight'] = 'MultiBarRightButton',
				['MultiBarLeft'] = 'MultiBarLeftButton',
				['PetBar'] = 'PetActionButton',
				['StanceBar'] = 'ShapeshiftButton',
			},
			['BlizzardActionBarPage'] = {
				['DRUID'] = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;',
				['WARRIOR'] = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;',
				['PRIEST'] = '[bonusbar:1] 7;',
				['ROGUE'] = '[bonusbar:1] 7; [form:3] 7;',
				['WARLOCK'] = '[form:2] 7;',
				['DEFAULT'] = '[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;',
			},
			['BlizzardDefaultFrames'] = {
				'MainMenuBar', 					-- FrameXML/MainMenuBar.xml
				'MainMenuExpBar', 				-- FrameXML/MainMenuBar.xml
				'ExhaustionLevelFillBar',		-- FrameXML/MainMenuBar.xml
				-- 'MainMenuXPBarTexture0',		-- FrameXML/MainMenuBar.xml (seems not to be there anymore)
				-- 'MainMenuXPBarTexture1',		-- FrameXML/MainMenuBar.xml (seems not to be there anymore)
				-- 'MainMenuXPBarTexture2',		-- FrameXML/MainMenuBar.xml (seems not to be there anymore)
				-- 'MainMenuXPBarTexture3',		-- FrameXML/MainMenuBar.xml (seems not to be there anymore)
				'MainMenuBarOverlayFrame', 		-- FrameXML/MainMenuBar.xml
				'MainMenuBarMaxLevelBar', 		-- FrameXML/MainMenuBar.xml
				'MainMenuMaxLevelBar0', 		-- FrameXML/MainMenuBar.xml	
				'MainMenuMaxLevelBar1', 		-- FrameXML/MainMenuBar.xml	
				'MainMenuMaxLevelBar2', 		-- FrameXML/MainMenuBar.xml	
				'MainMenuMaxLevelBar3', 		-- FrameXML/MainMenuBar.xml	
				'MainMenuBarArtFrame', 			-- FrameXML/MainMenuBar.xml
				'MainMenuBarTexture0', 			-- FrameXML/MainMenuBar.xml
				'MainMenuBarTexture1', 			-- FrameXML/MainMenuBar.xml
				'MainMenuBarTexture2', 			-- FrameXML/MainMenuBar.xml
				'MainMenuBarTexture3', 			-- FrameXML/MainMenuBar.xml
				'MainMenuBarLeftEndCap',		-- FrameXML/MainMenuBar.xml
				'MainMenuBarRightEndCap', 		-- FrameXML/MainMenuBar.xml
				'ExhaustionTick',				-- FrameXML/MainMenuBar.xml
				'BonusActionBarFrameTexture1',
				'BonusActionBarFrameTexture2',
				'BonusActionBarFrameTexture3',
				'BonusActionBarFrameTexture4',

				-- 'BonusActionBarTexture0',		-- FrameXML/BonusActionBarFrame.xml (seems not to be there anymore)
				-- 'BonusActionBarTexture1',		-- FrameXML/BonusActionBarFrame.xml (seems not to be there anymore)
				'ShapeshiftBarFrame', 			-- FrameXML/BonusActionBarFrame.xml
				'ShapeshiftBarLeft', 			-- FrameXML/BonusActionBarFrame.xml
				'ShapeshiftBarMiddle', 			-- FrameXML/BonusActionBarFrame.xml
				'ShapeshiftBarRight',			-- FrameXML/BonusActionBarFrame.xml
				'PossessBarFrame', 				-- FrameXML/BonusActionBarFrame.xml
				'PossessBackground1', 			-- FrameXML/BonusActionBarFrame.xml
				'PossessBackground2', 			-- FrameXML/BonusActionBarFrame.xml

				'SlidingActionBarTexture0', 	-- FrameXML/PetActionBarFrame.xml
				'SlidingActionBarTexture1', 	-- FrameXML/PetActionBarFrame.xml

				'VehicleMenuBar', 				-- FrameXML/VehicleMenuBar.xml
				'VehicleMenuBarArtFrame', 		-- FrameXML/VehicleMenuBar.xml
			},

		},
		['defaultSkin'] = {
			['tex'] = {
				['normal'] = [[Interface\Buttons\UI-Quickslot2]],
				['pushed'] = [[Interface\Buttons\UI-Quickslot-Depress]],
				['highlight'] = [[Interface\Buttons\ButtonHilight-Square]],
				['checked'] = [[Interface\Buttons\CheckButtonHilight]],
			},
			['showHotKey'] = true,
			['HotKeySettings'] = {},
			['showCount'] = true,
			['CountSettings'] = {},
			['showName'] = true,
			['NameSettings'] = {},
		},
	}

	--[[
	
	]]
	settings.CreateDefaults = function()
		local bars = {
			['ActionBar'] = {
				['buttons'] = 12,
				['columns'] = 12,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					90,
				},
			},
			['MultiBarBottomLeft'] = {
				['buttons'] = 12,
				['columns'] = 12,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					45,
				},
			},
			['MultiBarBottomRight'] = {
				['buttons'] = 12,
				['columns'] = 12,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					0,
				},
			},
			['MultiBarRight'] = {
				['buttons'] = 12,
				['columns'] = 12,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					-45,
				},
			},
			['MultiBarLeft'] = {
				['buttons'] = 12,
				['columns'] = 12,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					-90,
				},
			},
			['PetBar'] = {
				['buttons'] = 10,
				['columns'] = 10,
				['buttonSize'] = 30,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					-225,
				},
			},
			['StanceBar'] = {
				['buttons'] = 10,
				['columns'] = 10,
				['buttonSize'] = 30,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					-270,
				},
			},
			['TotemBar'] = {
				['buttons'] = 6,
				['columns'] = 6,
				['buttonSize'] = 36,
				['padding'] = 3,
				['position'] = {
					'CENTER', 
					0, 
					-315,
				},
			}
		}
		return bars
	end

-- ########################################################################################################
ns.settings = settings