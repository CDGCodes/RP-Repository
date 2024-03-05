--Speed Spell - Power Bond
local s,id=GetID()
function s.initial_effect(c)
	--activate--
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),nil,nil,nil,nil,s.stage2)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	return tc and tc:GetCounter(0x91)>4
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	local ct=tc:GetCounter(0x91)/2
	if chk==0 then return tc and tc:IsCanRemoveCounter(tp,0x91,ct,REASON_COST) end	 
	tc:RemoveCounter(tp,0x91,ct,REASON_COST)	
end
function s.stage2(e,tc,tp,sg,chk)
	if chk~=1 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetBaseAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(tc:GetBaseAttack())
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(s.damop)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end
