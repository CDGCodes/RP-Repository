--Duelist Armaments - Hammer
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
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id, 0))
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Add card to hand
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_TOHAND)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_ONFIELD)
	e9:SetCountLimit(1, {id, 1})
	e9:SetCost(s.addcost)
	e9:SetCondition(s.addcon)
	e9:SetTarget(s.addtg)
	e9:SetOperation(s.addop)
	c:RegisterEffect(e9)
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
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if c:IsRace(RACE_ILLUSION) and c:IsLevel(2) then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1000, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) then
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

function s.addcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return (c:GetEquipTarget() or c:IsType(TYPE_EFFECT)) and c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c, REASON_COST)
end
function s.addcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_SZONE) and c:IsType(TYPE_EQUIP)) or (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT))
end
function s.addfilter(c)
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0xFEDC) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.addop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
