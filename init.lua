dofile("data/scripts/lib/utilities.lua")
dofile("mods/dump_potion/settings.lua")

-- Build keycode lookup table from Noita's keycodes file
function build_keycode_lookup()
    local lookup = {}
    local keycodes_all = ModTextFileGetContent("data/scripts/debug/keycodes.lua") or ""
    for line in keycodes_all:gmatch("Key_.-\n") do
        local _, key, code = line:match("(Key_)(.+) = (%d+)")
        if key and code then
            lookup[key:upper()] = tonumber(code)
        end
    end
    lookup["SPACE"] = 44 -- Add common alias
    lookup[" "] = 44
    return lookup
end

local keycode_lookup = build_keycode_lookup()
local last_valid_key = keycode_lookup["K"] or 14

-- Convert key name from settings to keycode, fallback to last valid
function get_keycode_from_setting()
    local char = ModSettingGet("dump_potion.keybind") or "K"
    char = tostring(char):upper()
    local keycode = keycode_lookup[char]
    if keycode then
        last_valid_key = keycode
        return keycode
    else
        -- Revert to last valid key in both setting and UI
        local last_valid_char = nil
        for k, v in pairs(keycode_lookup) do
            if v == last_valid_key then
                last_valid_char = k
                break
            end
        end
        if last_valid_char then
            ModSettingSet("dump_potion.keybind", last_valid_char)
            ModSettingSetNextValue("dump_potion.keybind", last_valid_char, false)
        end
        return last_valid_key
    end
end

-- Convert keycode to key name (for legacy migration)
function get_keyname_from_keycode(code)
    local keycodes_all = ModTextFileGetContent("data/scripts/debug/keycodes.lua") or ""
    for line in keycodes_all:gmatch("Key_.-\n") do
        local _, key, c = line:match("(Key_)(.+) = (%d+)")
        if key and c and tonumber(c) == tonumber(code) then
            return key:upper()
        end
    end
    if tonumber(code) == 44 then return "SPACE" end
    return nil
end

-- Migrate legacy keycode value to key name
function sanitize_keybind_setting()
    local val = ModSettingGet("dump_potion.keybind")
    if val and tonumber(val) then
        local keyname = get_keyname_from_keycode(val)
        if keyname then
            ModSettingSet("dump_potion.keybind", keyname)
            ModSettingSetNextValue("dump_potion.keybind", keyname, false)
        end
    end
end

function OnPlayerSpawned(player_entity)
    -- No-op, but required by Noita mod API
end

function OnWorldPostUpdate()
    sanitize_keybind_setting()
    local key_binding = get_keycode_from_setting()
    if InputIsKeyJustDown(key_binding) then
        dump_potion()
    end
end

function dump_potion()
    local player = get_player()
    if player == nil then return end
    local inventory = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
    if inventory == nil then return end
    local active_item = ComponentGetValue2(inventory, "mActiveItem")
    if active_item == 0 then return end
    local potion_component = EntityGetFirstComponent(active_item, "PotionComponent")
    if potion_component ~= nil then
        local material_inventory = EntityGetFirstComponent(active_item, "MaterialInventoryComponent")
        if material_inventory ~= nil then
            local materials = ComponentGetValue2(material_inventory, "count_per_material_type")
            if materials ~= nil and #materials > 0 then
                for material_type, material_count in ipairs(materials) do
                    if material_count < 1 then goto continue end
                    local material_name = CellFactory_GetName(material_type - 1)
                    spawn_material_in_facing_direction(material_name, material_count)
                    AddMaterialInventoryMaterial(active_item, material_name , 0)
                    ::continue::
                end
            end
        end
    end
end

function get_player()
    local players = EntityGetWithTag("player_unit")
    if #players == 0 then return nil end
    return players[1]
end

function get_player_facing_direction()
    local player = get_player()
    if player == nil then return nil end
    local controls_component = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
    EntitySetComponentIsEnabled(player, controls_component, false)
    local aiming_vector = ComponentGetValue2(controls_component, "mAimingVector")
    EntitySetComponentIsEnabled(player, controls_component, true)
    if aiming_vector < 0 then return "left" else return "right" end
end

function spawn_material_in_facing_direction(material_name, material_count)
    local player = get_player()
    if player == nil then return end
    local distance = 50
    local x, y = EntityGetTransform(player)
    local direction = get_player_facing_direction()
    if direction == "left" then x = x - distance else x = x + distance end
    GameCreateParticle(material_name, x, y, material_count, 0, 0, false, true)
end

-- GamePrint("dump_potion: Initialized.")
