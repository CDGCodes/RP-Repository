-- Elemental HERO Nightmare Necroshade
-- This card is always treated as "Elemental HERO Necroshade".

local s, id = GetID()

function s.initial_effect(c)
	-- Always treated as "Elemental HERO Necroshade"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(89252153)  -- Code of "Elemental HERO Necroshade"
	c:RegisterEffect(e1)

	-- Special Summon from hand by discarding another “HERO” monster
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1, id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Special Summon Level 7 or lower “HERO” non-Fusion Monster from hand or GY
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE + LOCATION_ONFIELD)
	e3:SetCountLimit(1, id + 100)  -- Use a different ID for this effect
	e3:SetCost(s.spsumcost)
	e3:SetTarget(s.spsumtg)
	e3:SetOperation(s.spsumop)
	c:RegisterEffect(e3)
end

-- Effect 1: Special Summon from hand by discarding another “HERO” monster
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.IsHero, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local g = Duel.SelectMatchingCard(tp, s.IsHero, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
		-- Apply a restriction so the summoned monster cannot attack this turn
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- Effect 2: Special Summon Level 7 or lower “HERO” non-Fusion Monster from hand or GY
function s.spsumcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.spsumfilter(c, e, tp)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spsumtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.spsumfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
end

function s.spsumop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.spsumfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		-- Apply a restriction so the summoned monster cannot attack this turn
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end
