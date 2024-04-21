-- Evil HERO Obsidian Goliath
local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon from hand if you control another "Evil HERO" monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Destroyed by battle effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BATTLE_DESTROYED)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Sent to GY effect
    local e3 = e2:Clone()
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.thcon)
    c:RegisterEffect(e3)

    -- Destroyed an opponent's monster by battle effect
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(s.descon)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end

function s.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x6008) and c:IsType(TYPE_MONSTER)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.fusionSpellFilter(c)
    return c:IsAbleToHand() and c:IsSetCard(0x46) and c:IsType(TYPE_SPELL)
end

function s.evilHEROMonsterFilter(c)
    return c:IsAbleToHand() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.fusionSpellFilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.fusionSpellFilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
    end
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    return bc:IsType(TYPE_MONSTER) and bc:IsLocation(LOCATION_GRAVE)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsType), tp, LOCATION_GRAVE, 0, nil, TYPE_FUSION)
        local exg = g:Filter(Card.IsAbleToDeck, nil)
        return #exg > 0 and Duel.IsExistingMatchingCard(s.evilHEROMonsterFilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 and Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.evilHEROMonsterFilter), tp, LOCATION_GRAVE, 0, 1, 1, nil)
        if #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
        end
    end
end
