local Masque = LibStub("Masque")
local Masque_XPerlFrame = CreateFrame("Frame")

local AddOnName = "X-Perl UnitFrames"

local Masque_XPerl = {
	Groups = {},
	MasquedDebuffs = {}
}

-- X-Perl addons frame names for Masque groups
local XPerlAddOns = {}

-- Hook CreateFrame
function Masque_XPerl:CreateFrame(name)
	if type(name) ~= "string" then return end
	if strfind(name, "^XPerlBuff") or strfind(name, "^XPerl_*.*FrameAuraButton") then
		local button = _G[name]
		local XPerlAddOn = button:GetParent():GetParent():GetName()
		
		if not XPerlAddOn or Masque_XPerl.Groups[XPerlAddOn] == nil then return end

		Masque_XPerl.Groups[XPerlAddOn]:AddButton(button, {
			Icon		= _G[name.."icon"],
			Cooldown 	= _G[name.."cooldown"],
			Count 		= _G[name.."count"],
			Border 		= _G[name.."border"] or false -- Player buffs doesn't have border
		})
		-- Workaround for icons in top of Masque button skin
		if XPerlAddOn == "XPerl_Player" then
			Masque_XPerl.Groups.XPerl_Player:ReSkin()
		end
	end
end

-- Hook XPerl_PlayerBuffs_Show
function Masque_XPerl:PlayerBuffsShow()
	for i = 1, 40 do
		local name = "XPerl_PlayerdebuffFrameAuraButton"..i
		local button = _G[name]
		
		if not button then break end
		
		if not Masque_XPerl.MasquedDebuffs[name] then
			Masque_XPerl.Groups.XPerl_Player:AddButton(button, {
				Icon		= _G[name.."icon"],
				Cooldown	= _G[name.."cooldown"],
				Count		= _G[name.."count"],
				Border		= _G[name.."border"]
			})
			Masque_XPerl.MasquedDebuffs[name] = true
		end
	end
	Masque_XPerl.Groups.XPerl_Player:ReSkin()
end

function Masque_XPerl:Init()
	-- Masque every new buff
	hooksecurefunc("CreateFrame", Masque_XPerl.CreateFrame)
end

function Masque_XPerl:AddGroup(addon, name)
	XPerlAddOns[addon] = name
	Masque_XPerl.Groups[addon] = Masque:Group(AddOnName, name)
end

function Masque_XPerl:OnEvent(event, addon)
	if event == "ADDON_LOADED" then
		if addon == "XPerl_Party" then
			for i = 1, 4 do
				Masque_XPerl:AddGroup("XPerl_party"..i, "Party")
			end
		end
		if addon == "XPerl_Player" then Masque_XPerl:AddGroup(addon, "Player") end
		if addon == "XPerl_PlayerPet" then
			Masque_XPerl:AddGroup("XPerl_Player_Pet", "Player's pet")
			Masque_XPerl:AddGroup("XPerl_PetTarget", "Player's pet's target")
		end
		if addon == "XPerl_PartyPet" then Masque_XPerl:AddGroup(addon, "Party's pet") end
		if addon == "XPerl_Target" then Masque_XPerl:AddGroup(addon, "Target") end
		if addon == "XPerl_TargetTarget" then Masque_XPerl:AddGroup(addon, "Target's target") end
		if addon == "XPerl_PlayerBuffs" then hooksecurefunc("XPerl_PlayerBuffs_Show", Masque_XPerl.PlayerBuffsShow)	end
	end
end

Masque_XPerlFrame:SetScript("OnEvent", Masque_XPerl.OnEvent)
Masque_XPerlFrame:RegisterEvent("ADDON_LOADED")
Masque_XPerl:Init()