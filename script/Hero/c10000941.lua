local s, id = GetID()

function s.initial_effect(c)
    -- Activate: Special Summon a "HERO" monster and destroy the attacking monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.spfilter(c, e, tp)
    -- Filter for "Evil HERO" monsters in your graveyard that can be special summoned
    return c:IsSetCard(0x6008) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    -- Target an "Evil HERO" monster in your graveyard
    if chk==0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
            and Duel.GetAttacker() ~= nil
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, Duel.GetAttacker(), 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    -- Operation: Special Summon the selected "Evil HERO" and destroy the attacker
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    local atk = Duel.GetAttacker()
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.SpecialSummonComplete()
        if atk and atk:IsRelateToBattle() then -- Check if the attacker is still valid for destruction
            Duel.Destroy(atk, REASON_EFFECT)
        end
    end
end
