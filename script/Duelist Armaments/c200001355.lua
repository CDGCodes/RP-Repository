 --Duelist Armaments - Gun
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
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.spgycon)
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
	--Destroy
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_DESTROY)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_ONFIELD)
	e9:SetCountLimit(1, id, 0)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetCost(s.descost)
	e9:SetCondition(s.descon)
	e9:SetTarget(s.destgt)
	e9:SetOperation(s.desop)
	c:RegisterEffect(e9)
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
function s.spgycon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE)>Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)
end

function s.effcon(e)
	return e:GetHandler():IsType(TYPE_EFFECT)
end
function s.dircon(e)
	return e:GetHandler():IsAttackPos() and s.effcon
end

function s.costfilter(c, e)
	local ec=e:GetHandler()
	if ec:GetEquipTarget() then
		if c==ec:GetEquipTarget() then return false end
	end
	return c:IsSpell() and c:IsAbleToGraveAsCost() and not c:IsRelateToEffect(e)
end
function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND+LOCATION_ONFIELD, 0, 1, nil, e) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND+LOCATION_ONFIELD, 0, 1, 1, nil, e)
	Duel.SendtoGrave(g, REASON_COST)
end
function s.descon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()) or (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT))
end
function s.destgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(aux.True, tp, 0, LOCATION_ONFIELD, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp, aux.True, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local loc = c:GetLocation()
	if tc then g:RemoveCard(tc) end
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) then
		if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			local g=Duel.GetMatchingGroup(aux.True, tp, 0, loc, nil)
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
			local sg=g:Select(tp, 1, 1, nil)
			Duel.HintSelection(sg)
			local gc=sg:GetFirst()
			Duel.Destroy(gc, REASON_EFFECT)
		end
	end
end
