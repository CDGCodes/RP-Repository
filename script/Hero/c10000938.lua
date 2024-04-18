-- Evil Hero Granite Goliath
local s, id = GetID()

function s.initial_effect(c)
    -- Name treated as "Elemental HERO Clayman"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(84327329)  -- Code of "Elemental HERO Clayman"
    c:RegisterEffect(e1)

    -- Change battle positions of opponent's face-up monsters when Normal or Special Summoned
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.changePositionTarget)
    e2:SetOperation(s.changePositionOperation)
    c:RegisterEffect(e2)

    local e3 = e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Negate attack and decrease ATK/DEF of attacking monster
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_POSITION + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_BE_BATTLE_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id + 100)
    e4:SetCondition(s.negateAttackCondition)
    e4:SetOperation(s.negateAttackOperation)
    c:RegisterEffect(e4)
end

-- Change battle positions of opponent's face-up monsters
function s.changePositionTarget(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0,LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, g:GetCount(), 0, 0)
end

function s.changePositionOperation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0,LOCATION_MZONE, nil)
    if #g > 0 then
        for tc in aux.Next(g) do
            Duel.ChangePosition(tc, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK)
        end
    end
end

-- Negate attack and decrease ATK/DEF of attacking monster
function s.negateAttackCondition(e, tp, eg, ep, ev, re, r, rp)
    local atk = Duel.GetAttacker()
    return atk and atk:IsControler(1 - tp) and atk:IsFaceup() and atk:IsRelateToBattle()
end

function s.negateAttackOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local atk = Duel.GetAttacker()
    if atk:IsRelateToBattle() then
        Duel.NegateAttack()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-800)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 2)
            atk:RegisterEffect(e1)
            local e2 = e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            atk:RegisterEffect(e2)
        end
    end
end
