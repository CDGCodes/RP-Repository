--Dark Magician Girl the Ebon Sorceress
local s, id=GetID()
function s.initial_effect(c)
	--Become Dark Magician Girl
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(38033121)
	c:RegisterEffect(e1)
	--Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1, {id, 0})
	e3:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_GOLD_SARC_OF_LIGHT), 0, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	--Search on destruction
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1, {id, 1})
	e4:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_GRAVE) end)
	e4:SetTarget(s.srchtg)
	e4:SetOperation(s.srchop)
	c:RegisterEffect(e4)
end

s.listed_names={CARD_GOLD_CARD_OF_LIGHT, 38033121}

function s.sumtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, 0)
end
function s.sumop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
	end
end

function s.srchfilter(c)
	return (c:ListsCode(CARD_GOLD_SARC_OF_LIGHT) or c:IsCode(CARD_GOLD_SARC_OF_LIGHT)) and c:IsAbleToHand()
end
function s.srchtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.srchfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.srchop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCards(tp, s.srchfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end
