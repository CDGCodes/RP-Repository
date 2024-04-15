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

 --Make 1 zone unusable
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
 e2:SetProperty(EFFECT_FLAG_DELAY)
 e2:SetCode(EVENT_REMOVE)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCondition(s.zcon)
 e2:SetTarget(s.ztg)
 e2:SetOperation(s.zop)
 c:RegisterEffect(e2)
end
function s.zfilter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp) and c:IsPreviousControler(1-tp)
end
function s.zcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.zfilter,1,nil,tp)
end
function s.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
		+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	local dis=Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	Duel.SetTargetParam(dis)
end
function s.zop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--Disable the chosen zone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(function(e) return e:GetLabel() end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	c:RegisterEffect(e1)
end