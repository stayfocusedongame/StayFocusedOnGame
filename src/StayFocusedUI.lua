---
--- Created by stayfocusedongame.
--- DateTime: 2017/11/11 23:00
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
        end;
        if IsAddOnLoaded("BigWigs_Plugins") then
            SlashCmdList["BIGWIGSPULL"]("/pull 0");
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
SetCVar("autoInteract", 1);
SetCVar("autoLootDefault", 1);
SetCVar("autoLootRate", 0.1);
SetCVar("cameraDistanceMaxZoomFactor", 2.6);
SetCVar("cameraSavedDistance", 25);
SetCVar("cameraSavedPitch", 33);
SetCVar("chatBubbles", 1);
SetCVar("chatBubblesParty", 0);
SetCVar("chatStyle", "im");
SetCVar("colorChatNamesByClass", 1);
SetCVar("countdownForCooldowns", 1);
SetCVar("deselectOnClick", 1);
SetCVar("displayFreeBagSlots", 1);
SetCVar("enableFloatingCombatText", 1);
SetCVar("findYourselfAnywhere", 0);
SetCVar("findYourselfMode", 1);
SetCVar("floatingCombatTextAuras", 0);
SetCVar("floatingCombatTextCombatDamage", 0);
SetCVar("floatingCombatTextCombatDamageDirectionalScale", 0);
SetCVar("floatingCombatTextCombatHealing", 0);
SetCVar("floatingCombatTextCombatHealingAbsorbSelf", 0);
SetCVar("floatingCombatTextCombatHealingAbsorbTarget", 0);
SetCVar("floatingCombatTextCombatLogPeriodicSpells", 0);
SetCVar("floatingCombatTextCombatState", 0);
SetCVar("floatingCombatTextDamageReduction", 0);
SetCVar("floatingCombatTextDodgeParryMiss", 0);
SetCVar("floatingCombatTextEnergyGains", 0);
SetCVar("floatingCombatTextFloatMode", "2");
SetCVar("floatingCombatTextFriendlyHealers", 1);
SetCVar("floatingCombatTextHonorGains", 0);
SetCVar("floatingCombatTextPeriodicEnergyGains", 0);
SetCVar("floatingCombatTextPetMeleeDamage", 0);
SetCVar("floatingCombatTextReactives", 0);
SetCVar("floatingCombatTextRepChanges", 1);
SetCVar("floatingCombatTextSpellMechanics", 0);
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
SetCVar("raidFramesDisplayAggroHighlight", 1);
SetCVar("raidFramesDisplayClassColor", 1);
SetCVar("raidFramesDisplayClassColor", 1);
SetCVar("raidFramesDisplayOnlyDispellableDebuffs", 0);
SetCVar("raidFramesDisplayPowerBars", 1);
SetCVar("raidFramesDisplayPowerBars", 1);
SetCVar("raidFramesHealthText", "percent");
SetCVar("raidFramesHealthText", "percent");
SetCVar("raidFramesHeight", 72);
SetCVar("raidFramesHeight", 72); -- 36 to 72
SetCVar("raidFramesWidth", 72); -- 72 to 144
SetCVar("raidOptionDisplayMainTankAndAssist", 1);
SetCVar("raidOptionDisplayPets", 0);
SetCVar("raidOptionIsShown", 1);
SetCVar("raidOptionKeepGroupsTogether", 1);
SetCVar("raidOptionKeepGroupsTogether", 1);
SetCVar("raidOptionLocked", 1);
SetCVar("raidOptionLocked", 1);
SetCVar("raidOptionShowBorders", 0);
SetCVar("raidOptionShowBorders", 0);
SetCVar("raidOptionSortMode", "groups");
SetCVar("raidOptionSortMode", "groups");
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
        c = RAID_CLASS_COLORS[select(2, UnitClass("player"))];
        bg = PlayerFrame:CreateTexture();
        bg:SetPoint("TOPLEFT", PlayerFrameBackground);
        bg:SetPoint("BOTTOMRIGHT", PlayerFrameBackground, 0, 22);
        bg:SetTexture(TargetFrameNameBackground:GetTexture());
        bg:SetVertexColor(c.r, c.g, c.b);
        PlayerFrame.bg = true;
    end;
    if UnitIsPlayer("target") then
        c = RAID_CLASS_COLORS[select(2, UnitClass("target"))];
        TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b);
    end;
    if UnitIsPlayer("focus") then
        c = RAID_CLASS_COLORS[select(2, UnitClass("focus"))];
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
        statusbar:SetStatusBarColor(c.r, c.g, c.b);
        PlayerFrameHealthBar:SetStatusBarColor(c.r, c.g, c.b);
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
    ArenaEnemyFrame1:SetPoint("CENTER", UIParent, "CENTER", -200, 50);
    ArenaEnemyFrame2:SetPoint("CENTER", UIParent, "CENTER", -200, 0);
    ArenaEnemyFrame3:SetPoint("CENTER", UIParent, "CENTER", -200, -50);
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
-- Colorize action bar, units, minimap with faction color (horde, alliance and neutral)
-- Replace end caps with customized ones (horde, alliance and neutral)
function STAYFOCUSEDEVENTS:ADDON_LOADED(...)
    local red, geen, blue;
    local faction, _ = UnitFactionGroup("player");
    if faction == "Horde" then
        MainMenuBarRightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap horde.png");
        MainMenuBarLeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap horde.png");
        red = 0.55;
        blue = 0;
    elseif faction == "Alliance" then
        MainMenuBarRightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap alliance.png");
        MainMenuBarLeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap alliance.png");
        red = 0.3;
        green = 0.4;
        blue = 1;
    else
        MainMenuBarRightEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap neutral.png");
        MainMenuBarLeftEndCap:SetTexture("Interface\\AddOns\\StayFocusedUI\\Textures\\endcap neutral.png");
        red = 0.98;
        green = 0.84;
        blue = 0.11;
    end
    for i, v in pairs({
        ArtifactWatchBar.StatusBar.WatchBarTexture0, ArtifactWatchBar.StatusBar.WatchBarTexture1, ArtifactWatchBar.StatusBar.WatchBarTexture2, ArtifactWatchBar.StatusBar.WatchBarTexture3, ArtifactWatchBar.StatusBar.XPBarTexture0, ArtifactWatchBar.StatusBar.XPBarTexture1,
        ArtifactWatchBar.StatusBar.XPBarTexture2, ArtifactWatchBar.StatusBar.XPBarTexture3, BonusActionBarFrameTexture0, BonusActionBarFrameTexture1, BonusActionBarFrameTexture2, BonusActionBarFrameTexture3, BonusActionBarFrameTexture4, CastingBarFrameBorder, FocusFrameSpellBarBorder,
        FocusFrameTextureFrameTexture, FocusFrameToTTextureFrameTexture, HonorWatchBar.StatusBar.WatchBarTexture0, HonorWatchBar.StatusBar.WatchBarTexture1, HonorWatchBar.StatusBar.WatchBarTexture2, HonorWatchBar.StatusBar.WatchBarTexture3, HonorWatchBar.StatusBar.XPBarTexture0,
        HonorWatchBar.StatusBar.XPBarTexture1, HonorWatchBar.StatusBar.XPBarTexture2, HonorWatchBar.StatusBar.XPBarTexture3, MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3, MainMenuExpBar.WatchBarTexture0, MainMenuExpBar.WatchBarTexture1,
        MainMenuExpBar.WatchBarTexture2, MainMenuExpBar.WatchBarTexture3, MainMenuExpBar.XPBarTexture0, MainMenuExpBar.XPBarTexture1, MainMenuExpBar.XPBarTexture2, MainMenuExpBar.XPBarTexture3, MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        MainMenuXPBarDiv1, MainMenuXPBarDiv2, MainMenuXPBarDiv3, MainMenuXPBarDiv4, MainMenuXPBarDiv5, MainMenuXPBarDiv6, MainMenuXPBarDiv7, MainMenuXPBarDiv8, MainMenuXPBarDiv9, MainMenuXPBarDiv10, MainMenuXPBarDiv11, MainMenuXPBarDiv12, MainMenuXPBarDiv13, MainMenuXPBarDiv14,
        MainMenuXPBarDiv15, MainMenuXPBarDiv16, MainMenuXPBarDiv17, MainMenuXPBarDiv18, MainMenuXPBarDiv19, MainMenuXPBarTextureLeftCap, MainMenuXPBarTextureMid, MainMenuXPBarTextureRightCap, MiniMapBattlefieldBorder, MiniMapLFGFrameBorder, MiniMapMailBorder, MiniMapTrackingButtonBorder,
        MinimapBorder, MinimapBorderTop, PartyMemberFrame1PetFrameTexture, PartyMemberFrame1Texture, PartyMemberFrame2PetFrameTexture, PartyMemberFrame2Texture, PartyMemberFrame3PetFrameTexture, PartyMemberFrame3Texture, PartyMemberFrame4PetFrameTexture, PartyMemberFrame4Texture,
        PetFrameTexture, PlayerFrameTexture, ReputationWatchBar.StatusBar.WatchBarTexture0, ReputationWatchBar.StatusBar.WatchBarTexture1, ReputationWatchBar.StatusBar.WatchBarTexture2, ReputationWatchBar.StatusBar.WatchBarTexture3, ReputationWatchBar.StatusBar.XPBarTexture0,
        ReputationWatchBar.StatusBar.XPBarTexture1, ReputationWatchBar.StatusBar.XPBarTexture2, ReputationWatchBar.StatusBar.XPBarTexture3, TargetFrameSpellBarBorder, TargetFrameTextureFrameTexture, TargetFrameToTTextureFrameTexture,
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
    SendAs(select(1, ...), select(5, ...), "GUILD", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chatogg");
end;
function STAYFOCUSEDEVENTS:CHAT_MSG_OFFICER(...)
    SendAs(select(1, ...), select(5, ...), "GUILD", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chatogg");
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
function STAYFOCUSEDEVENTS:CHAT_MSG_BN_CONVERSATION(...)
    SendAs(select(1, ...), select(5, ...), "BN_WHISPER", "Interface\\AddOns\\StayFocusedUI\\Sounds\\chat_w.ogg");
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
-- Announce minimap : rares, treasures except garrison cache (raid waning and sound)
function STAYFOCUSEDEVENTS:VIGNETTE_ADDED(...)
    if GetLocale() == "frFR" then
        isGarrisonCache = "Cache du fief";
        isDetected = "détecté";
    else
        isGarrisonCache = "Garrison cache";
        isDetected = "detected";
    end;
    vignetteID = select(1, ...);
    if vignetteID then
        _, _, name, _ = C_Vignettes.GetVignetteInfoFromInstanceID(vignetteID);
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
    _, action, _, _, sourceName, _, _, _, _, _, _, _, _, _, spell, _, _, _, _, _, _, _, _ = ...
    if GetLocale() == "frFR" then
        isKicked = "interrompu";
    else
        isKicked = "interrupted";
    end;
    if action == "SPELL_INTERRUPT" and (sourceName == UnitName("player") or sourceName == UnitName("pet")) then
        if IsInRaid() then
            SendChatMessage(GetSpellLink(spell) .. " " .. tostring(isKicked), "RAID");
        elseif IsInGroup() then
            SendChatMessage(GetSpellLink(spell) .. " " .. tostring(isKicked), "PARTY");
        end;
    end;
end;

--- Handler
STAYFOCUSED:SetScript("OnEvent", function(self, event, ...)
    STAYFOCUSEDEVENTS[event](self, ...)
end);
for k, _ in pairs(STAYFOCUSEDEVENTS) do
    STAYFOCUSED:RegisterEvent(k);
end;