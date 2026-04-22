SMODS.Enhancement {
    key = 'abstracted',
    atlas = 'enhancements',
    pos = { x = 0, y = 0 },
    config = { 
        Xmult = 2.5, 
        bonus_chips = 25,
    }, 
    not_stoned = true,
    replace_base_card = true,       
    no_rank = false,
    no_suit = false,
    specific_rank = 'tadc_Abstracted', -- SMODS prefixes your mod id
    specific_suit = 'Spades',          -- real suit so flush logic works normally
    label = 'Abstracted', 
    display_name = 'Abstracted Card',
    weight = 0,

    draw_base_card = function(self, card, layer)
        return false
    end,

    loc_txt = {
        name = 'Abstracted Card',
        text = {
            "{C:chips}+#4#{} chips, {X:mult,C:white}X#1# {} Mult",
            "{C:green}#2# in #3#{} chance to",
            "be sent to the cellar",
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            self.config.Xmult, 
            G.GAME.probabilities.normal, 
            4,
            self.config.bonus_chips
        } }
    end,

    calculate = function(self, card, context)
        -- 1. SCORING BONUSES
        -- Chips fire during main scoring
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = self.config.bonus_chips,
                card = card
            }
        end

        -- X_mult fires in joker_main so it doesn't retrigger with Red Seal/Mime
        if context.joker_main and context.cardarea == G.play then
            return {
                x_mult = self.config.Xmult,
                message = localize { type = 'variable', key = 'a_xmult', vars = { self.config.Xmult } }
            }
        end

        -- 2. DESTRUCTION LOGIC (The Fix)
        -- This triggers after the hand is finished scoring
        if context.post_scoring and not context.blueprint and not context.repetition then
            if pseudorandom('abstracted') < G.GAME.probabilities.normal / 4 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        attention_text({
                            text = "Cellar!",
                            scale = 0.8,
                            hold = 1,
                            colour = G.C.FILTER,
                            align = 'cm',
                            offset = { x = 0, y = -2.7 },
                            major = card
                        })
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
            end
        end
    end
}
SMODS.Enhancement {
    key = 'disappearing',
    atlas = 'enhancements',
    pos = { x = 1, y = 0 },
    config = {
        x_chips = 1.1,
    },
    label = 'Disappearing',
    display_name = 'Disappearing Card',
    replace_base_card = false,

    loc_txt = {
        name = 'Disappearing Card',
        text = {
            "{X:chips,C:white}X#1#{} Chips",
            "{C:green}#2# in #3#{} chance to",
            "disappear when clicked",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {
            self.config.x_chips,
            G.GAME.probabilities.normal,
            10,
        } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- Check the card is actually in the played hand
            local in_play = false
            if G.play and G.play.cards then
                for _, c in ipairs(G.play.cards) do
                    if c == card then in_play = true; break end
                end
            end
            if in_play then
                SMODS.calculate_effect({ x_chips = self.config.x_chips }, card)
            end
        end
    end
}