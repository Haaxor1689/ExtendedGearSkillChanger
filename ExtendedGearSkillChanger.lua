ExtendedGearSkillChanger = {}
ExtendedGearSkillChanger.name = "ExtendedGearSkillChanger"

local LAM2 = LibStub("LibAddonMenu-2.0")
local panelData = {
    type = "panel",
    name = "Gear/Skill Changer"
}
local optionsData = {
    [1] = {
        type = "header",
        name = "Gear options"
    },
    [2] = {
        type = "checkbox",
        name = "Gear sets window movable",
        getFunc = function()
            return ExtendedGearSkillChanger.savedVariables.gearWindowMovable
        end,
        setFunc = function(value)
            ExtendedGearSkillChanger.savedVariables.gearWindowMovable = value
            GCBI:SetMovable(value)
        end
    },
    [3] = {
        type = "checkbox",
        name = "Hide clear button",
        getFunc = function()
            return ExtendedGearSkillChanger.savedVariables.gearClearHidden
        end,
        setFunc = function(value)
            ExtendedGearSkillChanger.savedVariables.gearClearHidden = value
            GCBIClearSet:SetHidden(value)
        end
    },
    [4] = {
        type = "button",
        name = "Sync Skills to Gear",
        func = function()
            ExtendedGearSkillChanger.SyncSkillsToGear()
        end,
        tooltip = "Synchronizes your skill preset names and icons to gear presets",
        isDangerous = true;
        warning = "This will rewrite your saved skill set names and icond. Will need to reload the UI."
    },
    [5] = {
        type = "header",
        name = "Skill options"
    },
    [6] = {
        type = "checkbox",
        name = "Skill sets window movable",
        getFunc = function()
            return ExtendedGearSkillChanger.savedVariables.skillWindowMovable
        end,
        setFunc = function(value)
            ExtendedGearSkillChanger.savedVariables.skillWindowMovable = value
            SCBI:SetMovable(value)
        end
    },
    [7] = {
        type = "checkbox",
        name = "Hide clear button",
        getFunc = function()
            return ExtendedGearSkillChanger.savedVariables.skillClearHidden
        end,
        setFunc = function(value)
            ExtendedGearSkillChanger.savedVariables.skillClearHidden = value
            SCBIClearSet:SetHidden(value)
        end
    },
    [8] = {
        type = "button",
        name = "Sync Gear to Skills",
        func = function()
            ExtendedGearSkillChanger.SyncGearToSkills()
        end,
        tooltip = "Synchronizes your gear preset names and icons to skill presets",
        isDangerous = true,
        warning = "This will rewrite your saved gear set names and icond. Will need to reload the UI."
    },
    [9] = {
        type = "header",
        name = "QuickMenu options"
    },
    [10] = {
        type = "checkbox",
        name = "Only show if both gear and set is saved",
        requiresReload = true,
        getFunc = function()
            return ExtendedGearSkillChanger.savedVariables.onlyIfBoth
        end,
        setFunc = function(value)
            ExtendedGearSkillChanger.savedVariables.onlyIfBoth = value
        end
    }
}

function ExtendedGearSkillChanger:Initialize()
    LAM2:RegisterAddonPanel("ExtendedGearSkillChangerOptions", panelData)
    LAM2:RegisterOptionControls("ExtendedGearSkillChangerOptions", optionsData)

    ExtendedGearSkillChanger.savedVariables = ZO_SavedVars:New("ExtendedGearSkillChangerSettings", 1, nil, {})
    ExtendedGearSkillChanger.SetDefaultSettings()
    ExtendedGearSkillChanger.ApplySettings()

    -- Init quick menu actions
    if QuickMenu then
        ExtendedGearSkillChanger.AddQuickMenuActions()
    end
end

function ExtendedGearSkillChanger.SetDefaultSettings()
    local sv = ExtendedGearSkillChanger.savedVariables
    if sv.gearWindowMovable == nil then
        sv.gearWindowMovable = true
    end
    if sv.skillWindowMovable == nil then
        sv.skillWindowMovable = true
    end
    if sv.gearClearHidden == nil then
        sv.gearClearHidden = false
    end
    if sv.skillClearHidden == nil then
        sv.skillClearHidden = false
    end
    if sv.onlyIfBoth == nil then
        sv.onlyIfBoth = false
    end
end

function ExtendedGearSkillChanger.ApplySettings()
    GCBI:SetMovable(ExtendedGearSkillChanger.savedVariables.gearWindowMovable)
    SCBI:SetMovable(ExtendedGearSkillChanger.savedVariables.skillWindowMovable)
    GCBIClearSet:SetHidden(ExtendedGearSkillChanger.savedVariables.gearClearHidden)
    SCBIClearSet:SetHidden(ExtendedGearSkillChanger.savedVariables.skillClearHidden)
end

function ExtendedGearSkillChanger.AddQuickMenuActions()
    local svg = GearChangerByIakoni.savedVariables
    local svs = SkillChangerByIakoni.savedVariables

    local function IsSetSaved(index, savedVariables)
        return savedVariables and savedVariables.ArraySetSavedFlag[index] == 1
    end

    for i = 1, 10 do
        if ExtendedGearSkillChanger.savedVariables.onlyIfBoth then
            if IsSetSaved(i, svg) and IsSetSaved(i, svs) then
                ExtendedGearSkillChanger.RegisterMenuEntry(i, svg)
            end
        else
            if IsSetSaved(i, svg) then
                ExtendedGearSkillChanger.RegisterMenuEntry(i, svg)
            elseif IsSetSaved(i, svs) then
                ExtendedGearSkillChanger.RegisterMenuEntry(i, svs)
            end
        end
    end
end

function ExtendedGearSkillChanger.RegisterMenuEntry(index, savedVariables)
    QuickMenu.RegisterMenuEntry(
        ExtendedGearSkillChanger.name,
        "equip" .. index,
        "Equip " .. savedVariables.ArraySetName[index] .. " set",
        GearChangerByIakoni.TextureArrayForGearSet[savedVariables.ArraySetIcon[index]],
        GearChangerByIakoni.TextureArrayForGearSet[savedVariables.ArraySetIcon[index]],
        function()
            GearChangerByIakoni.HotkeyEquipBOTH(index)
        end
    )
end

function ExtendedGearSkillChanger.SyncSkillsToGear()
    local svg = GearChangerByIakoni.savedVariables
    local svs = SkillChangerByIakoni.savedVariables

    if svg == nil or svs == nil then
        return
    end

    for i = 1, 10 do
        svs.ArraySetName[i] = svg.ArraySetName[i]
        svs.ArraySetIcon[i] = ExtendedGearSkillChanger.GearToSkillIcon(svg.ArraySetIcon[i])
    end
    d("Synchronized your skill presets to gear presets. /reloadui for changes to take effect.")
end

function ExtendedGearSkillChanger.SyncGearToSkills()
    local svg = GearChangerByIakoni.savedVariables
    local svs = SkillChangerByIakoni.savedVariables

    if not (svg and svs) then
        return
    end

    for i = 1, 10 do
        svg.ArraySetName[i] = svs.ArraySetName[i]
        svg.ArraySetIcon[i] = ExtendedGearSkillChanger.SkillToGearIcon(svs.ArraySetIcon[i])
    end
    d("Synchronized your gear presets to skill presets. /reloadui for changes to take effect.")
end

function ExtendedGearSkillChanger.GearToSkillIcon(index)
    if index == 1 then
        return 7
    elseif index == 2 then
        return 3
    elseif index == 3 then
        return 4
    elseif index == 4 then
        return 5
    elseif index == 5 then
        return 6
    elseif index == 6 then
        return 8
    elseif index == 7 then
        return 9
    elseif index == 8 then
        return 2
    elseif index == 9 then
        return 10
    elseif index == 10 then
        return 1
    elseif index == 11 then
        return 12
    elseif index == 12 then
        return 11
    end
end

function ExtendedGearSkillChanger.SkillToGearIcon(index)
    if index == 7 then
        return 1
    elseif index == 3 then
        return 2
    elseif index == 4 then
        return 3
    elseif index == 5 then
        return 4
    elseif index == 6 then
        return 5
    elseif index == 8 then
        return 6
    elseif index == 9 then
        return 7
    elseif index == 2 then
        return 8
    elseif index == 10 then
        return 9
    elseif index == 1 then
        return 10
    elseif index == 11 then
        return 12
    elseif index == 12 then
        return 11
    end
end

function ExtendedGearSkillChanger.OnAddOnLoaded(event, addonName)
    if addonName ~= ExtendedGearSkillChanger.name then
        return
    end
    ExtendedGearSkillChanger:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    ExtendedGearSkillChanger.name,
    EVENT_ADD_ON_LOADED,
    ExtendedGearSkillChanger.OnAddOnLoaded
)
