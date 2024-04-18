local s, id = GetID()

function s.initial_effect(c)
    -- Name treated as "Elemental HERO Burstinatrix"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(58932615)  -- Code of "Elemental HERO Burstinatrix"
    c:RegisterEffect(e1)

    -- Add "Polymerization" or "Dark Fusion" from deck to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.thCost)
    e2:SetTarget(s.thTarget)
    e2:SetOperation(s.thOperation)
    c:RegisterEffect(e2)

    -- Banish this card from your Graveyard, then target 1 monster your opponent controls; destroy it, and if you do, inflict damage to your opponent equal to half its original ATK
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetTarget(s.banishEffect)
    e4:SetOperation(s.banishOperation)
    e4:SetCountLimit(1, id + 100)
    c:RegisterEffect(e4)
end

-- Costs and Targets for Polymerization or Dark Fusion
function s.thCost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end  -- Check if it can be discarded
    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)  -- Actually discard as part of cost
end


function s.thFilter(c)
    return c:IsCode(24094653) or c:IsCode(94820406) and c:IsAbleToHand()
end

function s.thTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thFilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thOperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thFilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- Banish to destroy and damage
function s.banishEffect(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanBeEffectTarget(e) end
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) and e:GetHandler():IsAbleToRemove() end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY+CATEGORY_DAMAGE, g, 1, 0, 0)
end

function s.banishOperation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT) then
        local tc = Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            local dam = math.ceil(tc:GetBaseAttack() / 2)
            if Duel.Destroy(tc, REASON_EFFECT) ~= 0 then
                Duel.Damage(1-tp, dam, REASON_EFFECT)
            end
        end
    end
end