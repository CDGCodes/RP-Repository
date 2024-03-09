--Diamond Crystal Wing Synchro Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 1)
	--Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.imfilter)
	c:RegisterEffect(e1)
	--Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Revive materials
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Negate
end

function s.imcon(e)
	local c=e:GetHandler()
	local bc=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	return bc and ((bc==c and tc:IsLevelAbove(5)) or (tc==c and bc:IsLevelAbove(5)))
end
function s.imfilter(e, te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:GetBattleTarget()
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c, e, tp, sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)
		and ct>0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>=ct and mg:FilterCount(s.spfilter, nil, e, tp, c)==ct end
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mg, ct, 0, 0)
end
function spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	local mg=Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToEffect, nil, e)
	if #g<#mg then return end
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<#g then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
