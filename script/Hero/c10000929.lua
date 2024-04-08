--Elemental HERO Cutting Bladedge
local s,id=GetID()
function s.initial_effect(c)
    --Always treated as "Elemental HERO Bladedge"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetValue(73999409) -- The original card code for "Elemental HERO Bladedge"
    c:RegisterEffect(e0)

    --Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Banish and damage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end

function s.spfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x8) and c:IsAbleToGraveAsCost()
end

function s.heroCardFilter(c,tp,exc)
    return c:IsSetCard(0x8) and c:IsAbleToRemoveAsCost() and not c:IsCode(exc:GetCode())
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SendtoGrave(g1,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.heroCardFilter),tp,LOCATION_GRAVE,0,1,1,nil,tp,g1:GetFirst())
    Duel.Remove(g2,POS_FACEUP,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetDefense())
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Damage(1-tp,bc:GetDefense(),REASON_EFFECT)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        -- Updated to search for "HERO" monster with level less than or equal to the level of the destroyed monster
        local lv=bc:GetLevel()  -- Get the level of the battle destroyed monster
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filterHero),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,lv)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- Filter function for HERO monsters with level restriction
function s.filterHero(c,lv)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end