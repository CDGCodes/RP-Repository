-- Nightmare essence
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end


function s.spcstfilter(c)
	return c:IsSpell() 
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spchkfilter, tp, LOCATION_HAND, 0, 1, nil, e) end
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1A2B, 0x21, 500, 1000, 4, RACE_FIEND, ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if se:GetHandler():IsSpell() then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1A2B, 0x21, 500, 1000, 4, RACE_FIEND, ATTRIBUTE_DARK) then
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
