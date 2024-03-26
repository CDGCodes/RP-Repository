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
	--Reduce ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0, LOCATION_MZONE)
	e3:SetValue(s.redval)
	c:RegisterEffect(e3)
	--Search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1, id)
	e4:SetTarget(s.schtgt)
	e4:SetOperation(s.schop)
	c:RegisterEffect(e4)
	--Make monster into Evil HERO
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 0))
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1, {id, 1})
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.ehtgt)
	e5:SetOperation(s.ehop)
	c:RegisterEffect(e5)
	--Fusion
	local e6=Fusion.CreateSummonEff(c, aux.FilterBoolFunction(Card.IsSetCard, 0x8), Fusion.OnFieldMat, s.fusxtra)
	e6:SetCountLimit(1, {id, 2})
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e6)
end
s.listed_names={CARD_DARK_FUSION}

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
	return c:IsSetCard(0x8, fc, sumtype, tp) and (c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) or c:IsType(TYPE_NORMAL, tc, sumtype, tp))
end

function s.redval(e, c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard, e:GetHandler():GetControler(), LOCATION_GRAVE+LOCATION_REMOVED, 0, nil, 0x8)*-200
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
	local c=e:GetHandler()
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
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SUPREME_CASTLE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(1, 0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2, tp)
	end
end

function s.fusxtra(e, tp, mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup), tp, 0, LOCATION_ONFIELD, nil)
end
