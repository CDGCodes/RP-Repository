--Duelist Armaments - Scythe
local s, id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1, 0, id)
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
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Can attack all monsters
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_EQUIP)
	e9:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e9:SetValue(s.spval)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetRange(LOCATION_ONFIELD)
	e10:SetCondition(s.effcon)
	c:RegisterEffect(e10)
end

function s.spchkfilter(c, e)
	return c:IsSpell() and c:IsDiscardable() and c~=e:GetHandler()
end
function s.spcstfilter(c)
	return c:IsSpell() and c:IsDiscardable()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spchkfilter, tp, LOCATION_HAND, 0, 1, nil, e) end
	Duel.DiscardHand(tp, s.spcstfilter, 1, 1, REASON_COST|REASON_DISCARD)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1000, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if c:IsRace(RACE_ILLUSION) and c:IsLevel(2) then return false end
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

function s.effcon(e)
	return e:GetHandler():IsType(TYPE_EFFECT)
end
function s.dircon(e)
	return e:GetHandler():IsAttackPos() and s.effcon(e)
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()) or (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT))
end
function s.destgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local count=Duel.GetMatchingGroupCount(Card.IsType, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, nil, TYPE_SPELL)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, count, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g, REASON_EFFECT)
end

function s.spfilter(c, e)
	return c:IsFaceup() and c:IsSpell() and c:IsControler(e:GetHandler():GetControler())
end
function s.spval(e)
	local tp=e:GetHandler():GetControler()
	--Debug.Message(Duel.GetMatchingGroupCount(s.spfilter, tp, LOCATION_ONFIELD, 0, nil, e))
	return math.max(Duel.GetMatchingGroupCount(s.spfilter, tp, LOCATION_ONFIELD, 0, nil, e)-1, 0)
end