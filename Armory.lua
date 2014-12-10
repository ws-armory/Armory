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
	self.isSelected = false
    return o
end

function Armory:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Armory OnLoad
-----------------------------------------------------------------------------------------------
function Armory:OnLoad()
    -- load our form file
	Apollo.LoadSprites("ArmorySprites.xml","ArmorySprites")
	self.xmlDoc = XmlDoc.CreateFromFile("Armory.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Armory OnDocLoaded
-----------------------------------------------------------------------------------------------
function Armory:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndArmory = Apollo.LoadForm(self.xmlDoc, "Armory", nil, self)
		if self.wndArmory == nil then
			Apollo.AddAddonErrorText(self, "Could not load the Armory window for some reason.")
			return
		end
	    self.wndArmory:Show(true)
	
		self.wndCopy = Apollo.LoadForm(self.xmlDoc, "Copy", nil, self)
		if self.wndCopy == nil then
			Apollo.AddAddonErrorText(self, "Could not load the Copy window for some reason.")
			return
		end
	    self.wndCopy:Show(false)
	
		self.xmlDoc = nil
	end
end

-----------------------------------------------------------------------------------------------
-- Armory Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Armory:OnMouseEnter( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndArmory then return end
	
	if not self.isSelected then
		self.wndArmory:SetSprite("ArmorySprites:Hover")
	end
end

function Armory:OnMouseExit( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndArmory then return end
	
	if not self.isSelected then
		self.wndArmory:SetSprite("ArmorySprites:Base")
	end
end

function Armory:OnMouseClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl ~= self.wndArmory then return end
	
	if self.isSelected then
		self.isSelected = false
		self.wndArmory:SetSprite("ArmorySprites:Base")
		self.wndCopy:Close() --self.wndCopy:Show(false)
	else
		self.isSelected = true
		self.wndArmory:SetSprite("ArmorySprites:Active")
		local data = Armory:LoadItems()
		self.wndCopy:Invoke() --self.wndCopy:Show(true)
		self.wndCopy:FindChild("CopyButton"):SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard,data)
	end
end


---------------------------------------------------------------------------------------------------
-- CopyButton Functions
---------------------------------------------------------------------------------------------------

function Armory:LoadItems()
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
	
	return url
end


-----------------------------------------------------------------------------------------------
-- Armory Instance
-----------------------------------------------------------------------------------------------
local ArmoryInst = Armory:new()
ArmoryInst:Init()
