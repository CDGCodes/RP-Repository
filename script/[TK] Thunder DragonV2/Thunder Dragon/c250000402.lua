--Thunder DragonReclamation
local s,id=GetID()
function c250000402.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,extrafil=s.extrafil,location=LOCATION_HAND|LOCATION_GRAVE,extratg=s.extratg})
end
function s.ritualfil(c)
	return c:IsSetCard(0x11c) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel()
		and c:IsMonster() and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end