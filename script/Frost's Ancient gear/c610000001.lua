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

 --equip
 local e1=Effect.CreateEffect(c)
 e1:SetCategory(CATEGORY_EQUIP)
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_MZONE)
 e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e1:SetCountLimit(1)
 e1:SetTarget(s.eqtg)
 e1:SetOperation(s.eqop)
 c:RegisterEffect(e1)
end
function s.eqfilter(c)
	return c:IsSetCard(0x7)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget(e)
	if not g:IsRelateToEffect(e) then return end
	if e:GetHandler():IsFaceup() then
		if not Duel.Equip(tp,g,e:GetHandler(),true) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(e:GetHandler())
		g:RegisterEffect(e1)
		--atkup
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(g:GetAttack()/2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
