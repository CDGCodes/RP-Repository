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
    
    -- Register a global effect to ensure the attribute change is persistent
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,attribute)

    -- Change attribute for existing monsters in hand, Deck, and field
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,nil,TYPE_MONSTER)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e1:SetValue(attribute)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
    
    -- Continuous effect to keep updating attribute
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetOperation(s.adjustop)
    Duel.RegisterEffect(e2,tp)
end

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
    local attribute=Duel.GetFlagEffectLabel(tp,id)
    if attribute then
        local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil,TYPE_MONSTER)
        local tc=g:GetFirst()
        while tc do
            if tc:GetAttribute()~=attribute then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
                e1:SetValue(attribute)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
            tc=g:GetNext()
        end
    end
end

