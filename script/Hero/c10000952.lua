-- Dark Fusion Revival
local s, id = GetID()

function s.initial_effect(c)
    -- Fusion summon 1 Fusion Monster from your Extra Deck, by banishing Fusion Materials from your hand, Deck, or GY.
    local e1 = Fusion.CreateSummonEff {
        handler = c,
        fusfilter = s.fusfilter,
        matfilter = Fusion.InHandMat(Card.IsAbleToRemove),
        extrafil = s.fextra,
        extraop = Fusion.BanishMaterial,
        extratg = s.extratg,
        chkf = FUSPROC_NOLIMIT
    }
    c:RegisterEffect(e1)

    -- If this card is in your GY: You can banish 1 "Evil HERO" monster from your GY; add this card to your hand.
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.fusfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION)
end

function s.fextra(e, tp, mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_GRAVE + LOCATION_HAND + LOCATION_DECK, 0, nil)
end

function s.extratg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_GRAVE, 0, 1, e:GetHandler()) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_COST)
        Duel.SendtoHand(e:GetHandler(), nil, REASON_EFFECT)
    end
end

function s.thfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
