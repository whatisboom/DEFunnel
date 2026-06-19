local addonName, addonTable = ...
local DEFunnel = addonTable.DEFunnel or _G.DEFunnel

-- Optional ElvUI skin support.
-- Safe without ElvUI: exits silently when ElvUI is not installed/enabled.

local function GetElvUISkinModule()
    if not _G.ElvUI then
        return nil
    end

    local E = unpack(_G.ElvUI)
    if not E or not E.GetModule then
        return nil
    end

    return E:GetModule("Skins", true)
end

local function ResetButtonTextures(button)
    if not button then
        return
    end

    if button.SetNormalTexture then button:SetNormalTexture(nil) end
    if button.SetPushedTexture then button:SetPushedTexture(nil) end
    if button.SetDisabledTexture then button:SetDisabledTexture(nil) end
    if button.SetHighlightTexture then button:SetHighlightTexture(nil) end
end

local function SkinButton(button)
    if not button or button.IsElvUISkinned then
        return
    end

    local S = GetElvUISkinModule()
    if not S then
        return
    end

    if S.HandleButton then
        S:HandleButton(button)
    else
        ResetButtonTextures(button)
        if button.SetTemplate then
            button:SetTemplate("Default")
        end
    end

    button.IsElvUISkinned = true
end

function DEFunnel:SkinElvUI()
    local button = self.MailFrame and self.MailFrame.button or _G.DEFunnelSendButton
    SkinButton(button)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("MAIL_SHOW")
eventFrame:SetScript("OnEvent", function()
    if not DEFunnel or not DEFunnel.SkinElvUI then
        return
    end

    -- DEFunnel creates its mail button during MAIL_SHOW. Defer one frame so
    -- the original MailFrame:OnShow handler has time to create self.button.
    C_Timer.After(0, function()
        if DEFunnel and DEFunnel.SkinElvUI then
            DEFunnel:SkinElvUI()
        end
    end)
end)
