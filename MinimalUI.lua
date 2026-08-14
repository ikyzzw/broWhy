-- made with claude ai
-- if you don't like this please ignore.

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(18, 18, 22),
	Panel      = Color3.fromRGB(26, 26, 32),
	Element    = Color3.fromRGB(34, 34, 41),
	ElementHi  = Color3.fromRGB(42, 42, 50),
	Text       = Color3.fromRGB(235, 235, 240),
	SubText    = Color3.fromRGB(140, 140, 152),
	Stroke     = Color3.fromRGB(46, 46, 54),
	GradientA  = Color3.fromRGB(124, 92, 255),
	GradientB  = Color3.fromRGB(56, 189, 248),
}

local function new(class, props, children)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function corner(parent, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return new("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		Parent = parent,
	})
end

local function gradient(parent, colorA, colorB, rotation)
	return new("UIGradient", {
		Color = ColorSequence.new(colorA or Theme.GradientA, colorB or Theme.GradientB),
		Rotation = rotation or 45,
		Parent = parent,
	})
end

local function tween(obj, props, time, style, dir)
	local info = TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos, dragInput

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local IconsV2
do
	local ok, result = pcall(function()
		return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	end)
	if ok then
		IconsV2 = result
	end
end

local function resolveIcon(icon)
	if not icon or icon == "" then
		return nil
	end
	if type(icon) == "string" and icon:match("^rbxasset") then
		return icon
	end
	if IconsV2 then
		local ok, image = pcall(IconsV2.GetIcon, icon)
		if ok and image and image ~= "" then
			return image
		end
	end
	return nil
end

local Library = {}

function Library:CreateWindow(config)
	config = config or {}
	local title       = config.Title or "Menu"
	local size        = config.Size or UDim2.new(0, 520, 0, 340)
	local toggleKey   = config.ToggleKey or Enum.KeyCode.RightControl
	local toggleImage = config.ToggleImage or ""

	local screenGui = new("ScreenGui", {
		Name = "MinimalUI",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})

	local Main = new("Frame", {
		Name = "Main",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Theme.Background,
		ClipsDescendants = true,
	})
	corner(Main, 12)
	local mainStroke = stroke(Main, Theme.Stroke, 1)
	local mainGradient = gradient(mainStroke, Theme.GradientA, Theme.GradientB, 45)

	tween(Main, { Size = size }, 0.5)

	local TopBar = new("Frame", {
		Name = "TopBar",
		Parent = Main,
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 40),
	})
	corner(TopBar, 12)
	-- square off the bottom of the topbar so it reads as a flat header strip
	new("Frame", {
		Parent = TopBar,
		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
	})

	local accentBar = new("Frame", {
		Parent = TopBar,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.new(0, 4, 0, 16),
		BackgroundColor3 = Theme.GradientA,
	})
	corner(accentBar, 2)
	gradient(accentBar, Theme.GradientA, Theme.GradientB, 90)

	new("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 28, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
	})

	local closeBtn = new("ImageLabel", {
      Parent = TopBar,
      BackgroundTransparency = 1,
      AnchorPoint = Vector2.new(1, 0.5),
	  Position = UDim2.new(1, -14, 0.5, 0),
	  Size = UDim2.new(0, 22, 0, 22),
      Image = resolveIcon("minus"),
      ImageColor3 = Theme.Text,
	})
	corner(closeBtn, 6)
	
	local minimizeBtn = new("ImageLabel", {
      Parent = TopBar,
      BackgroundTransparency = 1,
      AnchorPoint = Vector2.new(1, 0.5),
	  Position = UDim2.new(1, -42, 0.5, 0),
	  Size = UDim2.new(0, 22, 0, 22),
      Image = resolveIcon("x"),
      ImageColor3 = Theme.Text,
	})
	corner(minimizeBtn, 6)

	makeDraggable(TopBar, Main)

	----------------------------------------------------------------
	-- MINIMIZE
	----------------------------------------------------------------
	-- Floating pill shown in place of the window while minimized.
	-- Corner radius is kept small on purpose so it reads as a
	-- rounded button rather than a circle.
	local minimized = false

	local indicator = new("TextButton", {
		Name = "MinimizedIndicator",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.new(0, 44, 0, 44),
		BackgroundColor3 = Theme.Panel,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
	})
	corner(indicator, 10)
	local indicatorStroke = stroke(indicator, Theme.Stroke, 1)
	gradient(indicatorStroke, Theme.GradientA, Theme.GradientB, 45)

	if toggleImage ~= "" then
		new("ImageLabel", {
			Parent = indicator,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			Image = toggleImage,
			ImageColor3 = Theme.Text,
		})
	else
		new("ImageLabel", {
			Parent = indicator,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			Image = resolveIcon("house"),
			ImageColor3 = Theme.Text,
		})
	end

	makeDraggable(indicator, indicator)

	local function setMinimized(state)
		minimized = state
		if minimized then
			indicator.Visible = true
			local closeTween = tween(Main, { Size = UDim2.new(0, 0, 0, 0) }, 0.3)
			closeTween.Completed:Once(function()
				if minimized then
					Main.Visible = false
				end
			end)
		else
			Main.Visible = true
			indicator.Visible = false
			tween(Main, { Size = size }, 0.35)
		end
	end

	minimizeBtn.MouseButton1Click:Connect(function()
		setMinimized(true)
	end)

	indicator.MouseButton1Click:Connect(function()
		setMinimized(false)
	end)

	-- slow ambient rotation on the border gradient, purely cosmetic
	task.spawn(function()
		local rot = 45
		while Main.Parent do
			rot = (rot + 0.15) % 360
			mainGradient.Rotation = rot
			RunService.Heartbeat:Wait()
		end
	end)

	local TabBar = new("Frame", {
		Name = "TabBar",
		Parent = Main,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(0, 130, 1, -40),
		BackgroundColor3 = Theme.Panel,
	})
	-- TabBar's bottom-left corner sits flush against Main's bottom-left
	-- corner (radius 12), so it needs to match. UICorner rounds all four
	-- corners at once though, and the top edge (against TopBar) and the
	-- bottom-right edge (against PagesHolder) both need to stay square.
	-- Same squaring trick TopBar uses on its own bottom edge: round the
	-- whole frame, then patch the three corners that shouldn't be rounded
	-- with flat squares of the same color.
	corner(TabBar, 12)
	new("Frame", { -- square off top-left + top-right (against TopBar)
		Parent = TabBar,
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(1, 0, 0, 12),
	})
	new("Frame", { -- square off bottom-right (against PagesHolder)
		Parent = TabBar,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Panel,
		Size = UDim2.new(0, 12, 0, 12),
	})

	-- The corner patches above are plain children of TabBar for the
	-- rounding fix. Tab buttons live in this separate inner frame instead
	-- of directly in TabBar, so UIListLayout only lays out the buttons and
	-- doesn't also try to stack/center the two patch frames in with them.
	local TabList = new("Frame", {
		Name = "TabList",
		Parent = TabBar,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	})
	new("UIListLayout", {
		Parent = TabList,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	new("UIPadding", {
		Parent = TabList,
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	})

	local pagesHolder = new("Frame", {
		Name = "PagesHolder",
		Parent = Main,
		Position = UDim2.new(0, 130, 0, 40),
		Size = UDim2.new(1, -130, 1, -40),
		BackgroundTransparency = 1,
	})

	-- show / hide the whole window on the toggle key
	local visible = true
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == toggleKey then
			visible = not visible
			if visible then
				screenGui.Enabled = true
				tween(Main, { Size = size }, 0.4)
			else
				local closeTween = tween(Main, { Size = UDim2.new(0, 0, 0, 0) }, 0.4)
				closeTween.Completed:Once(function()
					screenGui.Enabled = false
				end)
			end
		end
	end)

	-- Floating layer dropdown menus render into (WindUI's "New Elements"
	-- dropdown opens as an overlay panel instead of pushing the row below
	-- it down), plus a slot for whichever dropdown is currently open so a
	-- second one can close it before opening itself.
	local dropdownGui = new("ScreenGui", {
		Name = "MinimalUI_Dropdowns",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 10,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})
	local activeDropdownClose = nil

	local Window = {
		_tabs = {},
		_firstTab = false,
	}

	closeBtn.MouseButton1Click:Connect(function()
		local closeTween = tween(Main, { Size = UDim2.new(0, 0, 0, 0) }, 0.35)
		closeTween.Completed:Once(function()
			screenGui:Destroy()
		end)
	end)

	----------------------------------------------------------------
	-- MINIMIZE (programmatic)
	----------------------------------------------------------------
	function Window:Minimize(state)
		if state == nil then
			state = not minimized
		end
		setMinimized(state)
	end

	----------------------------------------------------------------
	-- NOTIFY
	----------------------------------------------------------------
	function Window:Notify(notifTitle, text, duration)
		duration = duration or 4

		local holder = new("Frame", {
			Parent = screenGui,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -20, 1, -20),
			Size = UDim2.new(0, 260, 0, 64),
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = 1,
		})
		corner(holder, 10)
		local nStroke = stroke(holder, Theme.Stroke, 1)
		gradient(nStroke, Theme.GradientA, Theme.GradientB, 45)

		new("TextLabel", {
			Parent = holder,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 8),
			Size = UDim2.new(1, -28, 0, 18),
			Font = Enum.Font.GothamSemibold,
			Text = notifTitle,
			TextColor3 = Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1,
		})

		local desc = new("TextLabel", {
			Parent = holder,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0, 28),
			Size = UDim2.new(1, -28, 0, 28),
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = Theme.SubText,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextTransparency = 1,
		})

		tween(holder, { BackgroundTransparency = 0 }, 0.3)
		for _, child in ipairs(holder:GetChildren()) do
			if child:IsA("TextLabel") then
				tween(child, { TextTransparency = 0 }, 0.3)
			end
		end

		task.delay(duration, function()
			tween(holder, { BackgroundTransparency = 1 }, 0.3)
			tween(desc, { TextTransparency = 1 }, 0.3)
			task.wait(0.3)
			holder:Destroy()
		end)
	end

	----------------------------------------------------------------
	-- TAB
	----------------------------------------------------------------
	function Window:CreateTab(name, icon)
		local iconImage = resolveIcon(icon)
		local iconSize = 16
		local textOffset = iconImage and 34 or 12

		local tabButton = new("TextButton", {
			Parent = TabList,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Theme.Element,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
		})
		corner(tabButton, 6)

		local tabIcon
		if iconImage then
			tabIcon = new("ImageLabel", {
				Parent = tabButton,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.new(0, iconSize, 0, iconSize),
				Image = iconImage,
				ImageColor3 = Theme.SubText,
			})
		end

		local tabLabel = new("TextLabel", {
			Parent = tabButton,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, textOffset, 0, 0),
			Size = UDim2.new(1, -textOffset - 8, 1, 0),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = Theme.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local page = new("ScrollingFrame", {
			Parent = pagesHolder,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.GradientA,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
		})
		new("UIPadding", {
			Parent = page,
			PaddingTop = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
		})
		local layout = new("UIListLayout", {
			Parent = page,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
		end)

		local function selectTab()
			for _, t in pairs(Window._tabs) do
				t.page.Visible = false
				tween(t.button, { BackgroundTransparency = 1 }, 0.15)
				tween(t.label, { TextColor3 = Theme.SubText }, 0.15)
				if t.icon then
					tween(t.icon, { ImageColor3 = Theme.SubText }, 0.15)
				end
			end
			page.Visible = true
			tween(tabButton, { BackgroundTransparency = 0 }, 0.15)
			tween(tabLabel, { TextColor3 = Theme.Text }, 0.15)
			if tabIcon then
				tween(tabIcon, { ImageColor3 = Theme.Text }, 0.15)
			end
		end

		tabButton.MouseButton1Click:Connect(selectTab)

		table.insert(Window._tabs, { button = tabButton, page = page, label = tabLabel, icon = tabIcon })
		if not Window._firstTab then
			Window._firstTab = true
			selectTab()
		end

		local Tab = {}

		----------------------------------------------------------------
		function Tab:CreateLabel(text)
			return new("TextLabel", {
				Parent = page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
		end

		----------------------------------------------------------------
		function Tab:CreateParagraph(title, content)
			title = title or ""
			content = content or ""

			-- AutomaticSize.Y on the holder + both labels lets the block
			-- grow to fit however much text SetTitle/SetContent puts in,
			-- and the page's UIListLayout picks up the new height via
			-- AbsoluteContentSize automatically (see `layout` above).
			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 8)
			new("UIPadding", {
				Parent = holder,
				PaddingTop = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
			})
			new("UIListLayout", {
				Parent = holder,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			local titleLabel = new("TextLabel", {
				Parent = holder,
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = Enum.Font.GothamBold,
				Text = title,
				RichText = true,
				TextWrapped = true,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = title ~= "",
			})

			local contentLabel = new("TextLabel", {
				Parent = holder,
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = Enum.Font.Gotham,
				Text = content,
				RichText = true,
				TextWrapped = true,
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = content ~= "",
			})

			return {
				SetTitle = function(_, newTitle)
					newTitle = newTitle or ""
					titleLabel.Text = newTitle
					titleLabel.Visible = newTitle ~= ""
				end,
				SetContent = function(_, newContent)
					newContent = newContent or ""
					contentLabel.Text = newContent
					contentLabel.Visible = newContent ~= ""
				end,
				GetTitle = function()
					return titleLabel.Text
				end,
				GetContent = function()
					return contentLabel.Text
				end,
			}
		end

		----------------------------------------------------------------
		function Tab:CreateButton(text, callback)
			local btn = new("TextButton", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Element,
				AutoButtonColor = false,
				Font = Enum.Font.Gotham,
				Text = "",
			})
			corner(btn, 8)
			new("TextLabel", {
				Parent = btn,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -24, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			btn.MouseButton1Click:Connect(function()
				tween(btn, { BackgroundColor3 = Theme.ElementHi }, 0.1)
				task.wait(0.1)
				tween(btn, { BackgroundColor3 = Theme.Element }, 0.15)
				pcall(callback)
			end)
			return btn
		end

		----------------------------------------------------------------
		-- WindUI "New Elements" toggle: a fully pill-shaped track (radius
		-- = half the row height, same look WindUI gets from its 23px
		-- corner radius on a New Elements row) plus a knob that responds
		-- to both a plain click and a drag -- drag it partway and let go,
		-- it snaps to whichever side it's closer to, exactly like WindUI's
		-- draggable switch.
		function Tab:CreateToggle(text, default, callback)
			local state = default or false

			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 19)

			new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -78, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local track = new("Frame", {
				Parent = holder,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 48, 0, 22),
				BackgroundColor3 = Theme.ElementHi,
			})
			corner(track, 11)
			stroke(track, Theme.Stroke, 1, 0.4)

			-- gradient fill layer, crossfaded in when ON
			local fill = new("Frame", {
				Parent = track,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Theme.GradientA,
				BackgroundTransparency = 1,
			})
			corner(fill, 11)
			gradient(fill, Theme.GradientA, Theme.GradientB, 0)

			local knobSize = 16
			local padding = 3
			local travel = track.Size.X.Offset - knobSize - padding * 2

			local knob = new("Frame", {
				Parent = track,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, padding, 0.5, 0),
				Size = UDim2.new(0, knobSize, 0, knobSize),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 2,
			})
			corner(knob, knobSize / 2)
			local knobScale = new("UIScale", { Parent = knob, Scale = 1 })

			local hitbox = new("TextButton", {
				Parent = track,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 3,
			})

			local function render(instant, on)
				local knobPos = on and UDim2.new(0, padding + travel, 0.5, 0) or UDim2.new(0, padding, 0.5, 0)
				local fillTransparency = on and 0 or 1
				if instant then
					knob.Position = knobPos
					fill.BackgroundTransparency = fillTransparency
				else
					tween(knob, { Position = knobPos }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					tween(fill, { BackgroundTransparency = fillTransparency }, 0.15, Enum.EasingStyle.Quint)
				end
			end
			render(true, state)

			local function set(v, fire)
				state = v
				render(false, state)
				if fire ~= false then
					pcall(callback, state)
				end
			end

			-- plain click anywhere on the track
			hitbox.MouseButton1Click:Connect(function()
				set(not state)
			end)

			-- drag the knob itself and release to snap to the nearest side
			local dragging = false
			knob.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				dragging = true
				tween(knobScale, { Scale = 1.2 }, 0.15)
			end)

			UserInputService.InputChanged:Connect(function(input)
				if not dragging then return end
				if input.UserInputType ~= Enum.UserInputType.MouseMovement
					and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local rel = (input.Position.X - track.AbsolutePosition.X - padding - knobSize / 2) / travel
				rel = math.clamp(rel, 0, 1)
				knob.Position = UDim2.new(0, padding + travel * rel, 0.5, 0)
				fill.BackgroundTransparency = 1 - rel
			end)

			UserInputService.InputEnded:Connect(function(input)
				if not dragging then return end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				dragging = false
				tween(knobScale, { Scale = 1 }, 0.15)
				local rel = (knob.Position.X.Offset - padding) / travel
				set(rel > 0.5)
			end)

			return {
				Set = function(_, v)
					set(v)
				end,
				Get = function()
					return state
				end,
			}
		end

		----------------------------------------------------------------
		function Tab:CreateSlider(text, min, max, default, callback)
			min, max = min or 0, max or 100
			local value = math.clamp(default or min, min, max)

			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 46),
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 8)

			new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 6),
				Size = UDim2.new(1, -70, 0, 16),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local valueLabel = new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 6),
				Size = UDim2.new(0, 50, 0, 16),
				Font = Enum.Font.GothamSemibold,
				Text = tostring(value),
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
			})

			local track = new("Frame", {
				Parent = holder,
				Position = UDim2.new(0, 12, 0, 28),
				Size = UDim2.new(1, -24, 0, 6),
				BackgroundColor3 = Theme.ElementHi,
			})
			corner(track, 3)

			local fill = new("Frame", {
				Parent = track,
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Theme.GradientA,
			})
			corner(fill, 3)
			gradient(fill, Theme.GradientA, Theme.GradientB, 0)

			local dragging = false

			local function setFromX(x)
				local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * rel + 0.5)
				valueLabel.Text = tostring(value)
				tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.08)
				pcall(callback, value)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setFromX(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
					setFromX(input.Position.X)
				end
			end)

			return {
				Set = function(_, v)
					value = math.clamp(v, min, max)
					local rel = (value - min) / (max - min)
					valueLabel.Text = tostring(value)
					tween(fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.15)
					pcall(callback, value)
				end,
				Get = function()
					return value
				end,
			}
		end

		----------------------------------------------------------------
		-- WindUI "New Elements" dropdown: the trigger is a pill-shaped
		-- row (same rounding as the New Elements toggle above), and
		-- opening it doesn't push anything else in the tab down --
		-- instead it drops a floating panel on its own overlay layer,
		-- positioned next to the row and flipped upward automatically if
		-- there isn't room below it on screen, matching WindUI's overlay
		-- dropdown menu.
		function Tab:CreateDropdown(text, options, default, callback)
			options = options or {}
			local selected = default or options[1]
			local open = false
			local optionButtons = {} -- opt -> button, so Set()/highlight can find it

			local ROW_HEIGHT = 30
			local MAX_MENU_HEIGHT = 220

			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 10)

			new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -112, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			-- compact pill "chip" -- the actual clickable control, holding
			-- the current value + chevron, same shape as the Config list
			-- control in the reference screenshot
			local chip = new("Frame", {
				Parent = holder,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 96, 0, 26),
				BackgroundColor3 = Theme.ElementHi,
			})
			corner(chip, 13)
			stroke(chip, Theme.Stroke, 1, 0.5)

			local selectedLabel = new("TextLabel", {
				Parent = chip,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = tostring(selected or "--"),
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
            
            local chevron = new("ImageLabel", {
			    Parent = chip,
			    BackgroundTransparency = 1,
			    AnchorPoint = Vector2.new(1, 0.5),
			    Position = UDim2.new(1, -8, 0.5, 0),
			    Size = UDim2.new(0, 12, 0, 12),
			    Image = resolveIcon("chevron-down"),
			    ImageColor3 = Theme.Text,
	    	})
		
			-- only the chip is interactive, matching the reference --
			-- the row label itself is just context, not a button
			local hitbox = new("TextButton", {
				Parent = chip,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 2,
			})

			-- the floating panel itself, parented to the overlay layer so
			-- it renders above every tab/page instead of resizing `holder`
			local menu = new("Frame", {
				Name = "DropdownMenu",
				Parent = dropdownGui,
				BackgroundColor3 = Theme.Panel,
				Visible = false,
				ClipsDescendants = true,
				Size = UDim2.new(0, 0, 0, 0),
			})
			corner(menu, 10)
			local menuStroke = stroke(menu, Theme.Stroke, 1)
			gradient(menuStroke, Theme.GradientA, Theme.GradientB, 45)

			local list = new("ScrollingFrame", {
				Parent = menu,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.GradientA,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			})
			new("UIPadding", {
				Parent = list,
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			})
			new("UIListLayout", {
				Parent = list,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			})

			local openMenu, closeMenu -- forward-declared, buildOptions() below calls closeMenu()

			local function computeHeight()
				local count = math.max(#options, 1)
				local contentHeight = count * ROW_HEIGHT + (count - 1) * 2 + 8
				return math.clamp(contentHeight, ROW_HEIGHT + 8, MAX_MENU_HEIGHT)
			end

			-- Rebuilds the option list from scratch. Used both on first
			-- build and by Refresh() when the options change at runtime.
			local function buildOptions()
				for _, child in ipairs(list:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				table.clear(optionButtons)

				for i, opt in ipairs(options) do
					local isSelected = opt == selected
					local optBtn = new("TextButton", {
						Parent = list,
						LayoutOrder = i,
						Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
						BackgroundColor3 = Theme.ElementHi,
						BackgroundTransparency = isSelected and 0.4 or 1,
						AutoButtonColor = false,
						Font = Enum.Font.Gotham,
						Text = "  " .. tostring(opt),
						TextColor3 = isSelected and Theme.Text or Theme.SubText,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
					})
					corner(optBtn, 6)
					optionButtons[opt] = optBtn

					optBtn.MouseEnter:Connect(function()
						if opt ~= selected then
							tween(optBtn, { BackgroundTransparency = 0.75 }, 0.12)
						end
					end)
					optBtn.MouseLeave:Connect(function()
						if opt ~= selected then
							tween(optBtn, { BackgroundTransparency = 1 }, 0.12)
						end
					end)

					optBtn.MouseButton1Click:Connect(function()
						local prev = optionButtons[selected]
						if prev and prev ~= optBtn then
							tween(prev, { BackgroundTransparency = 1 }, 0.12)
							tween(prev, { TextColor3 = Theme.SubText }, 0.12)
						end
						selected = opt
						selectedLabel.Text = tostring(opt)
						tween(optBtn, { BackgroundTransparency = 0.4 }, 0.12)
						tween(optBtn, { TextColor3 = Theme.Text }, 0.12)
						pcall(callback, selected)
						closeMenu()
					end)
				end
			end
			buildOptions()

			-- positions + sizes the panel right under `chip` (the circled
			-- control), flipping to open upward if there isn't room below
			-- it on screen, and clamped so it never runs off the right edge
			local function layoutMenu(targetHeight)
				local pos = chip.AbsolutePosition
				local size = chip.AbsoluteSize
				local viewportX = screenGui.AbsoluteSize.X
				local viewportY = screenGui.AbsoluteSize.Y
				local spaceBelow = viewportY - (pos.Y + size.Y) - 8
				local openUp = spaceBelow < targetHeight and pos.Y > spaceBelow

				local menuWidth = math.max(size.X, 170)
				local x = math.clamp(pos.X, 8, viewportX - menuWidth - 8)
				local y = openUp and (pos.Y - targetHeight - 6) or (pos.Y + size.Y + 6)

				menu.Position = UDim2.fromOffset(x, y)
				return menuWidth
			end

			openMenu = function()
				if activeDropdownClose then
					activeDropdownClose()
				end

				local targetHeight = computeHeight()
				local menuWidth = layoutMenu(targetHeight)
				menu.Size = UDim2.new(0, menuWidth, 0, 0)
				menu.Visible = true
				open = true
				tween(chevron, { Rotation = 180 }, 0.2)
				tween(menu, { Size = UDim2.new(0, menuWidth, 0, targetHeight) }, 0.22, Enum.EasingStyle.Quint)
				activeDropdownClose = closeMenu
			end

			closeMenu = function()
				if not open then return end
				open = false
				tween(chevron, { Rotation = 0 }, 0.2)
				local closeTween = tween(menu, { Size = UDim2.new(0, menu.Size.X.Offset, 0, 0) }, 0.18)
				closeTween.Completed:Once(function()
					if not open then
						menu.Visible = false
					end
				end)
				if activeDropdownClose == closeMenu then
					activeDropdownClose = nil
				end
			end

			hitbox.MouseButton1Click:Connect(function()
				if open then
					closeMenu()
				else
					openMenu()
				end
			end)

			-- click outside the row or the open panel closes it
			UserInputService.InputBegan:Connect(function(input)
				if not open then return end
				if input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local pos = input.Position
				local function inside(gui)
					local p, s = gui.AbsolutePosition, gui.AbsoluteSize
					return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
				end
				if not inside(holder) and not inside(menu) then
					closeMenu()
				end
			end)

			holder.Destroying:Connect(function()
				menu:Destroy()
			end)

			return {
				Set = function(_, v)
					local prev = optionButtons[selected]
					if prev then
						tween(prev, { BackgroundTransparency = 1 }, 0.12)
						tween(prev, { TextColor3 = Theme.SubText }, 0.12)
					end
					selected = v
					selectedLabel.Text = tostring(v)
					local btn = optionButtons[v]
					if btn then
						tween(btn, { BackgroundTransparency = 0.4 }, 0.12)
						tween(btn, { TextColor3 = Theme.Text }, 0.12)
					end
					pcall(callback, selected)
				end,
				Get = function()
					return selected
				end,
				-- Swap in a new option list at runtime (e.g. re-populating
				-- a "target player" dropdown). If `newval`'s current
				-- selection is still present in the new list it's kept,
				-- otherwise it falls back to the first option.
				Refresh = function(_, newval)
					newval = newval or {}
					options = newval
					local keepSelected = false
					for _, opt in ipairs(options) do
						if opt == selected then
							keepSelected = true
							break
						end
					end
					if not keepSelected then
						selected = options[1]
						selectedLabel.Text = tostring(selected or "")
					end
					buildOptions()
					if open then
						local targetHeight = computeHeight()
						local menuWidth = layoutMenu(targetHeight)
						tween(menu, { Size = UDim2.new(0, menuWidth, 0, targetHeight) }, 0.2)
					end
				end,
			}
		end

		----------------------------------------------------------------
		function Tab:CreateTextbox(text, placeholder, callback)
			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 8)

			new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.45, 0, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local box = new("TextBox", {
				Parent = holder,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0.45, 0, 0, 24),
				BackgroundColor3 = Theme.ElementHi,
				ClearTextOnFocus = false,
				PlaceholderText = placeholder or "",
				Font = Enum.Font.Gotham,
				Text = "",
				TextColor3 = Theme.Text,
				TextSize = 12,
			})
			corner(box, 6)
			new("UIPadding", { Parent = box, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

			box.FocusLost:Connect(function(enterPressed)
				if enterPressed and #box.Text > 0 then
					pcall(callback, box.Text)
				end
			end)

			return {
				Set = function(_, v)
					box.Text = v
				end,
				Get = function()
					return box.Text
				end,
			}
		end

		----------------------------------------------------------------
		function Tab:CreateKeybind(text, defaultKey, callback)
			local key = defaultKey or Enum.KeyCode.Unknown
			local binding = false

			local holder = new("Frame", {
				Parent = page,
				Size = UDim2.new(1, 0, 0, 38),
				BackgroundColor3 = Theme.Element,
			})
			corner(holder, 8)

			new("TextLabel", {
				Parent = holder,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -110, 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local keyBtn = new("TextButton", {
				Parent = holder,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0, 90, 0, 24),
				BackgroundColor3 = Theme.ElementHi,
				AutoButtonColor = false,
				Font = Enum.Font.Gotham,
				Text = key.Name,
				TextColor3 = Theme.SubText,
				TextSize = 12,
			})
			corner(keyBtn, 6)

			keyBtn.MouseButton1Click:Connect(function()
				if binding then return end
				binding = true
				keyBtn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if binding then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode
						keyBtn.Text = key.Name
						binding = false
					end
				elseif not processed
					and key ~= Enum.KeyCode.Unknown
					and input.UserInputType == Enum.UserInputType.Keyboard
					and input.KeyCode == key then
					pcall(callback)
				end
			end)

			return {
				Set = function(_, k)
					key = k
					keyBtn.Text = k.Name
				end,
				Get = function()
					return key
				end,
			}
		end

		return Tab
	end

	return Window
end

return Library
