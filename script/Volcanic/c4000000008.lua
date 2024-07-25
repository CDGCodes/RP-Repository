local s, id = GetID()
function s.initial_effect(c)
    -- XYZ summon
    Xyz.AddProcedure(c, nil, 4, 2)
    c:EnableReviveLimit()
-- Add on to this effect so during your Main Phase you can attach a Pyro monster from your hand, Grave, or Banish Zone to this card as Xyz material (without any cost)
function s.xyz_attach_effect(c)
    local e = Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,1))
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e:SetRange(LOCATION_MZONE)
    e:SetCode(EFFECT_XYZ_MATERIAL)
    e:SetCondition(s.xyz_attach_condition)
    e:SetOperation(s.xyz_attach_operation)
    c:RegisterEffect(e)
end

function s.xyz_attach_condition(e,c,og)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,TYPE_PYRO)
    return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and mg:IsExists(s.xyz_attach_filter,1,nil,tp)
end

function s.xyz_attach_filter(c,tp)
    return c:IsType(TYPE_PYRO) and c:IsControler(tp)
end

function s.xyz_attach_operation(e,tp,eg,ep,ev,re,r,rp,c,og)
    local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,TYPE_PYRO)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=mg:FilterSelect(tp,s.xyz_attach_filter,1,1,nil,tp)
    if g:GetCount()>0 then
        local tc=g:GetFirst()
        if not tc:IsImmuneToEffect(e) then
            Duel.Overlay(c,Group.FromCards(tc))
        end
    end
end
