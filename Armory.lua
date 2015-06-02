-----------------------------------------------------------------------------------------------
-- Client Lua Script for Armory
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"

-----------------------------------------------------------------------------------------------
-- Armory Module Definition
-----------------------------------------------------------------------------------------------
local Armory = {}
local ClassNames = {
	[GameLib.CodeEnumClass.Warrior] 	= Apollo.GetString("ClassWarrior"),
	[GameLib.CodeEnumClass.Engineer]	= Apollo.GetString("ClassEngineer"),
	[GameLib.CodeEnumClass.Esper] 		= Apollo.GetString("ClassESPER"),
	[GameLib.CodeEnumClass.Medic] 		= Apollo.GetString("ClassMedic"),
	[GameLib.CodeEnumClass.Stalker] 	= Apollo.GetString("ClassStalker"),
	[GameLib.CodeEnumClass.Spellslinger]	= Apollo.GetString("ClassSpellslinger"),
}

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
	self.wndArmory = nil
	self.wndCopy = nil
	return o
end

function Armory:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		"Lib:ApolloFixes-1.0",
		"Character",
	}
	Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end


-----------------------------------------------------------------------------------------------
-- Armory OnLoad
-----------------------------------------------------------------------------------------------
function Armory:OnLoad()
	self.addonChar = Apollo.GetAddon("Character")
	Apollo.RegisterEventHandler("ToggleCharacterWindow", "OnToggleCharacterWindow", self)

	-- load our form file
	Apollo.LoadSprites("ArmorySprites.xml","ArmorySprites")
	self.xmlDoc = XmlDoc.CreateFromFile("Armory.xml")

	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Armory Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Armory:OnDocLoaded()
	self.loaded = false
end

function Armory:OnToggleCharacterWindow(unitArg)
	if self.addonChar.wndCharacter:IsVisible() then
		self.wndArmory:Show(false)
		self.wndCopy:Show(false)
	else
		if not self.loaded and self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
			local wndParent = self.addonChar.wndCharacter:FindChild("CharFrame_BGArt")

			self.wndArmory = Apollo.LoadForm(self.xmlDoc, "Armory", wndParent, self)
			if self.wndArmory == nil then
				Apollo.AddAddonErrorText(self, "Could not load the Armory window for some reason.")
				return
			end

			self.wndCopy = Apollo.LoadForm(self.xmlDoc, "Copy", wndParent, self)
			if self.wndCopy == nil then
				Apollo.AddAddonErrorText(self, "Could not load the Copy window for some reason.")
				return
			end

			self.xmlDoc = nil
		end
		local nLeft, nTop, nRight, nBottom = self.addonChar.wndCharacter:FindChild("BGArt_HeaderFrame"):GetAnchorOffsets()
		self.wndArmory:SetAnchorOffsets(nLeft+7, nTop+47, (nLeft+40)+7, (nTop+38)+47) -- The size of the armory window is 40x38
		self.wndArmory:Show(true)
		self.wndCopy:Show(false)
		self.loaded = true
	end
end

function Armory:OnMouseEnter( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndArmory then return end

	if not self.wndCopy:IsShown() then
		self.wndArmory:SetSprite("ArmorySprites:Hover")
	end
end

function Armory:OnMouseExit( wndHandler, wndControl, x, y )
	if wndControl ~= self.wndArmory then return end

	if not self.wndCopy:IsShown() then
		self.wndArmory:SetSprite("ArmorySprites:Base")
	end
end

function Armory:OnMouseClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndControl ~= self.wndArmory then return end

	if self.wndCopy:IsShown() then
		self.wndCopy:Show(false,true)
		self.wndArmory:SetSprite("ArmorySprites:Base")
	else
		self.wndArmory:SetSprite("ArmorySprites:Active")
		self.wndCopy:FindChild("CopyButton"):SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard, Armory:LoadItems())

		local nLeft, nTop, nRight, nBottom = self.wndArmory:GetAnchorOffsets()
		self.wndCopy:SetAnchorOffsets((nLeft-240)-4, (nBottom-170), nLeft-4, nBottom) -- The size of the copy window is 240x170

		self.wndCopy:Show(true,true)
	end
end


---------------------------------------------------------------------------------------------------
-- CopyButton Functions
---------------------------------------------------------------------------------------------------

function Armory:LoadItems()
	local slotId
	local url
	local unit = GameLib.GetPlayerUnit()

	for key, item in ipairs(unit:GetEquippedItems()) do
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

	local title = unit:GetName() .. " - " .. ClassNames[unit:GetClassId()] .. " [" .. unit:GetLevel() .. "]"
	url = url .. "&title=" .. urlencode(title)

	return url
end


function Armory:OnCopyClosed( wndHandler, wndControl )
	if wndControl ~= self.wndCopy then return end

	-- Ugly hook to make it work with the "CloseOnExternalClick" style
	self.wndCopy:Invoke()
	self.wndCopy:Show(false,true)

	self.wndArmory:SetSprite("ArmorySprites:Base")
end

-- https://gist.github.com/ignisdesign/4323051
function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

-----------------------------------------------------------------------------------------------
-- Armory Instance
-----------------------------------------------------------------------------------------------
local ArmoryInst = Armory:new()
ArmoryInst:Init()
