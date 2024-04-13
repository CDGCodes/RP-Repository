-- Neo-Spacian Neos Core
local s, id = GetID()

function s.initial_effect(c)
    -- Treat as "Elemental HERO Neos"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_MZONE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(89943723)  -- Card ID for "Elemental HERO Neos"
    c:RegisterEffect(e1)

    -- Shuffle 1 other “Neos” or “Neo-Spacian” monster from your field or GY into your Deck: Add this card from your GY to your hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Equip to Fusion Monster instead when shuffled into Deck
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)
    aux.AddEREquipLimit(c, nil,aux.True, function(c,e,tp,tc) c:EquipByEffectAndLimitRegister(e,tp,tc,id,true)end,e3)

    -- Trigger effect: If the equipped monster destroys a monster by battle, add 1 “Neo Space” Spell or 1 “Neo-Spacian” monster from your Deck to your hand
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.addCondition)
    e4:SetTarget(s.addTarget)
    e4:SetOperation(s.addOperation)
    c:RegisterEffect(e4)
end

-- Shuffle 1 other “Neos” or “Neo-Spacian” monster from your field or GY into your Deck: Add this card from your GY to your hand
function s.thfilter(c)
    return c:IsSetCard(0x9) or c:IsSetCard(0x1f) and c:IsAbleToDeck()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, nil,e)
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_ONFIELD + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, 1, 1, nil,e)
    if #g > 0 then
        local tc = g:GetFirst()
        if Duel.SendtoDeck(tc, nil, 2, REASON_EFFECT) ~= 0 then -- Return the selected monster to the Deck
        Duel.SendtoHand(e:GetHandler(), nil, REASON_EFFECT) -- Return this card from the GY to the hand
        end
    end
end


function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsLocation(LOCATION_DECK) then
        local c = Duel.GetFirstMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, nil, TYPE_FUSION)
        if c then
            Duel.Equip(tp, e:GetHandler(), c)
            local e0=Effect.CreateEffect(e:GetHandler())
            e0:SetType(EFFECT_TYPE_SINGLE)
            e0:SetCode(EFFECT_EQUIP_LIMIT)
            e0:SetReset(RESET_EVENT|RESETS_STANDARD)
            e0:SetValue(function(e,c)return c==e:GetLabelObject()end)
            e0:SetLabelObject(c)
            e:GetHandler():RegisterEffect(e0)
            -- Increase ATK by 500
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_EQUIP)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            e:GetHandler():RegisterEffect(e1)
            -- Add the effect for destroying a monster by battle
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_EQUIP + EFFECT_TYPE_TRIGGER_O)
            e2:SetCode(EVENT_BATTLE_DESTROYING)
            e2:SetRange(LOCATION_MZONE)
            e2:SetOperation(s.addOperation)
            e:GetHandler():RegisterEffect(e2)
        end
    end
end


-- Trigger effect: If the equipped monster destroys a monster by battle, add 1 “Neo Space” Spell or 1 “Neo-Spacian” monster from your Deck to your hand
function s.addCondition(e, tp, eg, ep, ev, re, r, rp)
    local ec = e:GetHandler():GetEquipTarget()
    return ec and ec:IsRelateToBattle()
end

function s.addTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil, e)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.addOperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
    end
end

function s.thfilter(c,e)
    return c ~= e:GetHandler() and (c:IsSetCard(0x9) or c:IsSetCard(0x1f)) and c:IsAbleToDeck()
end
function s.addfilter(c,e)
    return (c:IsSetCard(0x9) or c:IsSetCard(0x1f)) and c:IsAbleToHand()
end
-- Check if the equipped monster is a valid target for equipping
function s.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9)
end