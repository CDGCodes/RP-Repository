--Empowered Bamboo Sword
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtgt)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end

function s.filter(c)
	return c:IsSetCard(0x60) and c:IsFaceup()
end
function s.val(e, c)
	return Duel.GetMatchingGroupCount(s.filter, e:GetHandlerPlayer(), LOCATION_ONFIELD+LOCATION_GRAVE, 0, nil, nil)*1000
end

function s.addcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:GetEquipTarget()~=nil
end
function s.shflfilter(c)
	return s.filter(c) and c:IsAbleToDeck()
end
function s.addtgt(e, tp, eg, ep, ev, re, r, rp)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.shflfilter, tp, LOCATION_GRAVE, 0, nil, nil)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, g, tp, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_SEARCH, nil, 1, tp, LOCATION_DECK)
end
function s.addop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.shflfilter, tp, LOCATION_GRAVE, 0, nil, nil)
	if #g>0 and Duel.SendtoDeck(g, nil, 0, REASON_EFFECT)>0 then
		local ec=Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_DECK, 0, 1, 1, nil, 0x60)
		if #ec>0 then
			Duel.SendtoHand(ec, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, ec)
		end
	end
end
