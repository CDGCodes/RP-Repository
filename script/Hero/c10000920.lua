-- Elemental HERO Gusting Avian
local s, id = GetID()

function s.initial_effect(c)
	-- Always treated as "Elemental HERO Avian"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(21844576)  -- Code of "Elemental HERO Avian"
	c:RegisterEffect(e1)

	-- Add "Fusion" Spell or any "Hero" card from Deck to hand when summoned
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1, id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	local e3 = e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	-- Special Summon from hand or Graveyard
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e4:SetCountLimit(1, id+100)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)

	-- Restrict Special Summoning after this card's summon
	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e5:SetCondition(s.sscon)
	e5:SetValue(s.splimit)
	c:RegisterEffect(e5)
end

-- Add "Fusion" Spell or any "Hero" card from Deck to hand when summoned
function s.thfilter(c)
	return c:IsAbleToHand() and ((c:IsType(TYPE_SPELL) and c:IsSetCard(0x46)) or (c:IsType(TYPE_MONSTER + TYPE_SPELL + TYPE_TRAP) and c:IsSetCard(0x8)))
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

-- Special Summon from hand or Graveyard
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(s.spcfilter, tp, LOCATION_HAND, 0, 1, e:GetHandler())
	end
	Duel.DiscardHand(tp, s.spcfilter, 1, 1, REASON_COST + REASON_DISCARD, e:GetHandler())
end

function s.spcfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end

-- Restrict Special Summoning after this card's summon
function s.sscon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetSummonType() == SUMMON_TYPE_SPECIAL + 1
end

function s.splimit(e, se, sp, st)
	return st ~= tp
end
