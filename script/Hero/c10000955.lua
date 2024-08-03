-- Masked HERO Shadow Blade
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsCode,21143940))) -- Mask Change card check
    c:RegisterEffect(e1)

    -- Banish on Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.banish_condition)
    e2:SetTarget(s.banish_target)
    e2:SetOperation(s.banish_operation)
    c:RegisterEffect(e2)

    -- Negate Attack
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negate_condition)
    e3:SetOperation(s.negate_operation)
    c:RegisterEffect(e3)

    -- ATK Boost
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetValue(s.atk_value)
    c:RegisterEffect(e4)
end

-- Banish condition
function s.banish_condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.banish_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.banish_operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end
end

-- Negate attack condition
function s.negate_condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local atk=Duel.GetAttacker()
    return atk and atk:IsControler(1-tp) and atk:IsFaceup() and atk:IsRelateToBattle()
end

function s.negate_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local atk=Duel.GetAttacker()
    if atk:IsRelateToBattle() then
        Duel.NegateAttack()
        Duel.Remove(atk,POS_FACEUP,REASON_EFFECT)
    end
end

-- ATK Boost
function s.atk_value(e,c)
    return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100
end
