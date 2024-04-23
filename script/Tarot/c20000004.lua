--Tarot - IV - The Emperor
local s,id=GetID()
function c20000004.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<7 then ft=ft+1 end
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		return ft>0 and g:GetClassCount(Card.GetCode)>=5
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=5 then
		local cg=Group.CreateGroup()
		for i=1,5 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local sg=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
			cg:Merge(sg)
		end
		Duel.ConfirmCards(1-tp,cg)
		Duel.ShuffleDeck(tp)
		local tg=cg:Select(1-tp,2,2,nil)
		local tc=tg:Select(1-tp,2,2,nil)
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			cg:RemoveCard(tc)
		end
	end
function s.spfilter1(c)
	return c:IsSetCard(0x13a) and c:IsMonster()
end