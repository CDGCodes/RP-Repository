-- Evil Domination!!!
local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Banish from GY and add cards effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.filterFusion(c,e,tp)
    return c:IsSetCard(0x6008) and c:IsType(TYPE_FUSION)
end

function s.filterReturn(c, code)
    return c:IsCode(code) and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filterReturn,tp,LOCATION_REMOVED,0,1,nil,10000942)
            and Duel.IsExistingMatchingCard(s.filterReturn,tp,LOCATION_REMOVED,0,1,nil,10000943)
            and Duel.IsExistingMatchingCard(s.filterReturn,tp,LOCATION_REMOVED,0,1,nil,10000944)
            and Duel.IsExistingMatchingCard(s.filterReturn,tp,LOCATION_REMOVED,0,1,nil,10000945)
    end
    local g = Group.CreateGroup()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tc = Duel.SelectMatchingCard(tp,s.filterReturn,tp,LOCATION_REMOVED,0,1,1,nil,10000942):GetFirst()
    g:AddCard(tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    tc = Duel.SelectMatchingCard(tp,s.filterReturn,tp,LOCATION_REMOVED,0,1,1,nil,10000943):GetFirst()
    g:AddCard(tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    tc = Duel.SelectMatchingCard(tp,s.filterReturn,tp,LOCATION_REMOVED,0,1,1,nil,10000944):GetFirst()
    g:AddCard(tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    tc = Duel.SelectMatchingCard(tp,s.filterReturn,tp,LOCATION_REMOVED,0,1,1,nil,10000945):GetFirst()
    g:AddCard(tc)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filterFusion, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Special Summon from Extra Deck
    local g = Duel.SelectMatchingCard(tp, s.filterFusion, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        local tc = g:GetFirst()
        if Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP) then
            -- Manually apply the Fusion Summon effect
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_FUSION_SUMMON)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,1)
            tc:RegisterEffect(e1,true)
        end
    end
end

function s.thfilter(c)
    return c:IsSetCard(0x6008) and c:IsType(TYPE_MONSTER) or (c:IsSetCard(0x6008) and c:IsType(TYPE_SPELL))
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
