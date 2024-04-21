-- Elemental HERO Hydraulic Bubbleman
local s, id = GetID()

function s.initial_effect(c)
    -- Always treated as "Elemental HERO Bubbleman"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(79979666)  -- Code of "Elemental HERO Bubbleman"
    c:RegisterEffect(e1)

    -- Special Summon from hand while controlling a face-up HERO monster (Quick Effect)
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

	-- Draw 2 cards as a Trigger effect when successfully summoned
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)  -- 'O' stands for optional
	e3:SetCode(EVENT_SUMMON_SUCCESS)  -- Activates on Normal Summon
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1, id + 100)
	e3:SetTarget(s.drawTarget)
	e3:SetOperation(s.drawOperation)
	c:RegisterEffect(e3)

	-- Optionally, you can add triggers for Special Summon as well
	local e4 = e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)  -- Activates on Special Summon
	c:RegisterEffect(e4)

    -- Draw 1 card and potentially Special Summon the target HERO when sent to GY as Fusion or Tribute material
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_DRAW + CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetCountLimit(1, id + 200)
    e5:SetCondition(s.materialCondition)
    e5:SetTarget(s.materialTarget)
    e5:SetOperation(s.materialOperation)
    c:RegisterEffect(e5)
end

-- Special Summon condition
function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.isHeroMonster, tp, LOCATION_MZONE, 0, 1, nil)
end

-- Special Summon target
function s.spSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
               and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end

-- Special Summon operation
function s.spSummonOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.drawTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 2)  -- Check if the player can draw 2 cards
    end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

function s.drawOperation(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Draw(p, 2, REASON_EFFECT)
end

-- Material condition adjusted for Fusion Summon only
function s.materialCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return rc and rc:IsType(TYPE_FUSION) and rc:IsSetCard(0x8)  -- Check if the reason card is a Fusion Monster from HERO archetype
end


-- Material target
function s.materialTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsPlayerCanDraw(tp, 1)
    end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

-- Material operation
function s.materialOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    if rc and (rc:IsSetCard(0x8) or rc:IsSetCard(0x1f)) and rc:IsType(TYPE_MONSTER) then
        Duel.Draw(tp, 1, REASON_EFFECT)
        local drawnCard = Duel.GetOperatedGroup():GetFirst()
        if drawnCard and drawnCard:IsLocation(LOCATION_HAND) and drawnCard:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.SpecialSummon(drawnCard, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

-- Helper function to determine HERO monsters
function s.isHeroMonster(c)
    return c:IsFaceup() and (c:IsSetCard(0x6008) or c:IsSetCard(0x8)) and c:IsType(TYPE_MONSTER)
end
