-- Elemental HERO Blazing Burstinatrix
local s, id = GetID()

function s.initial_effect(c)
	-- Always treated as "Elemental HERO Burstinatrix"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(58932615)  -- Code of "Elemental HERO Burstinatrix"
	c:RegisterEffect(e1)

	-- Special Summon from hand or GY when a "HERO" monster you control is destroyed
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.spSummonCondition)
	e2:SetTarget(s.spSummonTarget)
	e2:SetOperation(s.spSummonOperation)
	c:RegisterEffect(e2)

	-- Shuffle into the Deck when this card leaves the field
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.shuffleOperation)
	c:RegisterEffect(e3)

	-- Add a "Polymerization" Spell, "Fusion" Spell, or "HERO" monster from GY to hand upon Summon
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1, id + 100)
	e4:SetTarget(s.addToHandTarget)
	e4:SetOperation(s.addToHandOperation)
	c:RegisterEffect(e4)
end

-- Always treat this card as "Elemental HERO Burstinatrix" in hand, deck, and graveyard
function s.alwaysBurstinatrix(e, c)
	return c:IsCode(58932615)  -- Code of "Elemental HERO Burstinatrix"
end

-- Utility functions
function s.isHeroMonster(c)
	return c:IsFaceup() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end

function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
	local destroyed = eg:GetFirst()
	return destroyed and destroyed:IsControler(tp) and destroyed:IsType(TYPE_MONSTER) and destroyed:IsSetCard(0x8)
end

function s.spSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND + LOCATION_GRAVE)
end

function s.spSummonOperation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end

function s.shuffleOperation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsLocation(LOCATION_ONFIELD + LOCATION_GRAVE) then
		Duel.SendtoDeck(c, nil, -1, REASON_EFFECT)
	end
end

function s.addToHandTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.addToHandFilter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.addToHandOperation(e, tp, eg, ep, ev, re, r, rp)
	-- Select and add a "Polymerization" Spell, "Fusion" Spell, or "HERO" monster from GY to hand
	local g = Duel.SelectMatchingCard(tp, s.addToHandFilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
	end
end

function s.addToHandFilter(c)
	return c:IsType(TYPE_SPELL) and (c:IsCode(24094653) or c:IsCode(41482598) or c:IsSetCard(0x1f))
		or (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8))
end