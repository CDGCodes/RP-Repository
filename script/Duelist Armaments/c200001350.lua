--Duelist Armaments  - Dual Wield
local s, id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.spfilter(c, tp)
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_EQUIP) and Duel.IsPlayerCanSpecialSummonMonster(tp, c:GetCode(), 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT)
end
function s.eqfilter(c, ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if se:GetHandler():IsSpell() then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND, 0, 1, 1, nil, tp)
	local c=e:GetHandler()
	if #g>0 then
		local gc=g:GetFirst()
		gc:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL)
		Duel.SpecialSummonStep(gc, 0, tp, tp, true, false, POS_FACEUP)
		gc:AddMonsterAttributeComplete()
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_SET_BASE_ATTACK)
		e0:SetValue(1500)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		gc:RegisterEffect(e0, true)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_SET_BASE_DEFENSE)
		e1:SetValue(1000)
		gc:RegisterEffect(e1, true)
		local e2=e0:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_ILLUSION)
		gc:RegisterEffect(e2)
		local e3=e0:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(ATTRIBUTE_LIGHT)
		gc:RegisterEffect(e3)
		Duel.SpecialSummonComplete()
		if Duel.IsExistingMatchingCard(s.eqfilter, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND, 0, 1, nil, gc) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			local eg=Duel.SelectMatchingCard(tp, s.eqfilter, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND, 0, 1, 1, nil, gc)
			local egc=eg:GetFirst()
			Duel.Equip(tp, egc, gc)
		end
	end
	-- Spell Summon Restriction
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