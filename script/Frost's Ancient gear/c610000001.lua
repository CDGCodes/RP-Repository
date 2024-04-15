--Ancient Gear Burst-Gear Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,610000000,1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ANCIENT_GEAR),1)
	--Your opponent cannot activate Spell/Trap cards until the End of the Damage Step
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
 e3:SetCode(EFFECT_CANNOT_ACTIVATE)
 e3:SetRange(LOCATION_MZONE)
 e3:SetTargetRange(0,1)
 e3:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
 e3:SetCondition(function(e) return Duel.GetAttacker()==e:GetHandler() end)
 c:RegisterEffect(e3)

 
end
