local s, id = GetID()

function s.initial_effect(c)
    -- Fusion Summon setup
    c:EnableReviveLimit()
    Fusion.AddProcFun2(c, s.matfilter, s.matfilter, true)

    -- Indestructible by battle and direct attack conditions
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetCondition(s.heroOnFieldCondition)
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetCondition(s.heroOnFieldCondition)
    c:RegisterEffect(e2)

    -- Set Spell/Trap and add "HERO" card to hand after battle damage
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetTarget(s.sttg)
    e3:SetOperation(s.stop)
    c:RegisterEffect(e3)
end

function s.matfilter(c, fc, sumtype, tp)
    return c:IsSetCard(0x8) and c:IsLevelBelow(2000)
end

function s.heroOnFieldCondition(e)
    local c = e:GetHandler()
    local controller = c:GetControler()
    local monsters = Duel.GetFieldGroup(controller, LOCATION_MZONE, 0)
    if monsters then
        local count = monsters:FilterCount(s.heroFilter, nil) - 1
        return count > 0
    end
    return false
end

function s.heroFilter(c)
    return c:IsFaceup() and c:IsSetCard(0x8)
end

local heroSpellTrapCodes = {
    [8949584] = true, [213326] = true, [44676200] = true, [19024706] = true, [22020907] = true,
    [67045174] = true, [86952477] = true, [89832779] = true, [11961740] = true,
    [4290468] = true, [03775782] = true, [53046408] = true, [79785958] = true,
    [98649372] = true, [78211862] = true, [75417459] = true, [21015833] = true,
    [87430998] = true, [58074572] = true, [21143940] = true,
    [96782886] = true, [45906428] = true, [63035430] = true, [94380860] = true,
    [58242947] = true, [54840055] = true, [28985331] = true, [27564031] = true, [20721928] = true,
    -- Continue adding all other codes in this format, excluding 44095762
}

function s.stfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and heroSpellTrapCodes[c:GetCode()] and c:IsSSetable()
end



function s.sttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.stfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.stop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local sg=Duel.SelectMatchingCard(tp, s.stfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
    if #sg>0 then
        Duel.SSet(tp, sg:GetFirst())
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        sg:GetFirst():RegisterEffect(e1)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local hg=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(Card.IsSetCard), tp, LOCATION_GRAVE, 0, 1, 1, nil, 0x8)
    if #hg>0 then
        Duel.SendtoHand(hg, nil, REASON_EFFECT)
    end
end