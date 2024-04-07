-- Elemental HERO Hydraulic Bubbleman
local s, id = GetID()

function s.initial_effect(c)
	-- Always treated as "Elemental HERO Bubbleman"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(79979666)  -- Code of "Elemental HERO Bubbleman"
	c:RegisterEffect(e1)

	-- Special Summon from hand while controlling a face-up HERO monster (Main Phase)
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1, id)
	e2:SetCondition(s.spSummonCondition)
	e2:SetTarget(s.spSummonTarget)
	e2:SetOperation(s.spSummonOperation)
	c:RegisterEffect(e2)

	-- Draw 2 cards when this card is Special Summoned
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1, id + 100)
	e3:SetTarget(s.drawTarget)
	e3:SetOperation(s.drawOperation)
	c:RegisterEffect(e3)

	-- Draw 1 card and potentially Special Summon the target HERO when sent to GY as Fusion or Tribute material
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 2))
	e4:SetCategory(CATEGORY_DRAW + CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1, id + 200)
	e4:SetCondition(s.materialCondition)
	e4:SetTarget(s.materialTarget)
	e4:SetOperation(s.materialOperation)
	c:RegisterEffect(e4)
end

-- Utility functions
function s.isHeroMonster(c)
	return c:IsFaceup() and (c:IsSetCard(0x8) or c:IsSetCard(0x1f)) and c:IsType(TYPE_MONSTER)
end

function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.isHeroMonster, tp, LOCATION_MZONE, 0, 1, nil)
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
	end
end

function s.drawTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.drawOperation(e, tp, eg, ep, ev, re, r, rp)
	local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
	Duel.Draw(p, 2, REASON_EFFECT)
end

function s.materialCondition(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local rc = c:GetReasonCard()
	return rc and (rc:IsSetCard(0x8) or rc:IsSetCard(0x1f)) and rc:IsType(TYPE_MONSTER)
end

function s.materialTarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)  -- Allow drawing 1 card
end
function s.materialOperation(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local rc = c:GetReasonCard()
	if rc and (rc:IsSetCard(0x8) or rc:IsSetCard(0x1f)) and rc:IsType(TYPE_MONSTER) then
		-- Draw 1 card
		Duel.Draw(tp, 1, REASON_EFFECT)
		local drawnCard = Duel.GetOperatedGroup():GetFirst()
		-- Check if the drawn card is a valid HERO monster and can be Special Summoned from the hand
		if drawnCard and drawnCard:IsLocation(LOCATION_HAND) and drawnCard:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
			-- Special Summon the drawn HERO monster to the field
			Duel.SpecialSummon(drawnCard, 0, tp, tp, false, false, POS_FACEUP)
		end
	end
end