--The Corrupted Wind
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be normal summoned/set
    c:EnableUnsummonable()
    c:AddMustBeSpecialSummonedByCardEffect()
    --Special summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Cannot be special summoned by other ways
    --local e2=Effect.CreateEffect(c)
    --e2:SetType(EFFECT_TYPE_SINGLE)
    --e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    --e2:SetCode(EFFECT_SPSUMMON_CONDITION)
    --e2:SetValue(aux.FALSE)
    --c:RegisterEffect(e2)

    --Track activation of the card with ID 3000000002 and WIND attribute choice
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)
    --if not s.global_check then
    --    s.global_check=true
    --    local ge1=Effect.CreateEffect(c)
    --    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    --    ge1:SetCode(EVENT_CHAINING)
    --    ge1:SetOperation(s.checkop)
    --    Duel.RegisterEffect(ge1,0)
    --end

    --Special summon a WIND attribute monster from the graveyard once per turn during the end phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0)) -- Adding description
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.epcon)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)

    --Quick effect: Move a WIND monster to the spell and trap zone or vice versa
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1)) -- Adding description
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.stztg)
    e4:SetOperation(s.stzop)
    c:RegisterEffect(e4)

    --Gain 500 ATK for each monster set as a Continuous Spell
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetValue(s.atkval)
    c:RegisterEffect(e5)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(2100040002) then
        --Debug.Message(Duel.GetFlagEffectLabel(1, 3000000002))
        Duel.RegisterFlagEffect(rp,id,0,0,0,Duel.GetFlagEffectLabel(1, 2100040002))
    end
end

--Calculate the ATK boost based on the number of monsters set as Continuous Spells
function s.atkval(e,c)
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_SZONE,0,nil)
    return g:GetCount() * 500
end

--Filter for monsters set as Continuous Spells
function s.ctfilter(c)
    return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsOriginalType(TYPE_MONSTER)
end

--Special summon condition function
function s.spcon(e)
    local c=e:GetHandler()
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
        and ((Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp, id)==ATTRIBUTE_WIND) 
        or (Duel.HasFlagEffect(1-tp, id) and Duel.GetFlagEffectLabel(1-tp, id)==ATTRIBUTE_WIND))
end

--Special summon operation function
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
        if Duel.Destroy(g,REASON_COST)~=2 then return end
    end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Filter to check WIND attribute monsters on the field, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDestructable() and not c:IsCode(id)
end

--Condition to check if it's the controller's end phase
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return tp==Duel.GetTurnPlayer()
end

--Target function for special summoning WIND attribute monster from the graveyard
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WIND) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation function for special summoning WIND attribute monster from the graveyard
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_WIND)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Target function for moving WIND monster to spell and trap zone or vice versa
function s.stztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_MZONE,0,1,nil, e, tp)
        or Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_SZONE,0,1,nil, e, tp) end
end

--Operation function for moving WIND monster to spell and trap zone or vice versa
function s.stzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local g=Duel.SelectMatchingCard(tp,s.stzfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil, e, tp)
    local tc=g:GetFirst()
    if tc then
        if tc:IsLocation(LOCATION_MZONE) then
            if Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
                Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
            elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
                --Treat it as a Continuous Spell
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_CHANGE_TYPE)
                e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
                e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
                tc:RegisterEffect(e1)
            end
        else
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

--Filter for WIND monsters on the field
function s.stzfilter(c,e,tp)
    if c:IsAttribute(ATTRIBUTE_WIND) then
        if c:IsLocation(LOCATION_MZONE) then return true end
        return c:IsMonsterCard() and c:IsContinuousSpell() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
end
