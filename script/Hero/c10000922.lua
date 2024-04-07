-- Elemental HERO Crashing Clayman
local s, id = GetID()

function s.initial_effect(c)
	-- Always treated as "Elemental HERO Clayman"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(84327329)  -- Code of "Elemental HERO Clayman"
	c:RegisterEffect(e1)

	-- Special Summon from hand during attack declaration
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.spSummonCondition)
	e2:SetTarget(s.spSummonTarget)
	e2:SetOperation(s.spSummonOperation)
	c:RegisterEffect(e2)

	-- Restrict opponent from attacking "HERO" monsters, except "Elemental HERO Crashing Clayman"
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.battleTarget)
	c:RegisterEffect(e3)

	-- Change Battle Position and increase DEF
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_POSITION + CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1, id + 100)
	e4:SetCondition(s.positionChangeCondition)
	e4:SetTarget(s.positionChangeTarget)
	e4:SetOperation(s.positionChangeOperation)
	c:RegisterEffect(e4)
end

-- Utility functions
function s.isHeroMonster(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end

function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
	local atkTarget = Duel.GetAttackTarget()
	return atkTarget and atkTarget:IsControler(tp) and atkTarget:IsSetCard(0x8) and atkTarget:IsType(TYPE_MONSTER)
end

function s.spSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end

function s.spSummonOperation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
		local atkTarget = Duel.GetAttacker()
		if atkTarget and atkTarget:IsControler(1 - tp) then
			Duel.ChangeAttackTarget(c)
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-800)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			atkTarget:RegisterEffect(e1)
		end
	end
end

function s.positionChangeCondition(e, tp, eg, ep, ev, re, r, rp)
	return true  -- Activate the effect during any phase
end

function s.positionChangeTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsCanChangePosition()
	end
	Duel.SetOperationInfo(0, CATEGORY_POSITION, e:GetHandler(), 1, 0, 0)
end

function s.positionChangeOperation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		local pos = c:IsAttackPos() and POS_FACEUP_DEFENSE or POS_FACEUP_ATTACK
		Duel.ChangePosition(c, pos, pos)
		local g = Duel.GetMatchingGroup(s.isHeroMonster, tp, LOCATION_MZONE, 0, nil)
		if #g > 0 then
			for tc in aux.Next(g) do
				local e1 = Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_DEFENSE)
				e1:SetValue(1000)
				e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end

function s.battleTarget(e, c)
	return not c:IsCode(id) and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end
