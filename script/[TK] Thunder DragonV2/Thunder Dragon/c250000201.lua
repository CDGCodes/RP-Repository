--Thunder Dragon ThunderStorm
local s,id=GetID()
function c250000201.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,ft,tp)
	return c:IsSetCard(0x11c)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,ft,tp) end
	local ct=Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,ct,false,nil,nil,ft,tp)
	ct=Duel.Release(rg,REASON_COST)
	e:SetLabel(ct)
end
function s.rfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local ct=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
function s.filter(c)
	return c:IsSpell() and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x11c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then ct=ft end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local dg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,ct,ct,nil,e,tp)
	if #dg>0 then
		Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)
	end
end