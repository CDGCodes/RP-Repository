-- Nightmare gene
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x1A2B)))
	
	
	--add to hand
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_TO_HAND)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return (r&REASON_EFFECT)~=0
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	Duel.DiscardHand(tp,aux.True,e:GetHandler(),1,REASON_EFFECT+REASON_DISCARD)

end