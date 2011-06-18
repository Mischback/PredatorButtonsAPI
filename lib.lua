--[[
		PREDATOR BUTTONS API
		
		This addon wants to be understood as a ActionButton-framework.
		The addon itsself handles the functionality of the buttons (which are taken from the default UI)
		and handles the buttons positions in your UI.
		
		The look and feel of the addons can be adjusted by a layout.
]]

local _, ns = ...

local settings = ns.settings

-- ########################################################################################################

	local lib = {}
	lib.buttonFuncProxy = {}

	--[[ VOID debugging(STRING text)
		Prints "text" to the chat frame
	]]
	lib.debugging = function(text)
		DEFAULT_CHAT_FRAME:AddMessage('|cffffd700PredatorButtons:|r |cffeeeeee'..text..'|r')
	end

	--[[ VOID noop()
		This prevents the default UI from altering our stuff!
	]]
	lib.noop = function() end

	--[[
	
	]]
	lib.CreateConfigFrames = function()
		lib.CreateMover('ActionBar')
		lib.CreateMover('MultiBarBottomLeft')
		lib.CreateMover('MultiBarBottomRight')
		lib.CreateMover('MultiBarRight')
		lib.CreateMover('MultiBarLeft')
		lib.CreateMover('PetBar')
		lib.CreateMover('StanceBar')
	end

	--[[ Controls what happens while using a slash-command
		VOID SlashCmdHandler(STRING msg, EDITBOX editbox)
		Remember that the SlashCmds are '/predatorbuttons' and '/pb'
	]]
	lib.SlashCmdHandler = function(msg, editbox)
		local cmd, param = msg:match('^(%S*)%s*(.-)$')
		if ( cmd == 'config' ) then
			if ( not _G['PredatorButtonsActionBarMover'] ) then
				lib.CreateConfigFrames()
			elseif ( _G['PredatorButtonsActionBarMover']:IsShown() ) then
				_G['PredatorButtonsActionBarMover']:Hide()
				_G['PredatorButtonsMultiBarBottomLeftMover']:Hide()
				_G['PredatorButtonsMultiBarBottomRightMover']:Hide()
				_G['PredatorButtonsMultiBarRightMover']:Hide()
				_G['PredatorButtonsMultiBarLeftMover']:Hide()
				_G['PredatorButtonsPetBarMover']:Hide()
				_G['PredatorButtonsStanceBarMover']:Hide()
			elseif ( not _G['PredatorButtonsActionBarMover']:IsShown() ) then
				_G['PredatorButtonsActionBarMover']:Show()
				_G['PredatorButtonsMultiBarBottomLeftMover']:Show()
				_G['PredatorButtonsMultiBarBottomRightMover']:Show()
				_G['PredatorButtonsMultiBarRightMover']:Show()
				_G['PredatorButtonsMultiBarLeftMover']:Show()
				_G['PredatorButtonsPetBarMover']:Show()
				_G['PredatorButtonsStanceBarMover']:Show()
			end
		end
	end

	--[[ VOID HideBlizzard()
		Hides the default Blizzard-frames
	]]
	lib.HideBlizzard = function()
		local frame, v
		for _, v in pairs(settings.static.BlizzardDefaultFrames) do
			frame = _G[v]
			frame:SetAlpha(0)
			frame:Hide()
		end
	end

	--[[ VOID PredatorButtonsShapeshiftUpdate()
		Basically does nothing, since I have not encountered anything to do here.
		Anyway, this function hooks the Shapeshift_Update from Blizz, perhaps something has to be done in future.
	]]
	lib.PredatorButtonsShapeshiftUpdate = function()
		-- lib.debugging('ShapeshiftBar_Update()')
	end

	--[[ STRING GetActionBarPage()
		Returns the string for the state-driver for the main-actionbar
	]]
	lib.GetActionBarPage = function()
		local condition = settings.static.BlizzardActionBarPage['DEFAULT']
		local page = settings.static.BlizzardActionBarPage[settings.playerClass]
		if ( page ) then
			condition = condition.." "..page
		end
		condition = condition.." 1"
		return condition
	end

	--[[ VOID Proxify(FRAME button)
		Stores the SetSize() and SetPoint() functions of a button.
	]]
	lib.Proxify = function(button)
		local bname = button:GetName()
		if ( not lib.buttonFuncProxy[bname..'SetSize'] ) then
			lib.buttonFuncProxy[bname..'SetSize'] = button.SetSize
			button.SetSize = lib.noop										-- don't do this anymore!
		end
		if ( not lib.buttonFuncProxy[bname..'SetPoint'] ) then
			lib.buttonFuncProxy[bname..'SetPoint'] = button.SetPoint
			button.SetPoint = lib.noop										-- don't do this anymore!
		end
	end

-- ########################################################################################################

	--[[
	
	]]
	lib.CreateMover = function(key)
		local f = CreateFrame('Frame', settings.static.BarName[key]..'Mover', UIParent)
		f:SetAllPoints(_G[settings.static.BarName[key]])
		f:SetFrameLevel(_G[settings.static.ButtonPrefix[key]..'1']:GetFrameLevel()+50)
		f:EnableMouse(true)
		-- f:SetMovable(true)
		-- f:RegisterForDrag('LeftButton')

		f.tex = f:CreateTexture(nil, 'BACKGROUND')
		f.tex:SetAllPoints(f)
		f.tex:SetTexture(0, 1, 0, 0.5)

		f.caption = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		f.caption:SetText(key)
		f.caption:SetPoint('TOPLEFT')

		f.setting = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		f.setting:SetText('Mode: Buttons ('..PredatorButtonsSettings[key].buttons..')')
		f.setting:SetPoint('TOPLEFT', f.caption, 'BOTTOMLEFT', 5, -5)

		f.key = key
		f.mode = 'buttons'

		f:SetScript('OnMouseUp', function(self, btn)
			-- lib.debugging(self.key..', '..self.mode)
			if (btn ~= 'LeftButton') then return end
			if (self.mode == 'buttons') then
				self.setting:SetText('Mode: Columns ('..PredatorButtonsSettings[self.key].columns..')')
				self.mode = 'columns'
			elseif (self.mode == 'columns') then
				self.setting:SetText('Mode: ButtonSize ('..PredatorButtonsSettings[self.key].buttonSize..')')
				self.mode = 'buttonSize'
			elseif (self.mode == 'buttonSize') then
				self.setting:SetText('Mode: Padding ('..PredatorButtonsSettings[self.key].padding..')')
				self.mode = 'padding'
			elseif (self.mode == 'padding') then
				self.setting:SetText('Mode: Move')
				self:SetMovable(true)
				self:RegisterForDrag('LeftButton')
				self.mode = 'move'
			elseif (self.mode == 'move') then
				self.setting:SetText('Mode: Buttons ('..PredatorButtonsSettings[key].buttons..')')
				self:SetMovable(false)
				self:RegisterForDrag()
				self.mode = 'buttons'
			end
		end)

		f:SetScript('OnMouseWheel', function(self, delta)
			-- lib.debugging(self.key)
			local tmp
			if (self.mode == 'buttons') then
				tmp = PredatorButtonsSettings[self.key].buttons
				if (delta > 0) then
					tmp = tmp + 1
					if (tmp <= settings.static.NumButtons[self.key]) then
						PredatorButtonsSettings[self.key].buttons = tmp
					end
				else
					tmp = tmp - 1
					if (tmp > 0) then
						PredatorButtonsSettings[self.key].buttons = tmp
					end
				end
				self.setting:SetText('Mode: Buttons ('..PredatorButtonsSettings[self.key].buttons..')')
			elseif (self.mode == 'columns') then
				tmp = PredatorButtonsSettings[self.key].columns
				if (delta > 0) then
					tmp = tmp + 1
					if (tmp <= settings.static.NumButtons[self.key]) then
						PredatorButtonsSettings[self.key].columns = tmp
					end
				else
					tmp = tmp - 1
					if (tmp >= 1) then
						PredatorButtonsSettings[self.key].columns = tmp
					end
				end
				self.setting:SetText('Mode: Columns ('..PredatorButtonsSettings[self.key].columns..')')
			elseif (self.mode == 'buttonSize') then
				tmp = PredatorButtonsSettings[self.key].buttonSize
				if (delta > 0) then
					tmp = tmp + 1
					PredatorButtonsSettings[self.key].buttonSize = tmp
				else
					tmp = tmp - 1
					if (tmp > 0) then
						PredatorButtonsSettings[self.key].buttonSize = tmp
					end
				end
				self.setting:SetText('Mode: ButtonSize ('..PredatorButtonsSettings[self.key].buttonSize..')')
			elseif (self.mode == 'padding') then
				tmp = PredatorButtonsSettings[self.key].padding
				if (delta > 0) then
					tmp = tmp + 1
				else
					tmp = tmp - 1
				end
				PredatorButtonsSettings[self.key].padding = tmp
				self.setting:SetText('Mode: Padding ('..PredatorButtonsSettings[self.key].padding..')')
			end
			lib.HandleButtonBar(_G[settings.static.BarName[self.key]], self.key, PredatorButtonsSettings[self.key].buttonSize, PredatorButtonsSettings[self.key].buttonSize)
			self:ClearAllPoints()
			self:SetPoint('TOPLEFT', _G[settings.static.BarName[self.key]])
			self:SetSize(
				min(PredatorButtonsSettings[self.key].buttons, PredatorButtonsSettings[self.key].columns)*(PredatorButtonsSettings[self.key].buttonSize+(2*PredatorButtonsSettings[self.key].padding)),
				ceil(PredatorButtonsSettings[self.key].buttons/PredatorButtonsSettings[self.key].columns)*(PredatorButtonsSettings[self.key].buttonSize+(2*PredatorButtonsSettings[self.key].padding))
			)
			_G[settings.static.BarName[self.key]]:SetSize(
				min(PredatorButtonsSettings[self.key].buttons, PredatorButtonsSettings[self.key].columns)*(PredatorButtonsSettings[self.key].buttonSize+(2*PredatorButtonsSettings[self.key].padding)),
				ceil(PredatorButtonsSettings[self.key].buttons/PredatorButtonsSettings[self.key].columns)*(PredatorButtonsSettings[self.key].buttonSize+(2*PredatorButtonsSettings[self.key].padding))
			)
			self.tex:SetAllPoints(self)
		end)

		f:SetScript('OnDragStart', function(self)
			self:ClearAllPoints()
			self:StartMoving()
		end)
		f:SetScript('OnDragStop', function(self)
			self:StopMovingOrSizing()
			local point, _, relPoint, x, y = self:GetPoint(1)
			_G[settings.static.BarName[self.key]]:ClearAllPoints()
			_G[settings.static.BarName[self.key]]:SetPoint(point, UIParent, relPoint, x, y)
			PredatorButtonsSettings[self.key].position = {point, x, y}
			-- _G[settings.static.BarName[self.key]]:SetAllPoints(self)
			lib.HandleButtonBar(_G[settings.static.BarName[self.key]], self.key, PredatorButtonsSettings[self.key].buttonSize, PredatorButtonsSettings[self.key].buttonSize)
		end)

		return f
	end

-- ########################################################################################################

	--[[
	
	]]
	lib.HandleButtonTextObject = function(str, flag, cfg)
		if ( not str ) then return end
		if ( flag ) then
			if ( cfg ) then
				local tmp = cfg[1]
				if (tmp) then
					str:SetFont(unpack(tmp))
				end
				tmp = cfg[2]
				if (tmp) then
					str:ClearAllPoints()
					str:SetPoint(unpack(tmp))
				end
				tmp = cfg[3]
				if (tmp) then
					str:SetPoint(unpack(tmp))
				end
				str.SetFont = lib.noop
				str.SetPoint = lib.noop
			end
			str:Show()
		else
			str:Hide()
			str.Show = lib.noop
		end
	end

	--[[ VOID StyleButton
		FRAME button - the button
		STRING normalTex - Path of the normal texture
		STRING pushedTex - Path of the pushed texture
		STRING highlightTex - Path of the highlight texture
		STRING checkedTex - Path of the checked texture
		BOOL showHotKey - controls, if the hotkey is shown (and styled!)
		ARRAY HotKeySettings - 
			[1] = ARRAY FontSettings { font, fontsize, flags }
			[2] = POSITION
			[3] = POSITION
		BOOL showCount - controls, if the count is shown (and styled!)
		ARRAY CountSettings - 
			[1] = ARRAY FontSettings { font, fontsize, flags }
			[2] = POSITION
			[3] = POSITION
		BOOL showName - controls, if the macro text is shown (and styled!)
		ARRAY NameSettings - 
			[1] = ARRAY FontSettings { font, fontsize, flags }
			[2] = POSITION
			[3] = POSITION
		FUNCTION overrideFunc - Let's call it function-pointer^^
	]]
	lib.StyleButton = function(button, normalTex, pushedTex, highlightTex, checkedTex, showHotKey, HotKeySettings, showCount, CountSettings, showName, NameSettings, overrideFunc)

		-- Grab the parts of the button
		local bname = button:GetName()
		local icon = _G[bname..'Icon']
		local flash = _G[bname..'Flash']
		local hotkey = _G[bname..'HotKey']
		local count = _G[bname..'Count']
		local name = _G[bname..'Name']
		local border = _G[bname..'Border']
		local cd = _G[bname..'Cooldown']

		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		lib.HandleButtonTextObject(hotkey, showHotKey, HotKeySettings)
		lib.HandleButtonTextObject(count, showCount, CountSettings)
		lib.HandleButtonTextObject(name, showName, NameSettings)

		border:Hide()

		button:SetNormalTexture(normalTex)
		button:SetPushedTexture(pushedTex)
		button:SetHighlightTexture(highlightTex)
		button:SetCheckedTexture(checkedTex)

		-- Call the override to give layout authors full control
		if ( overrideFunc ) then
			overrideFunc(button)
		end

		border.Show = lib.noop													-- don't do this anymore!
		button.SetNormalTexture = lib.noop										-- don't do this anymore!
		button.SetPushedTexture = lib.noop										-- don't do this anymore!
		button.SetHighlightTexture = lib.noop									-- don't do this anymore!
		button.SetCheckedTexture = lib.noop										-- don't do this anymore!

	end

	--[[ VOID MoveButton(BUTTON button, INT sizeX, INT sizeY, ARRAY pos)
		Moves a button (which is in use, meaning visible) to the correct position.
		ARRAY pos is defined as an array which holds the position information as it is used in SetPoint()
	]]
	lib.MoveButton = function(button, sizeX, sizeY, pos)

		button:ClearAllPoints()
		-- button:SetSize(sizeX, sizeY)
		lib.buttonFuncProxy[button:GetName()..'SetSize'](button, sizeX, sizeY)
		-- button:SetPoint(unpack(pos))
		lib.buttonFuncProxy[button:GetName()..'SetPoint'](button, unpack(pos))

	end

	--[[ VOID HandleButtonBar
		FRAME parent
		STRING key - the string to access settings in arrays
		OTHER INPUT IS DOCUMENTED at lib.HandleButton !!!
	]]
	lib.HandleButtonBar = function(parent, key, sizeX, sizeY)
		-- lib.debugging('HandleButtonBar() '..key..', '..settings.static.NumButtons[key]..', '..PredatorButtonsSettings[key].buttons)
		local i, button
		for i = 1, settings.static.NumButtons[key] do
			button = _G[settings.static.ButtonPrefix[key]..i]
			lib.Proxify(button)
			if ( i <= PredatorButtonsSettings[key].buttons ) then				-- magic happening here!
				lib.MoveButton(button,
					sizeX, sizeY,
					{'TOPLEFT', parent, 'TOPLEFT', 
						( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
						-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
					} )
			else
				button:ClearAllPoints()
				-- button:SetPoint('BOTTOMRIGHT', UIParent, 'TOPLEFT', -5, 5)		-- out of sight, out of mind!
				lib.buttonFuncProxy[button:GetName()..'SetPoint'](button, 'BOTTOMRIGHT', UIParent, 'TOPLEFT', -5, 5)
			end
		end
	end

	--[[ FRAME CreateBar(STRING key)
		Creates the holder for the buttons specified by "key"
	]]
	lib.CreateBar = function(key)

		local f = CreateFrame('Frame', settings.static.BarName[key], UIParent, 'SecureHandlerStateTemplate')

		f:SetSize(
			min(PredatorButtonsSettings[key].buttons, PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding)),
			ceil(PredatorButtonsSettings[key].buttons/PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))
		)
		f:SetPoint(unpack(PredatorButtonsSettings[key].position))

		lib.HandleButtonBar(f, key, PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize)

		return f
	end

	--[[
	
	]]
	lib.CreateTotemBar = function()
		local key = 'TotemBar'

		local f = CreateFrame('Frame', settings.static.BarName[key], UIParent)

		f:SetSize(
			min(settings.static.NumButtons[key], PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding)),
			ceil(settings.static.NumButtons[key]/PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))
		)
		f:SetPoint(unpack(PredatorButtonsSettings[key].position))
		f.tex = f:CreateTexture(nil, 'OVERLAY')
		f.tex:SetAllPoints(f)
		f.tex:SetTexture(1, 0, 0, 0.25)

		_G['MultiCastFlyoutFrame']:SetParent(f)
		_G['MultiCastActionPage1']:SetParent(f)
		_G['MultiCastActionPage2']:SetParent(f)
		_G['MultiCastActionPage3']:SetParent(f)

		local button, i

		i = 1
		button = _G['MultiCastSummonSpellButton']
		button:SetParent(f)
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

-- #######################################################################
		i = 2
		button = _G['MultiCastSlotButton1']
		button:SetParent(f)
		button.SetParent = lib.noop
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton1']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton5']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton9']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

-- #######################################################################
		i = 3
		button = _G['MultiCastSlotButton2']
		button:SetParent(f)
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton2']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton6']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton10']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

-- #######################################################################
		i = 4
		button = _G['MultiCastSlotButton3']
		button:SetParent(f)
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton3']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton7']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton11']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

-- #######################################################################
		i = 5
		button = _G['MultiCastSlotButton4']
		button:SetParent(f)
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton4']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton8']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		button = _G['MultiCastActionButton12']
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

-- #######################################################################
		i = 6
		button = _G['MultiCastRecallSpellButton']
		button:SetParent(f)
		lib.Proxify(button)
		lib.MoveButton(button, 
			PredatorButtonsSettings[key].buttonSize, PredatorButtonsSettings[key].buttonSize,
			{'TOPLEFT', f, 'TOPLEFT', 
				( ((i-1)%PredatorButtonsSettings[key].columns)*(PredatorButtonsSettings[key].buttonSize+2*PredatorButtonsSettings[key].padding)+PredatorButtonsSettings[key].padding ),
				-( (floor((i-1) / PredatorButtonsSettings[key].columns))*(PredatorButtonsSettings[key].buttonSize+(2*PredatorButtonsSettings[key].padding))+PredatorButtonsSettings[key].padding )
			} )

		return f
	end

-- ########################################################################################################
ns.lib = lib