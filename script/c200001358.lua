--Empowered Bamboo Sword
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--to deck
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.addcon)
	e4:SetTarget(s.addtgt)
	e4:SetOperation(s.addop)
	c:RegisterEffect(e4)
end

function s.filter(c)
	return c:IsSetCard(0x60) and c:IsFaceup()
end
function s.val(e, c)
	return Duel.GetMatchingGroupCount(s.filter, e:GetHandlerPlayer(), LOCATION_ONFIELD+LOCATION_GRAVE, 0, nil, nil)*1000
end

function s.addcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.shflfilter(c)
	return s.filter(c) and c:IsAbleToDeck()
end
function s.addtgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.shflfilter, tp, LOCATION_GRAVE, 0, nil, nil)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.addfilter(c)
	return c:IsSetCard(0x60) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.shflfilter, tp, LOCATION_GRAVE, 0, nil, nil)
	if #g>0 and Duel.SendtoDeck(g, nil, 0, REASON_EFFECT)>0 then
		local ge=Duel.GetMatchingGroup
		local ec=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #ec>0 then
			Duel.SendtoHand(ec, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, ec)
		end
	end
end
