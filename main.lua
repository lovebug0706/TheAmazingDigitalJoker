-- main.lua

-- Enable optional features if any jokers need them
SMODS.current_mod.optional_features = {
    retrigger_joker = true,
}
-- Hook into the card's onclick function to inject our own context
local lcpref = Controller.L_cursor_press
Controller.L_cursor_press = function(self, x, y)
    lcpref(self, x, y)
    -- Only fire if not paused and we have a hand to interact with
    if G and G.hand and G.hand.cards and not G.SETTINGS.paused then
        for _, c in ipairs(G.hand.cards) do
            if c.config and c.config.center
            and c.config.center.key == 'm_tadc_disappearing'
            and c.states.hover.is == true then
                if pseudorandom('disappearing_click') < G.GAME.probabilities.normal / 10 then
                    attention_text({
                        text = "Hel-",
                        scale = 0.8,
                        hold = 1,
                        colour = G.C.FILTER,
                        align = 'cm',
                        offset = { x = 0, y = -2.7 },
                        major = c
                    })
                    G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.15,
    func = function()
        play_sound('tadc_disappear')
        c:start_dissolve()
        return true
    end
}))
                end
            end
        end
    end
end
-- Load Atlas
SMODS.Atlas {
    key = "TADCMODJokers",
    path = "jokers.png",
    px = 71,
    py = 95,
}
SMODS.Atlas {
    key = 'enhancements',
    path = 'enhancements.png',
    px = 71,
    py = 95
}
SMODS.Atlas {
    key = 'tarot',
    path = 'tarot.png',
    px = 71,
    py = 95
}
SMODS.Rank {
    key = 'Abstracted',
    card_key = 'Ab',       -- used to build card keys like "S_Ab", "H_Ab" etc.
    shorthand = 'Ab',
    nominal = 15,
    face_nominal = 0,
    loc_txt = { name = 'Abstracted' },
    pos = { x = 0 },      -- just an x offset into the vanilla cards_1 atlas column
    suit_map = {},         -- don't generate cards for any suit at startup
    in_pool = function(self, args)
        return false
    end,
}
SMODS.Sound {
    key = 'disappear',
    path = 'disappear.ogg',
}
-- Load all individual jokers from the items folder
-- Note: We use NFS because it's the standard for Steamodded to find local mod files
local subdir = "items"
local files = NFS.getDirectoryItems(SMODS.current_mod.path .. subdir)

for _, filename in pairs(files) do
    if filename:sub(-4) == ".lua" then
        -- This directly executes the file. 
        -- For this to work, the Joker must be defined as SMODS.Joker{...} inside the file.
        assert(SMODS.load_file(subdir .. "/" .. filename))()
    end
end