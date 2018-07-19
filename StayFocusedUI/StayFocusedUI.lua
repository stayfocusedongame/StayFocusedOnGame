---
--- Created by stayfocusedongame.
--- DateTime: 2018/07/19 12:00
---
STAYFOCUSED, STAYFOCUSEDEVENTS = CreateFrame("FRAME", "STAYFOCUSED"), {};
LibItemLevel = LibStub:GetLibrary("LibItemLevel.7000");
token = "";
--- TECH-001 :
-- Create hidden frame attached to UIParent for secure hiding ui elements
STAYFOCUSED_HIDE = CreateFrame("FRAME", "STAYFOCUSED_HIDE", UIParent);
STAYFOCUSED_HIDE:Hide();
--- TECH-002 :
-- Add a centralized moving function with frame, parent, point, relative to, relative point, x offset, y offset and scale options
function MoveElement(frame, parent, point, relativeto, relativepoint, xoffset, yoffset, scale)
    if parent ~= nil then
        frame:SetParent(parent);
    end;
    frame:ClearAllPoints();
    frame:SetPoint(point, relativeto, relativepoint, xoffset, yoffset);
    if scale ~= nil then
        frame:SetScale(scale);
    end;
end;
--- MOD-UI-001 :
-- Move FPS frame on bottom left corner
-- Associated with SLASH-CMD-004
FramerateLabel:ClearAllPoints();
FramerateLabel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0);
FramerateLabel:Hide();
FramerateText:ClearAllPoints();
FramerateText:SetPoint("LEFT", FramerateLabel, "RIGHT");
FramerateText:Hide();
--- TECH-003 :
-- Create a screen grid frame with colored lines to align ui elements
-- Associated with SLASH-CMD-005 and SLASH-CMD-006
STAYFOCUSED_GRID = CreateFrame("FRAME", "STAYFOCUSED_GRID", UIParent);
STAYFOCUSED_GRID:SetAllPoints(UIParent);
STAYFOCUSED_GRID:Hide();
for i = 0, 64 do
    column = GetScreenWidth() / 64;
    line = GetScreenHeight() / 64;
    horizontal = STAYFOCUSED_GRID:CreateTexture(nil, "BACKGROUND");
    vertical = STAYFOCUSED_GRID:CreateTexture(nil, "BACKGROUND");
    if i == 64 * .75 or i == 64 * .5 or i == 64 * .25 then
        horizontal:SetColorTexture(1, 0, 0, 0.5);
        vertical:SetColorTexture(1, 0, 0, 0.5);
    else
        horizontal:SetColorTexture(0, 0, 0, 0.1);
        vertical:SetColorTexture(0, 0, 0, 0.1);
    end;
    horizontal:SetPoint("TOPLEFT", STAYFOCUSED_GRID, "TOPLEFT", i * column - 1, 0);
    horizontal:SetPoint("BOTTOMRIGHT", STAYFOCUSED_GRID, "BOTTOMLEFT", i * column + 1, 0);
    vertical:SetPoint("TOPLEFT", STAYFOCUSED_GRID, "TOPLEFT", 0, -i * line + 1);
    vertical:SetPoint("BOTTOMRIGHT", STAYFOCUSED_GRID, "TOPRIGHT", 0, -i * line - 1);
end;
--- TECH-004 :
-- Set game variables to show LUA warnings and LUA errors
-- Print variables status in chat
-- Associated with SLASH-CMD-002
function LuaDebugOn()
    SetCVar("scriptErrors", 1);
    SetCVar("scriptWarnings", 1);
    print("scriptErrors enabled");
end;
--- TECH-005 :
-- Set game variables to hide LUA warnings and LUA errors
-- Print variables status in chat
-- Associated with SLASH-CMD-003
function LuaDebugOff()
    SetCVar("scriptErrors", 0);
    SetCVar("scriptWarnings", 0);
    print("scriptErrors disabled");
end;
--- FUNC-001 :
-- Perform ready check when in raid or group, if player is not leader or assistant, print help message in chat
-- Associated with SLASH-CMD-007
function AskIfReady()
    if GetLocale() == "frFR" then
        isNotRaidLeaderOrAssist = "Vous devez être leader ou assistant pour effectuer un readycheck !";
    else
        isNotRaidLeaderOrAssist = "You have to be leader or assistant to perform ready check !";
    end;
    if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
        DoReadyCheck();
    else
        print(isNotRaidLeaderOrAssist);
    end;
end;
--- FUNC-002 :
-- Perform 10 sec boss pull countdown
-- Send raid chat message - or self whisper - at beginning, at pre potion (1 sec) and at pulling
-- Synchronize with DBM and BIGWIGS boss pull timer
-- Can be canceled
-- Associated with SLASH-CMD-008 and SLASH-CMD-009
cancel = false;
function PullOnChat(time)
    STAYFOCUSED_PULL = CreateFrame("FRAME", nil);
    cdtime = time + 1;
    throttle = cdtime;
    ending = false;
    start = math.floor(GetTime());
    if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
        channel = "RAID";
        user = nil;
    else
        channel = "WHISPER";
        user = UnitName("player");
    end;
    STAYFOCUSED_PULL:SetScript("OnUpdate", function()
        if cancel ~= true then
            if ending == true then
                return
            end;
            countdown = (start - math.floor(GetTime()) + cdtime);
            if (countdown + 1) == throttle and countdown >= 0 then
                if countdown == 0 then
                    SendChatMessage('Pulling', channel, nil, user);
                    throttle = countdown;
                    ending = true;
                elseif countdown == 1 then
                    SendChatMessage('Pre-pot', channel, nil, user);
                    throttle = countdown;
                elseif countdown < 10 and countdown > 5 then
                    throttle = countdown;
                elseif countdown == 10 then
                    SendChatMessage(countdown, channel, nil, user);
                    if IsAddOnLoaded("DBM-Core") then
                        SlashCmdList["DEADLYBOSSMODS"]("pull 10");
                    end;
                    if IsAddOnLoaded("BigWigs_Plugins") then
                        SlashCmdList["BIGWIGSPULL"]("/pull 10");
                    end;
                    throttle = countdown;
                else
                    SendChatMessage(countdown, channel, nil, user);
                    throttle = countdown;
                end;
            end;
        end;
    end);
end;
--- SLASH-CMD-001 :
-- Add in game slash command (/sf rl) to reload ui
--- SLASH-CMD-002 :
-- Add in game slash command (/sf debugon) to enable LUA warnings and LUA errors
-- Associated with TECH-004
--- SLASH-CMD-003 :
-- Add in game slash command (/sf debugon) to hide LUA warnings and LUA errors
-- Associated with TECH-005
--- SLASH-CMD-004 :
-- Add in game slash command (/sf fps) to enable and disable FPS frame
-- Associated with MOD-UI-001
--- SLASH-CMD-005 :
-- Add in game slash command (/sf gridoff) to hide screen grid frame
-- Associated with TECH-003
--- SLASH-CMD-006 :
-- Add in game slash command (/sf gridon) to show screen grid frame
-- Associated with TECH-003
--- SLASH-CMD-007 :
-- Add in game slash command (/sf rc) to perform ready check
-- Associated with FUNC-001
--- SLASH-CMD-008 :
-- Add in game slash command (/sf pull) to start boss pull countdown
-- Associated with FUNC-002
--- SLASH-CMD-009 :
-- Add in game slash command (/sf stop) to stop boss pul countdown
-- Associated with FUNC-002
--- SLASH-CMD-010 :
-- Send help message with all available slash commands when use an unknown slash command
SLASH_SF1 = "/sf";
SlashCmdList.SF = function(option)
    if option == "rl" then
        ReloadUI();
    elseif option == "debugon" then
        LuaDebugOn();
    elseif option == "debugoff" then
        LuaDebugOff();
    elseif option == "fps" then
        ToggleFramerate();
    elseif option == "gridon" then
        STAYFOCUSED_GRID:Show();
    elseif option == "gridoff" then
        STAYFOCUSED_GRID:Hide();
    elseif option == "rc" then
        AskIfReady();
    elseif option == "pull" then
        PullOnChat(10);
    elseif option == "stop" then
        cancel = true;
        if IsAddOnLoaded("DBM-Core") then
            SlashCmdList["DEADLYBOSSMODS"]("pull -1");
        elseif IsAddOnLoaded("BigWigs_Plugins") then
            SlashCmdList["BIGWIGSPULL"]("/pull 0");
		else
			if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				channel = "RAID";
				user = nil;
			else
				channel = "WHISPER";
				user = UnitName("player");
			end;
			SendChatMessage('WARNING DO NOT PULL !', channel, nil, user);
		end;
    else
        print("Stay Focused Commands :");
        print("/sf rl = reload ui");
        print("/sf debugon = enable lua debug");
        print("/sf debugoff = disable lua debug");
        print("/sf fps = toggle fps");
        print("/sf gridon = show screen grid");
        print("/sf gridoff = hide screen grid");
        print("/sf rc = perform ready check");
        print("/sf pull = pull timer 10 sec");
        print("/sf stop = stop pull timer");
    end;
end;
--- TECH-006 :
-- Add a centralized function witch send as a raid warning with message, sender, canal, sound options
-- Associated with FUNC-005
function SendAs(message, sender, canal, sound)
    name = string.gsub(sender, "-%" .. string.gsub(GetRealmName(), " ", ""), "");
    RaidNotice_AddMessage(RaidWarningFrame, "\\" .. canal .. " [" .. date("%H:%M") .. " " .. name .. "] " .. message, ChatTypeInfo[canal]);
    if sound ~= nil then
        PlaySoundFile(sound, "Master");
    end;
end;
--- TECH-007 :
-- Set game variables (raid frames, advanced combat logging, floating combat text, sound, camera, threat, screenshot ...)
SetCVar("ActionButtonUseKeyDown", 1);
SetCVar("ShowNamePlateLoseAggroFlash", 1);
SetCVar("Sound_AmbienceVolume", 0.5);
SetCVar("Sound_EnableArmorFoleySoundForOthers", 0);
SetCVar("Sound_EnableArmorFoleySoundForSelf", 1);
SetCVar("Sound_EnableEmoteSounds", 1);
SetCVar("Sound_EnableErrorSpeech", 0);
SetCVar("Sound_EnableMusic", 0);
SetCVar("Sound_EnableSFX", 1);
SetCVar("Sound_EnableSoundWhenGameIsInBG", 1);
SetCVar("Sound_ListenerAtCharacter", 1);
SetCVar("Sound_MasterVolume", 0.5);
SetCVar("Sound_MusicVolume", 0.5);
SetCVar("Sound_SFXVolume", 0.5);
SetCVar("UberTooltips", 1);
SetCVar("UnitNameFriendlyGuardianName", 0);
SetCVar("UnitNameFriendlyMinionName", 0);
SetCVar("UnitNameFriendlyPetName", 0);
SetCVar("UnitNameFriendlyPlayerName", 0);
SetCVar("UnitNameFriendlySpecialNPCName", 0);
SetCVar("UnitNameFriendlyTotemName", 0);
SetCVar("UnitNameHostleNPC", 0);
SetCVar("UnitNameInteractiveNPC", 0);
SetCVar("UnitNameNPC", 1);
SetCVar("UnitNameNonCombatCreatureName", 1);
SetCVar("addFriendInfoShown", 1);
SetCVar("advancedCombatLogging", 1);
SetCVar("advancedWatchFrame", 1);
SetCVar("alwaysCompareItems", 1);
SetCVar("autoDismount", 1);
SetCVar("autoDismountFlying", 1);
SetCVar("autoInteract", 0);
SetCVar("autoLootDefault", 1);
SetCVar("autoLootRate", 0.1);
SetCVar("cameraDistanceMaxZoomFactor", 2.6);
SetCVar("cameraSavedDistance", 25);
SetCVar("cameraSavedPitch", 33);
SetCVar("cameraSmoothStyle", 0);
SetCVar("cameraSmoothTrackingStyle", 0);
SetCVar("chatBubbles", 1);
SetCVar("chatBubblesParty", 0);
SetCVar("chatStyle", "im");
SetCVar("colorChatNamesByClass", 1);
SetCVar("countdownForCooldowns", 1);
SetCVar("deselectOnClick", 1);
SetCVar("displayFreeBagSlots", 1);
SetCVar("findYourselfAnywhere", 0);
SetCVar("findYourselfMode", 1);
SetCVar("enableFloatingCombatText", 1);
SetCVar("floatingCombatTextAllSpellMechanics", 0);
SetCVar("floatingCombatTextAuras", 0);
SetCVar("floatingCombatTextCombatDamage", 0);
SetCVar("floatingCombatTextCombatDamageAllAutos", 0);
SetCVar("floatingCombatTextCombatDamageDirectionalOffset", 0);
SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0);
SetCVar("floatingCombatTextCombatHealing", 1);
SetCVar("floatingCombatTextCombatHealingAbsorbSelf", 0);
SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 0);
SetCVar("floatingCombatTextCombatLogPeriodicSpells", 0);
SetCVar("floatingCombatTextCombatState", 0);
SetCVar("floatingCombatTextComboPoints", 0);
SetCVar("floatingCombatTextDamageReduction", 0);
SetCVar("floatingCombatTextDodgeParryMiss", 0);
SetCVar("floatingCombatTextEnergyGains", 0);
SetCVar("floatingCombatTextFloatMode", 3);-- 1 = up, 2 = down, 3 = arc
SetCVar("floatingCombatTextFriendlyHealers", 0);
SetCVar("floatingCombatTextHonorGains", 0);
SetCVar("floatingCombatTextLowManaHealth", 0);
SetCVar("floatingCombatTextPeriodicEnergyGains", 0);
SetCVar("floatingCombatTextPetMeleeDamage", 0);
SetCVar("floatingCombatTextPetSpellDamage", 0);
SetCVar("floatingCombatTextReactives", 0);
SetCVar("floatingCombatTextReactives", 0);
SetCVar("floatingCombatTextRepChanges", 0);
SetCVar("floatingCombatTextSpellMechanics", 0);
SetCVar("floatingCombatTextSpellMechanicsOther", 0);
SetCVar("fullSizeFocusFrame", 0);
SetCVar("gametip", 0);
SetCVar("guildMemberNotify", 1);
SetCVar("guildShowOffline", 0);
SetCVar("lockActionBars", 1);
SetCVar("mapFade", 0);
SetCVar("nameplateMaxDistance", 40);
SetCVar("nameplateOtherAtBase", 0);
SetCVar("nameplateOtherBottomInset", -1);
SetCVar("nameplateOthertopInset", -1);
SetCVar("profanityFilter", 0);
SetCVar("rotateMinimap", 1);
SetCVar("screenshotFormat", "jpg");
SetCVar("screenshotQuality", 10);
SetCVar("showArenaEnemyCastbar", 1);
SetCVar("showArenaEnemyFrames", 1);
SetCVar("showArenaEnemyPets", 1);
SetCVar("showHonorAsExperience", 1);
SetCVar("showNPETutorials", 0);
SetCVar("showSpectatorTeamCircles", 1);
SetCVar("showTargetOfTarget", 1);
SetCVar("showTutorials", 0);
SetCVar("spamFilter", 1);
SetCVar("splashScreenBoost", 1);
SetCVar("splashScreenNormal", 11);
SetCVar("statusText", 1);
SetCVar("statusTextDisplay", "BOTH");
SetCVar("threatPlaySounds", 1);
SetCVar("threatShowNumeric", 1);
SetCVar("threatWarning", 3);
SetCVar("threatWorldText", 1);
SetCVar("toastDuration", 0);
SetCVar("trackQuestSorting", "proximity");
SetCVar("useCompactPartyFrames", 1);
SetCVar("violenceLevel", 5);
SetCVar("whisperMode", "popout_and_inline");
SetCVar("worldPreloadNonCritical", 0);
SetCVar("xpBarText", 1);
--- FUNC-003 :
-- Enable mousewheel zoom on minimap
Minimap:EnableMouseWheel(true);
Minimap:SetScript('OnMouseWheel', function(self, delta)
    if delta > 0 then
        Minimap_ZoomIn();
    else
        Minimap_ZoomOut();
    end;
end);
--- MOD-UI-002 :
-- Merge minimap's calendar button and minimap's tracking button
MiniMapTracking:ClearAllPoints();
MiniMapTracking:SetAllPoints(GameTimeFrame);
MiniMapTrackingButton:SetScript("OnMouseDown", function(self, btn)
    if btn == "RightButton" then
        GameTimeFrame:Click();
    end;
end);
--- MOD-UI-003 :
-- Adjust hall and garrison scales
GarrisonLandingPageMinimapButton:SetScale(0.65);
--- MOD-UI-004 :
-- Hide UIErrorFrame, unwanted bar elements and unwanted minimap elements
for _, f in next, { UIErrorsFrame, PossessBackground1, PossessBackground2, SlidingActionBarTexture0, SlidingActionBarTexture1, StanceBarLeft, StanceBarMiddle, StanceBarRight, ActionButton1NormalTexture, MultiBarBottomLeftButton1NormalTexture, MultiBarBottomLeftButton1FloatingBG,
    MultiBarBottomRightButton1NormalTexture, MultiBarBottomRightButton1FloatingBG, MultiBarLeftButton1NormalTexture, MultiBarLeftButton1FloatingBG, MultiBarRightButton1NormalTexture, MultiBarRightButton1FloatingBG, ActionButton2NormalTexture, MultiBarBottomLeftButton2NormalTexture,
    MultiBarBottomLeftButton2FloatingBG, MultiBarBottomRightButton2NormalTexture, MultiBarBottomRightButton2FloatingBG, MultiBarLeftButton2NormalTexture, MultiBarLeftButton2FloatingBG, MultiBarRightButton2NormalTexture, MultiBarRightButton2FloatingBG, ActionButton3NormalTexture,
    MultiBarBottomLeftButton3NormalTexture, MultiBarBottomLeftButton3FloatingBG, MultiBarBottomRightButton3NormalTexture, MultiBarBottomRightButton3FloatingBG, MultiBarLeftButton3NormalTexture, MultiBarLeftButton3FloatingBG, MultiBarRightButton3NormalTexture, MultiBarRightButton3FloatingBG,
    ActionButton4NormalTexture, MultiBarBottomLeftButton4NormalTexture, MultiBarBottomLeftButton4FloatingBG, MultiBarBottomRightButton4NormalTexture, MultiBarBottomRightButton4FloatingBG, MultiBarLeftButton4NormalTexture, MultiBarLeftButton4FloatingBG,
    MultiBarRightButton4NormalTexture, MultiBarRightButton4FloatingBG, ActionButton5NormalTexture, MultiBarBottomLeftButton5NormalTexture, MultiBarBottomLeftButton5FloatingBG, MultiBarBottomRightButton5NormalTexture, MultiBarBottomRightButton5FloatingBG, MultiBarLeftButton5NormalTexture,
    MultiBarLeftButton5FloatingBG, MultiBarRightButton5NormalTexture, MultiBarRightButton5FloatingBG, ActionButton6NormalTexture, MultiBarBottomLeftButton6NormalTexture, MultiBarBottomLeftButton6FloatingBG, MultiBarBottomRightButton6NormalTexture, MultiBarBottomRightButton6FloatingBG,
    MultiBarLeftButton6NormalTexture, MultiBarLeftButton6FloatingBG, MultiBarRightButton6NormalTexture, MultiBarRightButton6FloatingBG, ActionButton7NormalTexture, MultiBarBottomLeftButton7NormalTexture, MultiBarBottomLeftButton7FloatingBG, MultiBarBottomRightButton7NormalTexture,
    MultiBarBottomRightButton7FloatingBG, MultiBarLeftButton7NormalTexture, MultiBarLeftButton7FloatingBG, MultiBarRightButton7NormalTexture, MultiBarRightButton7FloatingBG, ActionButton8NormalTexture, MultiBarBottomLeftButton8NormalTexture, MultiBarBottomLeftButton8FloatingBG,
    MultiBarBottomRightButton8NormalTexture, MultiBarBottomRightButton8FloatingBG, MultiBarLeftButton8NormalTexture, MultiBarLeftButton8FloatingBG, MultiBarRightButton8NormalTexture, MultiBarRightButton8FloatingBG, ActionButton9NormalTexture, MultiBarBottomLeftButton9NormalTexture,
    MultiBarBottomLeftButton9FloatingBG, MultiBarBottomRightButton9NormalTexture, MultiBarBottomRightButton9FloatingBG, MultiBarLeftButton9NormalTexture, MultiBarLeftButton9FloatingBG, MultiBarRightButton9NormalTexture, MultiBarRightButton9FloatingBG, ActionButton10NormalTexture,
    MultiBarBottomLeftButton10NormalTexture, MultiBarBottomLeftButton10FloatingBG, MultiBarBottomRightButton10NormalTexture, MultiBarBottomRightButton10FloatingBG, MultiBarLeftButton10NormalTexture, MultiBarLeftButton10FloatingBG, MultiBarRightButton10NormalTexture, MultiBarRightButton10FloatingBG,
    ActionButton11NormalTexture, MultiBarBottomLeftButton11NormalTexture, MultiBarBottomLeftButton11FloatingBG, MultiBarBottomRightButton11NormalTexture, MultiBarBottomRightButton11FloatingBG, MultiBarLeftButton11NormalTexture, MultiBarLeftButton11FloatingBG, MultiBarRightButton11NormalTexture,
    MultiBarRightButton11FloatingBG, ActionButton12NormalTexture, MultiBarBottomLeftButton12NormalTexture, MultiBarBottomLeftButton12FloatingBG, MultiBarBottomRightButton12NormalTexture, MultiBarBottomRightButton12FloatingBG, MultiBarLeftButton12NormalTexture, MultiBarLeftButton12FloatingBG,
    MultiBarRightButton12NormalTexture, MultiBarRightButton12FloatingBG, GameTimeFrame, MiniMapWorldMapButton, MinimapBorderTop, MinimapZoomIn, MinimapZoomOut, MiniMapTrackingBackground, MiniMapTrackingButtonBorder, QueueStatusMinimapButtonBorder, MiniMapMailBorder,
} do
    f:SetParent(STAYFOCUSED_HIDE);
    f:SetAlpha(0);
    f:Hide();
end;
--- MOD-UI-005 :
-- Move objective tracker on upper left corner
-- Set objective tracker max height at 75% screen
delpos = ObjectiveTrackerFrame.ClearAllPoints;
setpos = ObjectiveTrackerFrame.SetPoint;
hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(self, anchorpoint, relativeto, xoffset, yoffset)
    delpos(self);
    setpos(self, "TOPLEFT", 30, -10);
    self:SetHeight(GetScreenHeight() * .75);
end);
--- MOD-UI-006 :
-- Clean chat frame
for i = 1, NUM_CHAT_WINDOWS do
    _G["ChatFrame" .. i .. "EditBoxLeft"]:SetAlpha(0);
    _G["ChatFrame" .. i .. "EditBoxRight"]:SetAlpha(0);
    _G["ChatFrame" .. i .. "EditBoxMid"]:SetAlpha(0);
    _G["ChatFrame" .. i .. "TabLeft"]:SetAlpha(0);
    _G["ChatFrame" .. i .. "TabRight"]:SetAlpha(0);
    _G["ChatFrame" .. i .. "TabMiddle"]:SetAlpha(0);
end;
for _, value in ipairs(CHAT_FRAME_TEXTURES) do
    for i = 1, NUM_CHAT_WINDOWS, 1 do
        _G["ChatFrame" .. i .. value]:Hide();
        _G["ChatFrame" .. i .. value].Show = function()
        end;
        _G["ChatFrame" .. i .. value]:SetAlpha(0);
        _G["ChatFrame" .. i .. value].SetAlpha = function()
        end;
    end;
end;
--- MOD-UI-007 :
-- Move chat frame to lower left corner
ChatFrame1:ClearAllPoints();
ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -150);
ChatFrame1.ClearAllPoints = function()
end;
ChatFrame1.SetPoint = function()
end;
ChatFrame1:SetUserPlaced(true);
--- MOD-UI-008 :
-- Move player, target and focus frames on right side closer to center
MoveElement(PlayerFrame, nil, "CENTER", UIParent, "CENTER", 200, -110, nil);
PlayerFrame:SetUserPlaced(true);
PlayerFrame.SetPoint = function()
end;
MoveElement(TargetFrame, nil, "CENTER", UIParent, "CENTER", 300, -20, nil);
TargetFrame:SetUserPlaced(true);
TargetFrame.SetPoint = function()
end;
MoveElement(FocusFrame, nil, "CENTER", UIParent, "CENTER", 363, 80, nil);
FocusFrame:SetUserPlaced(true);
FocusFrame.SetPoint = function()
end;
--- MOD-UI-009 :
-- Move, adjust scales and clean cast bars (player, target and focus)
CastingBarFrame:HookScript("OnShow", function(self)
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    self.SetPoint = function()
    end;
    self:SetHeight(12);
    self:SetWidth(200);
    self.Border:Hide(0);
    self.BorderShield:Hide(0);
    self.Flash:Hide(0);
    self.Flash:SetAlpha(0);
    self.Flash:SetTexture(nil);
    self.Text:ClearAllPoints();
    self.Text:SetPoint("CENTER", 0, 0);
    self.Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
end);
TargetFrameSpellBar:HookScript("OnShow", function(self)
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 20);
    self.SetPoint = function()
    end;
    self:SetHeight(12);
    self:SetWidth(200);
    self.Border:Hide(0);
    self.BorderShield:Hide(0);
    self.Flash:Hide(0);
    self.Flash:SetAlpha(0);
    self.Flash:SetTexture(nil);
    self.Text:ClearAllPoints();
    self.Text:SetPoint("CENTER", 0, 0);
    self.Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
end);
FocusFrameSpellBar:HookScript("OnShow", function(self)
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 40);
    self.SetPoint = function()
    end;
    self:SetHeight(12);
    self:SetWidth(200);
    self.Border:Hide(0);
    self.BorderShield:Hide(0);
    self.Flash:Hide(0);
    self.Flash:SetAlpha(0);
    self.Flash:SetTexture(nil);
    self.Text:ClearAllPoints();
    self.Text:SetPoint("CENTER", 0, 0);
    self.Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE");
end);
--- MOD-UI-010 :
-- Replace portraits by class icons (player, target and focus)
hooksecurefunc("UnitFramePortrait_Update", function(self)
    if self.portrait then
        if UnitIsPlayer(self.unit) then
            local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))];
            if t then
                self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
                self.portrait:SetTexCoord(unpack(t));
            end;
        else
            self.portrait:SetTexCoord(0, 1, 0, 1);
        end;
    end;
end);
--- MOD-UI-011 :
-- Colorize unit frames background with class color (player, focus and target)
local colornamebg = CreateFrame("FRAME");
colornamebg:RegisterEvent("GROUP_ROSTER_UPDATE");
colornamebg:RegisterEvent("PLAYER_TARGET_CHANGED");
colornamebg:RegisterEvent("PLAYER_FOCUS_CHANGED");
colornamebg:RegisterEvent("UNIT_FACTION");
local function eventHandler(self, event, ...)
    if PlayerFrame:IsShown() and not PlayerFrame.bg then
        c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[select(2, UnitClass("player"))] or RAID_CLASS_COLORS[select(2, UnitClass("player"))];
        bg = PlayerFrame:CreateTexture();
        bg:SetPoint("TOPLEFT", PlayerFrameBackground);
        bg:SetPoint("BOTTOMRIGHT", PlayerFrameBackground, 0, 22);
        bg:SetTexture(TargetFrameNameBackground:GetTexture());
        bg:SetVertexColor(c.r, c.g, c.b);
        PlayerFrame.bg = true;
    end;
    if UnitIsPlayer("target") then
        c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[select(2, UnitClass("target"))] or RAID_CLASS_COLORS[select(2, UnitClass("target"))];
        TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b);
    end;
    if UnitIsPlayer("focus") then
        c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[select(2, UnitClass("focus"))] or RAID_CLASS_COLORS[select(2, UnitClass("focus"))];
        FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b);
    end;
end;
colornamebg:SetScript("OnEvent", eventHandler);
for _, BarTextures in pairs({ TargetFrameNameBackground, FocusFrameNameBackground }) do
    BarTextures:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
end;
--- MOD-UI-012 :
-- Colorize unit frames health bar with class color (player, target and focus)
local function colour(statusbar, unit)
    local _, class, c;
    if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
        _, class = UnitClass(unit);
        c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
        _, myclass = UnitClass("player");
        p = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[myclass] or RAID_CLASS_COLORS[myclass];
        statusbar:SetStatusBarColor(c.r, c.g, c.b);
        PlayerFrameHealthBar:SetStatusBarColor(p.r, p.g, p.b);
    end;
end;
hooksecurefunc("UnitFrameHealthBar_Update", colour)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
    colour(self, self.unit);
end);
--- MOD-UI-013 :
-- Hide player and pet hit indicator
PlayerHitIndicator:SetText(nil);
PlayerHitIndicator.SetText = function()
end;
PetHitIndicator:SetText(nil);
PetHitIndicator.SetText = function()
end;
--- MOD-UI-014 :
-- Hide target buff and debuff
hooksecurefunc("TargetFrame_UpdateAuraPositions", function(self)
    for i = 1, 40 do
        debuff, buff = _G["TargetFrameDebuff" .. i], _G["TargetFrameBuff" .. i];
        if debuff then
            debuff:Hide();
        end;
        if buff then
            buff:Hide();
        end;
    end;
end);
for i = 1, 40 do
    debuff, buff = _G["TargetFrameDebuff" .. i], _G["TargetFrameBuff" .. i];
    if debuff then
        debuff:Hide();
    end;
    if buff then
        buff:Hide();
    end;
end;
--- MOD-UI-015 :
-- Move boss frames on left side closer to center
MoveElement(Boss1TargetFrame, nil, "CENTER", UIParent, "CENTER", -200, -100, 1.1);
Boss1TargetFrame.SetPoint = function()
end;
for i = 2, 5 do
    MoveElement(_G["Boss" .. i .. "TargetFrame"], nil, "RIGHT", _G["Boss" .. (i - 1) .. "TargetFrame"], "BOTTOM", _G["Boss" .. i .. "TargetFrame"]:GetHeight(), _G["Boss" .. i .. "TargetFrame"]:GetHeight() + 50, 1.1);
end;
--- MOD-UI-016 :
-- Move arena enemies frames on left side closer to center
-- use this script to show frames outside of arena
--[[/run LoadAddOn("Blizzard_ArenaUI") ArenaEnemyFrames:Show() ArenaEnemyFrame1:Show() ArenaEnemyFrame2:Show() ArenaEnemyFrame3:Show() ArenaEnemyFrame1CastingBar:Show() ArenaEnemyFrame2CastingBar:Show() ArenaEnemyFrame3CastingBar:Show()]]
if LoadAddOn("Blizzard_ArenaUI") then
    ArenaEnemyFrame1:ClearAllPoints();
    ArenaEnemyFrame2:ClearAllPoints();
    ArenaEnemyFrame3:ClearAllPoints();
    ArenaEnemyFrames:SetScale(2);
    ArenaEnemyFrame1:SetPoint("CENTER", UIParent, "CENTER", -175, 50);
    ArenaEnemyFrame2:SetPoint("CENTER", UIParent, "CENTER", -150, 0);
    ArenaEnemyFrame3:SetPoint("CENTER", UIParent, "CENTER", -125, -50);
    ArenaEnemyFrame1.SetPoint = function()
    end;
    ArenaEnemyFrame2.SetPoint = function()
    end;
    ArenaEnemyFrame3.SetPoint = function()
    end;
end;
--- MOD-UI-017 :
-- Hide boss banner
BossBanner:UnregisterAllEvents();
--- MOD-UI-018 :
-- Hide talking head
if LoadAddOn("Blizzard_TalkingHeadUI") then
    TalkingHeadFrame:SetScript("OnShow", nil);
    TalkingHeadFrame:SetScript("OnHide", nil);
    TalkingHeadFrame:UnregisterAllEvents();
end;
--- MOD-UI-019 :
-- Colorize action bar, units, mini-map with faction color (horde, alliance and neutral)
-- Replace end caps with customized ones (horde, alliance and neutral)
function STAYFOCUSEDEVENTS:ADDON_LOADED(...)
    local red, geen, blue;
    local faction, _ = UnitFactionGroup("player");
    if faction == "Horde" then
        MainMenuBarArtFrame.LeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap horde.png");
        MainMenuBarArtFrame.RightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap horde.png");
        red = 0.55;
        blue = 0;
    elseif faction == "Alliance" then
        MainMenuBarArtFrame.LeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap alliance.png");

        MainMenuBarArtFrame.RightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap alliance.png");

        red = 0.3;
        green = 0.4;
        blue = 1;
    else
        MainMenuBarArtFrame.LeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap neutral.png");
        MainMenuBarArtFrame.RightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap neutral.png");
        red = 0.98;
        green = 0.84;
        blue = 0.11;
    end
        MainMenuBarArtFrame.LeftEndCap:SetHeight(MainMenuBarArtFrame.LeftEndCap:GetHeight() + 5)
        MainMenuBarArtFrame.LeftEndCap:SetScale(1)
        MainMenuBarArtFrame.LeftEndCap:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
        MainMenuBarArtFrame.RightEndCap:SetHeight(MainMenuBarArtFrame.RightEndCap:GetHeight() + 5)
        MainMenuBarArtFrame.RightEndCap:SetScale(1)
        MainMenuBarArtFrame.RightEndCap:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
		
    for i, v in pairs({MainMenuBarArtFrameBackground.BackgroundLarge, MainMenuBarArtFrameBackground.BackgroundSmall, MicroButtonAndBagsBar.MicroBagBar,
       -- ArtifactWatchBar.StatusBar.WatchBarTexture0, ArtifactWatchBar.StatusBar.WatchBarTexture1, ArtifactWatchBar.StatusBar.WatchBarTexture2, ArtifactWatchBar.StatusBar.WatchBarTexture3, ArtifactWatchBar.StatusBar.XPBarTexture0, ArtifactWatchBar.StatusBar.XPBarTexture1,
       -- ArtifactWatchBar.StatusBar.XPBarTexture2, ArtifactWatchBar.StatusBar.XPBarTexture3,
		BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2, BonusActionBarFrameTexture3, BonusActionBarFrameTexture4, CastingBarFrameBorder, FocusFrameSpellBarBorder,
        FocusFrameTextureFrameTexture, FocusFrameToTTextureFrameTexture,
	   -- HonorWatchBar.StatusBar.WatchBarTexture0, HonorWatchBar.StatusBar.WatchBarTexture1, HonorWatchBar.StatusBar.WatchBarTexture2, HonorWatchBar.StatusBar.WatchBarTexture3, HonorWatchBar.StatusBar.XPBarTexture0,
       -- HonorWatchBar.StatusBar.XPBarTexture1, HonorWatchBar.StatusBar.XPBarTexture2, HonorWatchBar.StatusBar.XPBarTexture3, 
		MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3, 
	   -- MainMenuExpBar.WatchBarTexture0, MainMenuExpBar.WatchBarTexture1, MainMenuExpBar.WatchBarTexture2, MainMenuExpBar.WatchBarTexture3, MainMenuExpBar.XPBarTexture0, MainMenuExpBar.XPBarTexture1, MainMenuExpBar.XPBarTexture2, MainMenuExpBar.XPBarTexture3, 
	   MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        MainMenuXPBarDiv1, MainMenuXPBarDiv2, MainMenuXPBarDiv3, MainMenuXPBarDiv4, MainMenuXPBarDiv5, MainMenuXPBarDiv6, MainMenuXPBarDiv7, MainMenuXPBarDiv8, MainMenuXPBarDiv9, MainMenuXPBarDiv10, MainMenuXPBarDiv11, MainMenuXPBarDiv12, MainMenuXPBarDiv13, MainMenuXPBarDiv14,
        MainMenuXPBarDiv15, MainMenuXPBarDiv16, MainMenuXPBarDiv17, MainMenuXPBarDiv18, MainMenuXPBarDiv19, MainMenuXPBarTextureLeftCap, MainMenuXPBarTextureMid, MainMenuXPBarTextureRightCap, MiniMapBattlefieldBorder, MiniMapLFGFrameBorder, MiniMapMailBorder, MiniMapTrackingButtonBorder,
        MinimapBorder, MinimapBorderTop, PartyMemberFrame1PetFrameTexture, PartyMemberFrame1Texture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame2Texture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame3Texture, PartyMemberFrame4PetFrameTexture, PartyMemberFrame4Texture,
        PetFrameTexture, PlayerFrameTexture, 
	  -- ReputationWatchBar.StatusBar.WatchBarTexture0, ReputationWatchBar.StatusBar.WatchBarTexture1, ReputationWatchBar.StatusBar.WatchBarTexture2, ReputationWatchBar.StatusBar.WatchBarTexture3, ReputationWatchBar.StatusBar.XPBarTexture0,
      -- ReputationWatchBar.StatusBar.XPBarTexture1, ReputationWatchBar.StatusBar.XPBarTexture2, ReputationWatchBar.StatusBar.XPBarTexture3, 
		TargetFrameSpellBarBorder, TargetFrameTextureFrameTexture, TargetFrameToTTextureFrameTexture,
    }) do
        v:SetDesaturated(true);
        v:SetVertexColor(red, green, blue);
    end;
end;
--- FUNC-004 :
-- Accept quests
-- Complete quests
-- Skip quests details
-- When multiple quest available, stand by for player choice
-- Stop automation with shift key pressed
function STAYFOCUSEDEVENTS:QUEST_ACCEPT_CONFIRM(...)
    if IsShiftKeyDown() then
        return
    else
        ConfirmAcceptQuest();
        StaticPopup_Hide("QUEST_ACCEPT");
    end;
end;
function STAYFOCUSEDEVENTS:QUEST_AUTOCOMPLETE(...)
    if IsShiftKeyDown() then
        return
    else
        if GetNumAutoQuestPopUps() > 0 then
            questId, questType = GetAutoQuestPopUp(1);
            if questType == "COMPLETE" then
                index = GetQuestLogIndexByID(questId);
                ShowQuestComplete(index);
            end;
        end;
    end;
end;
function STAYFOCUSEDEVENTS:QUEST_COMPLETE(...)
    if IsShiftKeyDown() then
        return
    else
        if GetNumQuestChoices() <= 1 then
            GetQuestReward(GetNumQuestChoices());
        end;
    end;
end;
function STAYFOCUSEDEVENTS:QUEST_DETAIL(...)
    if IsShiftKeyDown() then
        return
    else
        if QuestGetAutoAccept() then
            C_Timer.After(math.max(1, 0.01), CloseQuest);
        else
            C_Timer.After(math.max(1, 0.01), AcceptQuest);
        end;
    end;
end;
function STAYFOCUSEDEVENTS:QUEST_GREETING(...)
    if IsShiftKeyDown() then
        return
    else
        if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() then
            numAvailable = GetNumAvailableQuests() or 0;
            numActive = GetNumActiveQuests() or 0;
            if numAvailable >= 1 then
                for i = 1, numAvailable do
                    SelectAvailableQuest(i);
                end;
            end;
            if numActive >= 1 then
                for i = 1, numActive do
                    _, isComplete = GetActiveTitle(i);
                    if isComplete then
                        SelectActiveQuest(i);
                    end;
                end;
            end;
        end;
    end;
end;
function STAYFOCUSEDEVENTS:QUEST_PROGRESS(...)
    if IsShiftKeyDown() then
        return
    else
        if IsQuestCompletable() then
            CompleteQuest();
        end;
    end;
end;
--- FUNC-005 :
-- Send chat messages in raid warning with specific sound (guild, guild officer, instance, instance leader, party, party leader, raid, raid leader, whisper and battle net)
-- Associated with TECH-006
function STAYFOCUSEDEVENTS:CHAT_MSG_GUILD(...)
    SendAs(select(1, ...), select(5, ...), "GUILD", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_g.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_OFFICER(...)
    SendAs(select(1, ...), select(5, ...), "GUILD", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_g.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_INSTANCE_CHAT(...)
    SendAs(select(1, ...), select(5, ...), "PARTY", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_INSTANCE_CHAT_LEADER(...)
    SendAs(select(1, ...), select(5, ...), "PARTY", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_PARTY(...)
    SendAs(select(1, ...), select(5, ...), "PARTY", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_PARTY_LEADER(...)
    SendAs(select(1, ...), select(5, ...), "PARTY", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_RAID(...)
    SendAs(select(1, ...), select(5, ...), "RAID", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_RAID_LEADER(...)
    SendAs(select(1, ...), select(5, ...), "RAID", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_i.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_BN_INLINE_TOAST_BROADCAST(...)
    SendAs(select(1, ...), select(5, ...), "BN_WHISPER", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_w.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_BN_WHISPER(...)
    SendAs(select(1, ...), select(5, ...), "BN_WHISPER", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_w.ogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_WHISPER(...)
    SendAs(select(1, ...), select(5, ...), "WHISPER", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_w.ogg");
end;
--- MOD-UI-020 :
-- Show paper doll item level
function ShowPaperDollItemLevel(self, unit)
    result = "";
    id = self:GetID();
    if id == 4 or id > 17 then
        return
    end;
    if not self.levelString then
        self.levelString = self:CreateFontString(nil, "OVERLAY");
        self.levelString:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE");
        self.levelString:SetPoint("TOP");
        self.levelString:SetTextColor(1, 0.82, 0);
    end;
    if unit and self.hasItem then
        _, level, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, id);
        if level > 0 and quality > 2 then
            self.levelString:SetText(level);
            result = true;
        end;
    else
        self.levelString:SetText("");
        result = true;
    end;
    if id == 16 or id == 17 then
        _, offhand, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, 17);
        if quality == 6 then
            _, mainhand = LibItemLevel:GetUnitItemInfo(unit, 16);
            self.levelString:SetText(math.max(mainhand, offhand));
        end;
    end;
    return result;
end;
hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
    ShowPaperDollItemLevel(self, "player");
end);
--- MOD-UI-021 :
-- Show weapons and armors item level in bags
-- Colorize item level when greater than 90% of equipped item level
function SetContainerItemLevel(button, ItemLink)
    if not button then
        return
    end;
    if not button.levelString then
        button.levelString = button:CreateFontString(nil, "OVERLAY");
        button.levelString:SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE");
        button.levelString:SetPoint("TOP");
    end;
    if button.origItemLink ~= ItemLink then
        button.origItemLink = ItemLink;
    else return
    end;
    if ItemLink then
        count, level, _, _, quality, _, _, class, subclass, _, _ = LibItemLevel:GetItemInfo(ItemLink);
        name, _ = GetItemSpell(ItemLink);
        _, equipped, _ = GetAverageItemLevel();
        if level >= (98 * equipped / 100) then
            button.levelString:SetTextColor(0, 1, 0);
        else
            button.levelString:SetTextColor(1, 1, 1);
        end;
        if count == 0 and level > 0 and quality > 1 then
            button.levelString:SetText(level);
        else
            button.levelString:SetText("");
        end;
    else
        button.levelString:SetText("");
    end;
end;
hooksecurefunc("ContainerFrame_Update", function(self)
    local name = self:GetName();
    for i = 1, self.size do
        local button = _G[name .. "Item" .. i];
        SetContainerItemLevel(button, GetContainerItemLink(self:GetID(), button:GetID()));
    end;
end);
--- MOD-UI-022 :
-- Collapse objectives in pvp
function STAYFOCUSEDEVENTS:PLAYER_ENTERING_WORLD(...)
    if (instanceType == "pvp" or instanceType == "arena") and not ObjectiveTrackerFrame.collapsed then
        ObjectiveTracker_Collapse();
    end;
end;
--- FUNC-006 :
-- Confirm disenchant roll
function STAYFOCUSEDEVENTS:CONFIRM_DISENCHANT_ROLL(...)
    ConfirmLootRoll(select(1, ...), select(2, ...));
    StaticPopup_Hide("CONFIRM_LOOT_ROLL");
end;
--- FUNC-007 :
-- Confirm loot roll
function STAYFOCUSEDEVENTS:CONFIRM_LOOT_ROLL(...)
    ConfirmLootRoll(select(1, ...), select(2, ...));
    StaticPopup_Hide("CONFIRM_LOOT_ROLL");
end;
--- FUNC-008 :
-- Confirm bind on pickup loot
function STAYFOCUSEDEVENTS:LOOT_BIND_CONFIRM(...)
    ConfirmLootSlot(select(1, ...), select(2, ...));
    StaticPopup_Hide("LOOT_BIND");
end;
--- FUNC-009 :
-- Speed up looting
function STAYFOCUSEDEVENTS:LOOT_READY(...)
    delay = 0;
    if GetTime() - delay >= 0.3 then
        delay = GetTime();
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i);
            end;
            delay = GetTime();
        end;
    end;
end;
--- FUNC-010 :
-- Open mails except GM's mails and ones with cash on delivery
function STAYFOCUSEDEVENTS:MAIL_INBOX_UPDATE(...)
    numItems, totalItems = GetInboxNumItems();
    if totalItems == 0 then
        return
    elseif numItems > 0 then
        _, _, _, _, _, payToLoot, _, _, _, _, _, _, isGM, _ = GetInboxHeaderInfo(numItems);
        if not (payToLoot > 0 or isGM) then
            AutoLootMailItem(numItems);
        end;
    end;
end;
--- FUNC-011 :
-- Repair equipment and sell junk when visiting a merchant
-- Stop selling when merchant window is closed
function STAYFOCUSEDEVENTS:MERCHANT_SHOW(...)
    repairAllCost, canRepair = GetRepairAllCost();
    if CanMerchantRepair() and canRepair and repairAllCost > 0 then
        RepairAllItems();
    end;
    token = C_Timer.NewTicker(math.max(1, 0.01), function()
        for BagID = 0, 4 do
            for BagSlot = 1, GetContainerNumSlots(BagID) do
                itemToSold = GetContainerItemLink(BagID, BagSlot);
                if itemToSold then
                    _, _, qualite, _, _, _, _, _, _, _, prix = GetItemInfo(itemToSold);
                    if MerchantFrame:IsShown() and qualite == 0 and prix ~= 0 then
                        UseContainerItem(BagID, BagSlot);
                    end;
                end;
            end;
        end;
    end, 200)
end;
function STAYFOCUSEDEVENTS:MERCHANT_CLOSED(...)
    if token then
        token:Cancel();
    end;
end;
--- FUNC-012 :
-- Learn available recipes when visiting a trainer
-- Stop learning when trainer window is closed
function STAYFOCUSEDEVENTS:TRAINER_SHOW(...)
    token = C_Timer.NewTicker(math.max(1, 0.01), function()
        if IsTradeskillTrainer() then
            SetTrainerServiceTypeFilter("available", 1, 1);
            for i = 1, GetNumTrainerServices() do
                BuyTrainerService(i);
            end;
        end;
    end, 200)
end;
function STAYFOCUSEDEVENTS:TRAINER_CLOSED(...)
    if token then
        token:Cancel();
    end;
end;
--- FUNC-013 :
-- Release corpse in pvp
function STAYFOCUSEDEVENTS:PLAYER_DEAD(...)
    InstStat, InstType = IsInInstance();
    if InstStat and InstType == "pvp" and not HasSoulstone() then
        RepopMe();
    end;
end;
--- FUNC-014 :
-- Announce mini-map : rares, treasures except garrison cache (raid warning and sound)
function STAYFOCUSEDEVENTS:VIGNETTE_MINIMAP_UPDATED(...)
	local pinsToRemove = {};
    if GetLocale() == "frFR" then
        isGarrisonCache = "Cache du fief";
        isDetected = "détecté";
    else
        isGarrisonCache = "Garrison cache";
        isDetected = "detected";
    end;
    vignetteGUID = select(1, ...);
	added =  select(2, ...);
    if vignetteGUID and added then
 		local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID);
        name, _ = vignetteInfo.name;
        if name ~= nil and name ~= isGarrisonCache then
            message = "|cff00ff00" .. name .. " " .. isDetected .. "!|r";
            RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"]);
            PlaySoundFile("Interface\\AddOns\\StayFocusedUI\\Sounds\\rare_and_treasure.ogg", "Master");
        end;  
     end;
end;
--- FUNC-015 :
-- Confirm summon
function STAYFOCUSEDEVENTS:CONFIRM_SUMMON(...)
    if not UnitAffectingCombat("player") then
        ConfirmSummon();
        StaticPopup_Hide("CONFIRM_SUMMON");
    end;
end;
--- FUNC-016 :
-- Announce spell interruption when player in party or raid
function STAYFOCUSEDEVENTS:COMBAT_LOG_EVENT_UNFILTERED(...)
	local _, action, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	-- debug
	-- if sourceGUID == UnitGUID("player") then
    -- print("action="..tostring(action).."+sourceGUID="..tostring(sourceGUID).."+spellID="..tostring(spellID))
	-- end
	if GetLocale() == "frFR" then
        isKicked = "interrompu";
    else
        isKicked = "interrupted";
    end;
    if action == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            SendChatMessage(GetSpellLink(spellID) .. " " .. tostring(isKicked), "INSTANCE_CHAT");
		elseif IsInRaid() then
            SendChatMessage(GetSpellLink(spellID) .. " " .. tostring(isKicked), "RAID");
        elseif IsInGroup() then
			SendChatMessage(GetSpellLink(spellID) .. " " .. tostring(isKicked), "PARTY");
		else 
			SendChatMessage(GetSpellLink(spellID) .. " " .. tostring(isKicked), "SAY");
        end;
    end;
end;
--- FUNC-017 :
-- Enable double click fishing with or without fishing pole equipped
local ArcheologyKnown = GetSpellInfo(80451);
local FishingKnown = GetSpellInfo(131474);
local stopCastingTimer, stopCasting, isCasting;
local isFishing, isSurveying;
local authorizedClickZones = {
    [WorldFrame] = true,
    [UIParent] = true,
};
local STAYFOCUSED_FISHING = CreateFrame("Button", "STAYFOCUSED_FISHING", UIParent, "SecureActionButtonTemplate");
STAYFOCUSED_FISHING:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, ...);
end);
STAYFOCUSED_FISHING:RegisterEvent("PLAYER_LOGIN");
STAYFOCUSED_FISHING:EnableMouse(true);
STAYFOCUSED_FISHING:RegisterForClicks("RightButtonUp");
STAYFOCUSED_FISHING:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0);
STAYFOCUSED_FISHING:Hide();
STAYFOCUSED_FISHING:SetAttribute("action", nil);
STAYFOCUSED_FISHING:SetAttribute("type", "spell");
STAYFOCUSED_FISHING:SetAttribute("spell", FishingKnown);
STAYFOCUSED_FISHING:SetScript("PostClick", function(self, button, down)
    if InCombatLockdown() then
    stopCasting = true;
    elseif isCasting then
    ClearOverrideBindings(self);
    isCasting = nil;
    end ;
end);
function STAYFOCUSED_FISHING:SetupClickHook()
    local lastClickTime = 0;
    WorldFrame:HookScript("OnMouseDown", function(self, button, down)
        if not isFishing or button ~= "RightButton" or InCombatLockdown() or CanScanResearchSite() then
            return
        end;
        local clickTime = GetTime();
        local clickDiff = clickTime - lastClickTime;
        lastClickTime = clickTime;
        if clickDiff > 0.05 and clickDiff < 0.25 then
            if IsMouselooking() then
                MouselookStop();
            end;
            SetOverrideBindingClick(STAYFOCUSED_FISHING, true, "BUTTON2", "STAYFOCUSED_FISHING");
            isCasting = true;
        end;
    end);
    self.SetupClickHook = nil;
end;
function STAYFOCUSED_FISHING:EnableDoubleClickFishing()
    if isFishing then
        return
    end;
    if not GetSpellInfo(FishingKnown) then
        return
    end;
    if self.SetupClickHook then
        self:SetupClickHook();
        self:RegisterEvent("PLAYER_LOGOUT");
    end;
    isFishing = true;
end;
function STAYFOCUSED_FISHING:DisableDoubleClickFishing()
    if not isFishing then
        return
    end;
    isFishing = nil;
    stopCastingTimer = nil;
end;
function STAYFOCUSED_FISHING:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_LOGOUT");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
end;
function STAYFOCUSED_FISHING:PLAYER_LOGOUT()
    self:DisableDoubleClickFishing();
end
function STAYFOCUSED_FISHING:PLAYER_REGEN_DISABLED()
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    if UnitChannelInfo("unit") == FishingKnown then
        self:UNIT_SPELLCAST_CHANNEL_STOP("player", FishingKnown);
    end;
    if isFishing then
        self:DisableDoubleClickFishing();
    end;
end;
function STAYFOCUSED_FISHING:PLAYER_REGEN_ENABLED()
    if stopCasting then
        ClearOverrideBindings(self);
        stopCasting = nil;
        isCasting = nil;
    end;
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
    self:EnableDoubleClickFishing();
end;
function STAYFOCUSED_FISHING:UNIT_SPELLCAST_CHANNEL_START(unit, spell)
    if spell == FishingKnown then
        if stopCastingTimer then
            stopCastingTimer = GetTime() + 1000000;
        end;
    end;
end;
function STAYFOCUSED_FISHING:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell)
    if spell == FishingKnown then
        if stopCastingTimer then
            stopCastingTimer = GetTime() + 10000;
        end;
    end;
end;
local STAYFOCUSED_FISHINGTIMERFRAME = CreateFrame("Frame");
local STAYFOCUSED_FISHINGTIMER = STAYFOCUSED_FISHINGTIMERFRAME:CreateAnimationGroup();
local timer = STAYFOCUSED_FISHINGTIMER:CreateAnimation();
timer:SetDuration(1);
STAYFOCUSED_FISHINGTIMER:SetScript("OnFinished", function(self, requested)
    if not isFishing or not stopCastingTimer then
        return
    end;
    if GetTime() > stopCastingTimer then
        STAYFOCUSED_FISHING:DisableDoubleClickFishing();
        stopCastingTimer = nil;
    else
        self:Play();
    end;
end);
GameTooltip:HookScript("OnShow", function(self)
    if isFishing or not authorizedClickZones[self:GetOwner()] then
        return
    end;
    STAYFOCUSED_FISHING:EnableDoubleClickFishing();
    if not isFishing then
        STAYFOCUSED_FISHING:EnableDoubleClickFishing();
    end;
    stopCastingTimer = GetTime() + 10000;
    STAYFOCUSED_FISHINGTIMER:Play();
end);
--- FUNC-018 :
-- Enable double click survey
local STAYFOCUSED_SURVEYING = CreateFrame("Button", "STAYFOCUSED_SURVEYING", UIParent, "SecureActionButtonTemplate");
STAYFOCUSED_SURVEYING:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, ...);
end)
STAYFOCUSED_SURVEYING:RegisterEvent("PLAYER_LOGIN");
STAYFOCUSED_SURVEYING:EnableMouse(true);
STAYFOCUSED_SURVEYING:RegisterForClicks("RightButtonUp");
STAYFOCUSED_SURVEYING:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0);
STAYFOCUSED_SURVEYING:Hide();
STAYFOCUSED_SURVEYING:SetAttribute("action", nil);
STAYFOCUSED_SURVEYING:SetAttribute("type", "spell");
STAYFOCUSED_SURVEYING:SetAttribute("spell", ArcheologyKnown);
STAYFOCUSED_SURVEYING:SetScript("PostClick", function(self, button, down)
    if InCombatLockdown() then
        stopCasting = true;
    elseif isCasting then
        ClearOverrideBindings(self);
        isCasting = nil;
    end;
end);
function STAYFOCUSED_SURVEYING:SetupClickHook()
    local lastClickTime = 0;
    WorldFrame:HookScript("OnMouseDown", function(self, button, down)
        if not isSurveying or button ~= "RightButton" or InCombatLockdown() or not CanScanResearchSite() or not GetSpellCooldown(80451) == 0 then
            return
        end;
        local clickTime = GetTime();
        local clickDiff = clickTime - lastClickTime;
        lastClickTime = clickTime;
        if clickDiff > 0.05 and clickDiff < 0.25 then
            if IsMouselooking() then
                MouselookStop();
            end;
            SetOverrideBindingClick(STAYFOCUSED_SURVEYING, true, "BUTTON2", "STAYFOCUSED_SURVEYING");
            isCasting = true;
        end;
    end);
    self.SetupClickHook = nil;
end;
function STAYFOCUSED_SURVEYING:EnableDoubleClickSurvey()
    if isSurveying then
        return
    end;
    if not GetSpellInfo(ArcheologyKnown) then
        return
    end;
    if self.SetupClickHook then
        self:SetupClickHook();
        self:RegisterEvent("PLAYER_LOGOUT");
    end;
    isSurveying = true;
end;
function STAYFOCUSED_SURVEYING:DisableDoubleClickSurvey()
    if not isSurveying then
        return
    end;
    isSurveying = nil;
    stopCastingTimer = nil;
end;
function STAYFOCUSED_SURVEYING:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_LOGOUT");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
end;
function STAYFOCUSED_SURVEYING:PLAYER_LOGOUT()
    self:DisableDoubleClickSurvey();
end;
function STAYFOCUSED_SURVEYING:PLAYER_REGEN_DISABLED()
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    if UnitChannelInfo("unit") == ArcheologyKnown then
        self:UNIT_SPELLCAST_CHANNEL_STOP("player", ArcheologyKnown);
    end;
    if isSurveying then
        self:DisableDoubleClickSurvey();
    end;
end;
function STAYFOCUSED_SURVEYING:PLAYER_REGEN_ENABLED()
    if stopCasting then
        ClearOverrideBindings(self);
        stopCasting = nil;
        isCasting = nil;
    end;
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
    self:EnableDoubleClickSurvey();
end;
function STAYFOCUSED_SURVEYING:UNIT_SPELLCAST_CHANNEL_START(unit, spell)
    if spell == ArcheologyKnown then
        if stopCastingTimer then
            stopCastingTimer = GetTime() + 1000000;
        end;
    end;
end;
function STAYFOCUSED_SURVEYING:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell)
    if spell == ArcheologyKnown then
        if stopCastingTimer then
            stopCastingTimer = GetTime() + 10000;
        end;
    end;
end;
local STAYFOCUSED_SURVEYINGTIMERFRAME = CreateFrame("Frame");
local STAYFOCUSED_SURVEYINGTIMER = STAYFOCUSED_SURVEYINGTIMERFRAME:CreateAnimationGroup();
local timer = STAYFOCUSED_SURVEYINGTIMER:CreateAnimation();
timer:SetDuration(1);
STAYFOCUSED_FISHINGTIMER:SetScript("OnFinished", function(self, requested)
    if not isFishing or not stopCastingTimer then
        return
    end;
    if GetTime() > stopCastingTimer then
        STAYFOCUSED_FISHING:DisableDoubleClickFishing();
        stopCastingTimer = nil;
    else
        self:Play();
    end;
end);
GameTooltip:HookScript("OnShow", function(self)
    if isSurveying or not authorizedClickZones[self:GetOwner()] then
        return
    end;
    STAYFOCUSED_SURVEYING:EnableDoubleClickSurvey();
    if not isSurveying then
        STAYFOCUSED_SURVEYING:EnableDoubleClickSurvey();
    end;
    stopCastingTimer = GetTime() + 10000;
    STAYFOCUSED_SURVEYINGTIMER:Play();
end);
--- FUNC-019 :
-- Colorize PvE nameplates by threat for all roles (green : threat status corresponding to your role, red not corresponding, orange for status warning, blue for off-tank) and resize nameplates while tanking
local offTanks = {};
local function resetFrame(frame)
    if frame.threat then
        frame.threat = nil;
        frame.healthBar:SetStatusBarColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b);
    end;
end;
local function updateHealthColor(frame, ...)
    if frame.threat then
        local forceUpdate = ...;
        local previousColor = frame.threat.previousColor;
        if forceUpdate or previousColor.r ~= frame.healthBar.r or previousColor.g ~= frame.healthBar.g or previousColor.b ~= frame.healthBar.b then
            frame.healthBar:SetStatusBarColor(frame.threat.color.r, frame.threat.color.g, frame.threat.color.b);
            frame.threat.previousColor.r = frame.healthBar.r;
            frame.threat.previousColor.g = frame.healthBar.g;
            frame.threat.previousColor.b = frame.healthBar.b;
        end;
    end;
end;
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", updateHealthColor);
local function collectOffTanks()
    local collectedTanks = {};
    local unitPrefix, unit, i, unitRole;
    local isInRaid = IsInRaid();
    if isInRaid then
        unitPrefix = "raid";
    else
        unitPrefix = "party";
    end;
    for i = 1, GetNumGroupMembers() do
        unit = unitPrefix .. i;
        if not UnitIsUnit(unit, "player") then
            unitRole = UnitGroupRolesAssigned(unit);
            if unitRole == "TANK" then
                table.insert(collectedTanks, unit);
            elseif isInRaid and unitRole == "NONE" then
                local _, _, _, _, _, _, _, _, _, raidRole = GetRaidRosterInfo(i);
                if raidRole == "MAINTANK" then
                    table.insert(collectedTanks, unit);
                end;
            end;
        end;
    end;
    return collectedTanks;
end;
local function isOfftankTanking(mobUnit)
    local unit, situation;
    for _, unit in ipairs(offTanks) do
        situation = UnitThreatSituation(unit, mobUnit) or -1;
        if situation > 1 then
            return true;
        end;
    end;
    return false;
end
local function updateThreatColor(frame)
    playerRole = GetSpecializationRole(GetSpecialization());
    if playerRole == "TANK" then
        frame.healthBar:SetHeight(12);
    end;
    local unit = frame.unit;
    local reaction = UnitReaction("player", unit);
    if reaction and reaction < 5 and (reaction < 4 or CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit)) and not UnitIsPlayer(unit) and not CompactUnitFrame_IsTapDenied(frame) then
        local threat = UnitThreatSituation("player", unit) or -1;
        if playerRole == "TANK" and threat < 1 and isOfftankTanking(unit) then
            threat = 4;
        end;
        if not frame.threat or frame.threat.lastSituation ~= threat then
            local r, g, b;
            if threat == 0 then
                --  Player has less than 100% raw threat (default UI shows no indicator)
                if playerRole == "TANK" then
                    r, g, b = 1, 0, 0; else r, g, b = 0, 1, 0;
                end;
            elseif threat == 1 then
                -- Player has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
                r, g, b = .6, .4, 0;
            elseif threat == 2 then
                -- Player is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
                if playerRole == "TANK" then
                    r, g, b = 1, 0, 0; else r, g, b = 0, 1, 0;
                end;
            elseif threat == 3 then
                -- Player is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)
                if playerRole == "TANK" then
                    r, g, b = 0, 1, 0; else r, g, b = 1, 0, 0;
                end;
            elseif threat == 4 then
                -- off-tank is tanking
                if playerRole == "TANK" then
                    r, g, b = 0, 0, 1; else r, g, b = 0, 1, 0;
                end;
            end
            if not frame.threat then
                frame.threat = {
                    ["color"] = {},
                    ["previousColor"] = {},
                };
            end;
            frame.threat.lastSituation = threat;
            frame.threat.color.r = r;
            frame.threat.color.g = g;
            frame.threat.color.b = b;
            updateHealthColor(frame, true);
        end;
    else
        resetFrame(frame);
    end;
end;
local STAYFOCUSED_THREATPLATES = CreateFrame("frame")
STAYFOCUSED_THREATPLATES:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
STAYFOCUSED_THREATPLATES:RegisterEvent("NAME_PLATE_UNIT_ADDED");
STAYFOCUSED_THREATPLATES:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
STAYFOCUSED_THREATPLATES:RegisterEvent("PLAYER_ROLES_ASSIGNED");
STAYFOCUSED_THREATPLATES:RegisterEvent("RAID_ROSTER_UPDATE");
STAYFOCUSED_THREATPLATES:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
STAYFOCUSED_THREATPLATES:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_THREAT_SITUATION_UPDATE" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
            updateThreatColor(nameplate.UnitFrame);
        end;
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unitId = arg1;
        local callback = function()
            local plate = C_NamePlate.GetNamePlateForUnit(unitId);
            if plate then
                updateThreatColor(plate.UnitFrame);
            end;
        end;
        callback();
        C_Timer.NewTimer(0.3, callback);
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local nameplate = C_NamePlate.GetNamePlateForUnit(arg1);
        resetFrame(nameplate.UnitFrame);
    elseif event == "PLAYER_ROLES_ASSIGNED" or event == "RAID_ROSTER_UPDATE" then
        offTanks = collectOffTanks();
    end;
end);
--- Handler
STAYFOCUSED:SetScript("OnEvent", function(self, event, ...)
    STAYFOCUSEDEVENTS[event](self, ...);
	-- debug
	-- arg1, arg2, arg3, arg4, arg5,arg6, arg7, arg8, arg9 = select(1, ...), select(2, ...), select(3, ...), select(4, ...), select(5, ...), select(6, ...), select(7, ...), select(8, ...), select(9, ...)
	-- print(tostring(event).."-arg1-"..tostring(arg1).."-arg2-"..tostring(arg2).."-arg3-"..tostring(arg3).."-arg4-"..tostring(arg4).."-arg5-"..tostring(arg5).."-arg6-"..tostring(arg6).."-arg7-"..tostring(arg7).."-arg8-"..tostring(arg8).."-arg9-"..tostring(arg9))
end);
for k, _ in pairs(STAYFOCUSEDEVENTS) do
    STAYFOCUSED:RegisterEvent(k);
end;