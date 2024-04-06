--Duelist Armaments - Dagger
local s, id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--ATK/DEF up (Equip)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 0))
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Return to hand
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1, id, 0)
	e5:SetCost(s.rtcost)
	e5:SetTarget(s.rttg)
	e5:SetOperation(s.rtop)
	c:RegisterEffect(e5)
	--Copy Equip effects as monster
	local e6=e2:Clone()
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.effcon)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.effcon)
	c:RegisterEffect(e7)
	--Allow direct attacks
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(1)
	e8:SetCondition(s.dircon)
	c:RegisterEffect(e8)
	--Negate activated effect
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_CHAINING)
	e9:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e9:SetCountLimit(1, id, 1)
	e9:SetRange(LOCATION_ONFIELD)
	e9:SetCost(s.negcost)
	e9:SetCondition(s.negcon)
	e9:SetTarget(s.negtgt)
	e9:SetOperation(s.negop)
	c:RegisterEffect(e9)
end

function s.spcstfilter(c)
	return c:IsSpell() and c:IsDiscardable()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcstfilter, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.DiscardHand(tp, s.spcstfilter, 1, 1, REASON_COST|REASON_DISCARD)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if se:GetHandler():IsSpell() then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL+TYPE_TRAPMONSTER)
		Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id, 1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end

function s.rtfilter(c, e)
	return c:IsSpell() and c:IsAbleToRemoveAsCost() and c~=e:GetHandler()
end
function s.rtcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, s.rtfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, e)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.rttg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end
function s.rtop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, c)
	end
end

function s.effcon(e)
	return e:GetHandler():IsType(TYPE_EFFECT)
end
function s.dircon(e)
	return e:GetHandler():IsAttackPos() and s.effcon
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return (c:GetEquipTarget() or c:IsType(TYPE_EFFECT)) and c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c, REASON_COST)
end
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	return (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()) or (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT))
end
function s.negtgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg, REASON_EFFECT)
	end
	e:GetHandler():RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end
