-- Custom Contact Fusion Monster
local s, id = GetID()

function s.initial_effect(c)
    -- Contact Fusion Material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, 89943723, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK))
    Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)

    -- Add your additional effects here if needed
end

-- Contact Fusion Material Filter
function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end
-- Contact Fusion Operation
function s.contactop(g, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

-- Special Summon Limit--
function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
