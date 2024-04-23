--Duelist Armaments - White Armor
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsType,TYPE_SPELL), 1, 99, s.syncex, nil, nil, s.syncheck)
	c:SetSPSummonOnce(id)
    --Add Equip on Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetTarget(s.eqtgt)
	e0:SetOperation(s.eqop)
	c:RegisterEffect(e0)
    --Banish card, copy Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, {id, 0})
	e1:SetHintTiming(TIMING_DRAW_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.bancost)
	e1:SetTarget(s.bantgt)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    --Equip card from grave
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, {id, 1})
	e2:SetCondition(s.geqcon)
	e2:SetTarget(s.geqtgt)
	e2:SetOperation(s.geqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e2)
    --Gains ATK equal to ATK of equipped monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Return to Extra Deck is it leaves the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(function(e)return e:GetHandler():IsFaceup()end)
	e4:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e4)
end

function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.eqfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.eqtgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.eqfilter), tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end

function s.bancostfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.bancost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bancostfilter, tp, LOCATION_ONFIELD|LOCATION_HAND, 0, 2, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.GetMatchingGroup(s.bancostfilter, tp, LOCATION_ONFIELD|LOCATION_HAND, 0, nil)
	local tc=g:Select(tp, 2, 2, nil)
	Duel.SendtoGrave(tc, REASON_COST)
end
function s.banfilter(c)
	return c:IsAbleToRemove()
end
function s.bantgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingTarget(s.banfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp, s.banfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil)
	local tc=g:GetFirst()
	if (tc:IsNormalSpell() or tc:IsNormalTrap() or (tc:IsSpellTrap() and tc:IsType(TYPE_COUNTER+TYPE_QUICKPLAY))) and tc:CheckActivateEffect(false, true, false) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		local te, ceg, cep, cev, cre, cr, crp=tc:CheckActivateEffect(false, true, true)
		Duel.ClearTargetCard()
		g:GetFirst():CreateEffectRelation(e)
		local tg=te:GetTarget()
		e:SetProperty(te:GetProperty())
		if tg then tg(e, tp, ceg, cep, cev, cre, cr, crp, 1) end
		e:SetLabelObject(te)
		Duel.ClearOperationInfo(0)
	end
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end
function s.banop(e, tp, eg, ep, ev, re, r, rp)
	if e:GetLabelObject() then
		local te=e:GetLabelObject()
		if te and te:GetHandler():IsRelateToEffect(e) then
			e:SetLabelObject(te:GetLabelObject())
			local op=te:GetOperation()
			if op then
				op(e, tp, eg, ep, ev, re, r, rp)
			end
			Duel.Remove(te:GetHandler(), POS_FACEUP, REASON_EFFECT)
		end
	else
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
	end
end

function s.syncex(c, scard, sumtype, tp)
    return c:IsType(TYPE_SPELL, scard, sumtype, tp)
end
function s.syncfilter(c)
    return c:IsCode(200001369)
end
function s.syncheck(g, sc, tp)
    return g:IsExists(s.syncfilter, 1, nil)
end

function s.geqcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
end
function s.gfeqfilter(c, sc)
    return sc:CheckEquipTarget(c)
end
function s.geqfilter(c, e, tp)
	if not c:CheckUniqueOnField(tp) then return false end
	if c:IsType(TYPE_EQUIP) then return Duel.IsExistingMatchingCard(s.gfeqfilter, tp, LOCATION_MZONE, 0, 1, nil, c) end
	return c:IsType(TYPE_MONSTER)
end
function s.geqtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return true end
	if chk==0 then return Duel.IsExistingTarget(s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp) end
	local sg=Duel.SelectTarget(tp, s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, sq, 1, 0, 0)
end
function s.geqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local g=Duel.GetMatchingGroup(s.gfeqfilter, tp, LOCATION_MZONE, 0, nil, tc)
        local sc=g:Select(tp, 1, 1, nil)
		sc:GetFirst():EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end

function s.atkvalfilter(c)
	return c:IsOriginalType(TYPE_MONSTER)
end
function s.atkval(e, c)
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)
end