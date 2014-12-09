-----------------------------------------------------------------------------------------------
-- Client Lua Script for Armory
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Armory Module Definition
-----------------------------------------------------------------------------------------------
local Armory = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local Website = "http://ws-armory.github.io"
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Armory:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function Armory:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Armory OnLoad
-----------------------------------------------------------------------------------------------
function Armory:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Armory.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Armory OnDocLoaded
-----------------------------------------------------------------------------------------------
function Armory:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Armory", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("armory", "OnArmoryOn", self)
		
		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- Armory Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/armory"
function Armory:OnArmoryOn()
	self.wndMain:Invoke() -- show the window
	self.wndMain:Show(not self.wndMain:IsVisible(), true)
end

-- when the Close button is clicked
function Armory:OnClose()
	self.wndMain:Close() -- hide the window
end

function Armory:OnMouseEnter( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndMain then return end
	self.wndMain:FindChild("Overlay"):SetSprite("ArmorySprites:Hover")
end

function Armory:OnMouseExit( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndMain then return end
	self.wndMain:FindChild("Overlay"):SetSprite("")
end

function Armory:OnMouseButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl ~= self.wndMain then return end
	self.wndMain:FindChild("Overlay"):SetSprite("ArmorySprites:Selected")
	self.wndMain:FindChild("CopyButton"):Show(true)
end

function Armory:OnMouseButtonUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	if wndControl ~= self.wndMain then return end
	self.wndMain:FindChild("Overlay"):SetSprite("")
end

---------------------------------------------------------------------------------------------------
-- CopyButton Functions
---------------------------------------------------------------------------------------------------

function Armory:OnCopy()
	local slotId
	local url

	for key, item in ipairs(GameLib.GetPlayerUnit():GetEquippedItems()) do
		slotId = item:GetSlot()
		-- Do not export Tool, Key and Bag items
		if slotId ~= 6 and slotId ~= 9 and slotId < 17 then
			if url == nil or url == '' then
				url = Website .. "/?" .. slotId .. "=" .. item:GetItemId()
			else
				url = url .. "&" ..slotId .. "=" .. item:GetItemId()
			end
		end
	end
	
	self.wndMain:FindChild("CopyButton"):SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard,url)
end


-----------------------------------------------------------------------------------------------
-- Armory Instance
-----------------------------------------------------------------------------------------------
local ArmoryInst = Armory:new()
ArmoryInst:Init()
