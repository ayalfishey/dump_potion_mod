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
        ui_name = "Dump Potion Key",
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