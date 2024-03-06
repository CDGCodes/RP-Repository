--Black Rose Magician Girl
local s,id=GetID()
function s.initial_effect(c)
	--contact fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,38033121,73580471)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
