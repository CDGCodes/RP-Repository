-- Elemental HERO Striking Sparkman
local s, id = GetID()
function s.initial_effect(c)
	-- Name becomes "Elemental HERO Sparkman"
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_ONFIELD + LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(20721928)  -- Code of "Elemental HERO Sparkman"
	c:RegisterEffect(e1)
	
	-- Destroy and search
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	-- Change to Defense Position
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	
	-- Gain ATK
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end

function s.thfilter(c)
	return c:IsSetCard(0x8) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount() > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end

function s.postg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsPosition(POS_ATTACK) end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsPosition, tp, 0, LOCATION_MZONE, 1, nil, POS_ATTACK) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
	local g = Duel.SelectTarget(tp, Card.IsPosition, tp, 0, LOCATION_MZONE, 1, 1,
	nil, POS_ATTACK)
	Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function s.posop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_ATTACK) then
		Duel.ChangePosition(tc, POS_FACEUP_DEFENSE)
	end
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
	local ac = Duel.GetAttacker()
	return ac:IsSetCard(0x8) and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsPosition(POS_DEFENSE)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local ac = Duel.GetAttacker()
	if ac:IsFaceup() and ac:IsSetCard(0x8) then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
		ac:RegisterEffect(e1)
	end
end