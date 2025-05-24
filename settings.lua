-- Load Noita's mod settings library
dofile("data/scripts/lib/mod_settings.lua")

-- Define mod ID and settings version
local mod_id = "dump_potion"
mod_settings_version = 1

-- Mod settings table
default_key = "K"
mod_settings = {
    {
        id = "keybind",
        ui_name = "Dump Potion Key ",
        ui_description = "Enter a single character (e.g., K, Z, space) for the key to dump the potion.",
        value_default = default_key,
        scope = MOD_SETTING_SCOPE_RUNTIME,
        type = "string"
    }
}

-- Migrate legacy keycode value ("14") to key name ("K") for users updating from old versions
if ModSettingGet("dump_potion.keybind") == "14" then
    ModSettingSet("dump_potion.keybind", default_key)
    ModSettingSetNextValue("dump_potion.keybind", default_key, false)
end

-- Mod settings update and GUI functions
function ModSettingsUpdate(init_scope)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end

function mod_setting_value_set(mod_id, gui, in_main_menu, setting, old_value, new_value)
    if setting.id == "keybind" then
        local key = tostring(new_value):upper()
        -- Build keycode lookup (reuse logic from init.lua)
        local keycode_lookup = {}
        local keycodes_all = ModTextFileGetContent("data/scripts/debug/keycodes.lua") or ""
        for line in keycodes_all:gmatch("Key_.-\n") do
            local _, k, code = line:match("(Key_)(.+) = (%d+)")
            if k and code then
                keycode_lookup[k:upper()] = tonumber(code)
            end
        end
        keycode_lookup["SPACE"] = 44
        keycode_lookup[" "] = 44

        if not keycode_lookup[key] then
            GamePrint("Dump Potion: Invalid key! Reverting to previous value.")
            return old_value
        end
    end
    return new_value
end