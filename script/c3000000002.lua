--Soul Corruption
--Created by ScareTheVoices
local s,id=GetID()
function s.initial_effect(c)
    --Apply effects when activated
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local attribute=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,nil,TYPE_MONSTER)
    local tc=g:GetFirst()
    while tc do
        -- Apply the attribute change to monsters in hand, deck, and on the field
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(attribute)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
    
    -- Retain attribute when moved to hand, Deck, or Graveyard
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0)
    e2:SetTarget(s.atttg)
    e2:SetValue(attribute)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end

function s.atttg(e,c)
    return c:IsType(TYPE_MONSTER)
end
