--[[
------------------------------Basic Table of Contents------------------------------
Line 17, Atlas ---------------- Explains the parts of the atlas.
Line 29, Joker 2 -------------- Explains the basic structure of a joker
Line 88, Runner 2 ------------- Uses a bit more complex contexts, and shows how to scale a value.
Line 127, Golden Joker 2 ------ Shows off a specific function that's used to add money at the end of a round.
Line 163, Merry Andy 2 -------- Shows how to use add_to_deck and remove_from_deck.
Line 207, Sock and Buskin 2 --- Shows how you can retrigger cards and check for faces
Line 240, Perkeo 2 ------------ Shows how to use the event manager, eval_status_text, randomness, and soul_pos.
Line 310, Walkie Talkie 2 ----- Shows how to look for multiple specific ranks, and explains returning multiple values
Line 344, Gros Michel 2 ------- Shows the no_pool_flag, sets a pool flag, another way to use randomness, and end of round stuff.
Line 418, Cavendish 2 --------- Shows yes_pool_flag, has X Mult, mainly to go with Gros Michel 2.
Line 482, Castle 2 ------------ Shows the use of reset_game_globals and colour variables in loc_vars, as well as what a hook is and how to use it.
--]]

SMODS.Joker {
    object_type = "Joker",
	-- How the code refers to the joker.
	key = 'whereskinger',
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Kinger',
		text = {
			--[[
			The #1# is a variable that's stored in config, and is put into loc_vars.
			The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
				There's {X:}, which sets the background, usually used for XMult.
				There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
				There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
				Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
				You can find the vanilla joker descriptions and names as well as several other things in the localization files.
				]]
			"Im starting to think...",
			"{X:mult,C:white}X#1# {} Mult, Gains {C:green}+#2#{} Xmult per round",
			"{C:red}Do not use with Caine."
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { mult = 2.5, mult_gain = 0.75 } },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
	end,
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 4,
	-- Which atlas key to pull from.
	atlas = 'TADCMODJokers',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 0, y = 0 },
	-- Kinger Overlay below.
	soul_pos = { x = 1, y = 0 },
	-- Cost of card in shop.
	cost = 10,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)
		-- Tests if context.joker_main == true.
		-- joker_main is a SMODS specific thing, and is where the effects of jokers that just give +stuff in the joker area area triggered, like Joker giving +Mult, Cavendish giving XMult, and Bull giving +Chips.
		if context.joker_main then
			-- Tells the joker what to do. In this case, it pulls the value of mult from the config, and tells the joker to use that variable as the "mult_mod".
			return {
				Xmult_mod = card.ability.extra.mult,
				-- This is a localize function. Localize looks through the localization files, and translates it. It ensures your mod is able to be translated. I've left it out in most cases for clarity reasons, but this one is required, because it has a variable.
				-- This specifically looks in the localization table for the 'variable' category, specifically under 'v_dictionary' in 'localization/en-us.lua', and searches that table for 'a_mult', which is short for add mult.
				-- In the localization file, a_mult = "+#1#". Like with loc_vars, the vars in this message variable replace the #1#.
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.mult } }
				-- Without this, the mult will stil be added, but it'll just show as a blank red square that doesn't have any text.
			}
		end
		if context.end_of_round and context.game_over == false and context.main_eval then
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
        return {
            message = localize('k_upgrade_ex'),
            colour = G.C.GREEN
        }
    end
	end
}
SMODS.Joker {
    object_type = "Joker",
    key = 'cainesidekick',
    loc_txt = {
        name = 'Bubble',
        text = {
            "{C:red}You really were the lesser of the two.",
            "{X:mult,C:white}X#1#{} Mult, {X:chips,C:white}X#1#{} Chips",
            "Removable in {C:attention}#2#{} rounds."
        }
    },
    config = { extra = { penalty = 0.8, round = 0, maxround = 2 } },
    rarity = 1,
    atlas = 'TADCMODJokers',
    pos = { x = 2, y = 0 },
    cost = 1,
    
    add_to_deck = function(self, card, from_debuff)
        card.ability.eternal = true
    end,

    loc_vars = function(self, info_queue, card)
    local r_left = (card.ability.extra.maxround or 2) - math.max(card.ability.extra.round or 0, 0)
    return { vars = { (card.ability.extra.penalty or 0.8), r_left } }
end,

    calculate = function(self, card, context)
        -- In newer 2026 builds, using 'context.other_joker' or checking 'main_scoring' 
        -- is sometimes more reliable than 'joker_main' for X-effects.
			if context.joker_main then
            -- Talisman/New SMODS manual injection
            SMODS.calculate_effect({x_chips = card.ability.extra.penalty}, card)
            return {
                Xmult_mod = card.ability.extra.penalty,
                message = "Defective!",
                colour = G.C.RED
            }
        end

        -- Countdown logic
        -- Countdown logic
        if context.end_of_round and not context.blueprint and not context.repetition and context.main_eval then
            card.ability.extra.round = (card.ability.extra.round or 0) + 1
            if card.ability.extra.round >= card.ability.extra.maxround then
                card.ability.eternal = nil
                return { message = "*pop!*", colour = G.C.FILTER }
            else
                return { message = tostring(card.ability.extra.maxround - card.ability.extra.round), colour = G.C.FILTER }
            end
        end
    end  -- closes calculate function
}        -- closes SMODS.Joker
SMODS.Joker {
    object_type = "Joker",
    key = 'ringmaster',
    loc_txt = {
        name = 'Caine',
        text = {
            "{X:mult,C:white}X#1#{} Mult, Gains {C:green}+#2#{} Xmult per round",
            "{C:green}#3# in #4#{} chance to spawn {C:attention}Bubble{}",
            "{C:red}#5# in #6#{} chance to {C:red}destroy{} a random Joker",
            "and gain {X:mult,C:white}X#7#{} Mult",
            "{C:red,E:1}Do not use with Kinger."
        }
    },
    config = { extra = { mult = 5, mult_gain = 1, spawn_odds = 3, eat_odds = 6, eat_gain = 0.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult, 
            card.ability.extra.mult_gain,
            G.GAME.probabilities.normal, card.ability.extra.spawn_odds,
            G.GAME.probabilities.normal, card.ability.extra.eat_odds,
            card.ability.extra.eat_gain
        } }
    end,
    rarity = 3,
    atlas = 'TADCMODJokers',
    pos = { x = 3, y = 0 },
    soul_pos = { x = 4, y = 0 },
    cost = 6,
    calculate = function(self, card, context)
        -- 1. SCORING LOGIC
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.mult } }
            }
        end

        -- 2. KINGER CHECK (Triggers whenever any card is added or moved)
        if (context.setting_blind or context.cardarea_focus) and not context.blueprint then
            if G.jokers and G.jokers.cards then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i].config.center.key == 'j_tadc_whereskinger' then
                        card:start_dissolve()
                        return {
                            message = "Wait...",
                            colour = G.C.RED
                        }
                    end
                end
            end
        end

        -- 3. END OF ROUND CHAOS
        if context.end_of_round and not context.blueprint and context.main_eval then
            -- Scaling per round
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            
            -- Spawn Bubble
if #G.jokers.cards < G.jokers.config.card_limit or card.ability.set == 'Negative' then
    if pseudorandom('caine_spawn') < G.GAME.probabilities.normal / card.ability.extra.spawn_odds then
        local bubble = SMODS.add_card({
            set = 'Joker',
            key = 'j_tadc_cainesidekick',
            insane = true
        })
        -- Reset the round counter after spawning so end_of_round
        -- doesn't immediately count this round against it
        if bubble then
    bubble.ability.extra.round = -1  -- absorbs the immediate end_of_round tick
    bubble.ability.eternal = true
end
    end
end

            -- Delete a random Joker & Gain Mult
            if pseudorandom('caine_eat') < G.GAME.probabilities.normal / card.ability.extra.eat_odds then
                local other_jokers = {}
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] ~= card then
                        table.insert(other_jokers, G.jokers.cards[i])
                    end
                end
                
                if #other_jokers > 0 then
                    local victim = pseudorandom_element(other_jokers, pseudoseed('caine_victim'))
                    victim:start_dissolve()
                    
                    -- The reward
                    card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.eat_gain
                    
                    return {
                        message = "Gained +" .. card.ability.extra.eat_gain .. "X",
                        colour = G.C.MULT
                    }
                end
            end

            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.GREEN
            }
        end
    end
}