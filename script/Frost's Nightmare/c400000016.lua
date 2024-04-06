-- Nightmare gene
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x1A2B)))
	local e0=Fusion.CreateSummonEff(c,aux.True,nil,s.fextra,s.extraop,nil,s.stage2,2,0,nil,nil,nil,nil,nil,s.extratg)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 	e0:SetProperty(EFFECT_FLAG_DELAY)
 	e0:SetCode(EVENT_TO_HAND)
 	e0:SetCountLimit(1, id)
 	e0:SetRange(LOCATION_HAND)
 	e0:SetCost(s.spcost)
 	c:RegisterEffect(e0)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsDiscardable),tp,LOCATION_HAND,0,nil)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsDiscardable(REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
end
function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(0x1A2B) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #rg>0 then
		Duel.SendtoGrave(rg,REASON_DISCARD+REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
