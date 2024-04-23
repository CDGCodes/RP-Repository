local s, id = GetID()

function s.initial_effect(c)
    -- If this card is in your hand: You can target 1 "Fire King" monster you control; 
    -- destroy it, and if you do, Special Summon this card.
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- If this card is destroyed by a card effect and sent to the GY: 
    -- You can Special Summon 1 Level 4 or lower "Fire King" monster from your Deck, 
    -- except "Fire King Flamestrider".
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1, id+1)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

function s.spfilter1(c)
    return c:IsSetCard(0x81) and c:IsDestructable()
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spfilter1, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter1(chkc) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.spfilter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if Duel.Destroy(tc, REASON_EFFECT) ~= 0 then
            Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r, REASON_EFFECT) ~= 0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x81) and c:IsLevelBelow(4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
