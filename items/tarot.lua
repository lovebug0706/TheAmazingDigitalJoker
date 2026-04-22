SMODS.Consumable {
    key = 'cellar',
    set = 'Tarot',
    atlas = 'tarot', -- Ensure this points to your sprite sheet
    pos = { x = 0, y = 0 }, -- First frame in your atlas
    config = { max_highlighted = 3 },
    
    loc_txt = {
        name = 'The Cellar',
        text = {
            "Enhances up to {C:attention}#1#{} selected",
            "cards into {C:attention}Abstracted Cards{}"
        }
    },

    -- Tooltip variables
    loc_vars = function(self, info_queue, card)
        -- This adds the Obsidian Card description to the tooltip automatically
        info_queue[#info_queue+1] = G.P_CENTERS.m_tadc_abstracted
        return { vars = { self.config.max_highlighted } }
    end,

    -- Check if the card can be used
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted >= 1 and #G.hand.highlighted <= self.config.max_highlighted
    end,

    -- What happens when you click "Use"
    use = function(self, card, area, copier)
    for i = 1, #G.hand.highlighted do
        local highlighted_card = G.hand.highlighted[i]
        highlighted_card:flip()
        
        -- 1. Apply Enhancement
        highlighted_card:set_ability(G.P_CENTERS.m_tadc_abstracted, nil, true)
        
        -- 2. FORCE IDENTITY OVERRIDE
        -- We manually set the base values to match your specific_rank/suit.
        -- This 'severs' the connection to the old 10s or 8s.
        highlighted_card.base.value = 'tadc_Abstracted'
    highlighted_card.base.suit = 'Spades'
    highlighted_card.base.id = 15
    highlighted_card:set_sprites(highlighted_card.config.center)
        
        -- 3. Force UI Redraw
        highlighted_card:set_sprites(highlighted_card.config.center)
        
        highlighted_card:flip()
    end
    
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
end
}
SMODS.Consumable {
    key = 'nationalanthem',
    set = 'Tarot',
    atlas = 'tarot', -- Ensure this points to your sprite sheet
    pos = { x = 1, y = 0 }, -- First frame in your atlas
    config = { max_highlighted = 3 },
    
    loc_txt = {
        name = 'National Anthem',
        text = {
            "Enhances up to {C:attention}#1#{} selected",
            "cards into {C:attention}Disappearing Cards{}"
        }
    },

    -- Tooltip variables
    loc_vars = function(self, info_queue, card)
        -- This adds the Obsidian Card description to the tooltip automatically
        info_queue[#info_queue+1] = G.P_CENTERS.m_tadc_disappearing
        return { vars = { self.config.max_highlighted } }
    end,

    -- Check if the card can be used
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted >= 1 and #G.hand.highlighted <= self.config.max_highlighted
    end,

    -- What happens when you click "Use"
    use = function(self, card, area, copier)
    for i = 1, #G.hand.highlighted do
        local highlighted_card = G.hand.highlighted[i]
        highlighted_card:flip()
        
        -- 1. Apply Enhancement
        highlighted_card:set_ability(G.P_CENTERS.m_tadc_disappearing, nil, true)
        
        -- 3. Force UI Redraw
        highlighted_card:set_sprites(highlighted_card.config.center)
        
        highlighted_card:flip()
    end
    
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
end
}
SMODS.Consumable {
    key = 'circus',
    set = 'Tarot',
    atlas = 'tarot',
    pos = { x = 2, y = 0 },  -- adjust to your atlas position
    config = {},

    loc_txt = {
        name = 'The Circus',
        text = {
            "Spawns a random joker",
            "from {C:attention}The Amazing Digital Circus{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    can_use = function(self, card)
        -- Can only use if there's room for a joker
        return #G.jokers.cards < G.jokers.config.card_limit
    end,

    use = function(self, card, area, copier)
    local tadc_jokers = {}
    for key, center in pairs(G.P_CENTERS) do
        if center.set == 'Joker' 
        and center.mod 
        and center.mod.id == 'TheAmazingDigitalJoker'
        and not center.hidden then
            table.insert(tadc_jokers, key)
        end
    end

    if #tadc_jokers > 0 then
        local chosen = pseudorandom_element(tadc_jokers, pseudoseed('circus_pick'))
        SMODS.add_card({
            set = 'Joker',
            key = chosen,
        })
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
end
}