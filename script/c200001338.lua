--Black Rose Magician Girl
local s,id=GetID()
function s.initial_effect(c)
	--contact fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,38033121,73580471)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--gain atk
	--destroy monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.material={38033121,73580471}
s.listed_names={38033121,73580471}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function s.cfilter(c, tp)
	return c:IsReason(REASON_DESTROY) and c:IsCode(38033121)
end
function s.descon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.decop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.Destroy(tc,REASON_EFFECT)
end
