--Evil HERO Moonfall
local s, id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c, true, true, s.fusfilter, 2)
	--Fusion Restriction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, id)
	e2:SetTarget(s.schtgt)
	e2:SetOperation(s.schop)
	c:RegisterEffect(e2)
	--Make monster into Evil HERO
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1, {id, 1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.ehtgt)
	e3:SetOperation(s.ehop)
	c:RegisterEffect(e3)
	--Dark Fusion
end
s.listed_names={CARD_DARK_FUSION}

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
	return c:IsSetCard(0x8, fc, sumtype, tp) and (c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) or c:IsType(TYPE_NORMAL, tc, sumtype, tp))
end

function s.schfilter(c)
	return c:IsAbleToHand() and c:IsSpell() and (c:IsCode(CARD_DARK_FUSION) or c:ListsCode(CARD_DARK_FUSION))
end
function s.schtgt(e, tp, eg, ep, ev, re, r, rp)
	if chk==o then return Duel.IsExistingMatchingCard(s.schfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.schop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, s.schfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end

function s.ehfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x6008)
end
function s.ehtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.ehfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ehfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp, s.ehfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
end
function s.ehop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id, 2))
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetValue(0x6008)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
