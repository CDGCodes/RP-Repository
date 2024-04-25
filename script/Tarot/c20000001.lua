--Tarot - I - The Magician
local s,id=GetID()
function c20000001.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)

	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp) and Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsSummonableCard,tp,LOCATION_DECK,0,1,nil)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_EHERO_BLAZEMAN) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummon(tp) or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(1-tp)
	local g=Duel.GetMatchingGroup(Card.IsSummonableCard,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local spcard=nil
	for tc in g:Iter() do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
	end
	if seq==-1 then
		Duel.ConfirmDecktop(tp,dcount)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		return
	end
	Duel.ConfirmDecktop(tp,dcount-seq)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and lv~=spcard:GetLevel()
		and spcard:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.DisableShuffleCheck()
		if dcount-seq==1 then Duel.SendtoHand(spcard,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,spcard)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) or #hg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local dis=hg:Select(1-tp,2,2,nil)
	Duel.Remove(dis,POS_FACEUP,REASON_EFFECT,PLAYER_NONE,1-tp)
	Duel.ShuffleHand(1-tp)
		end
	else
		Duel.DiscardDeck(tp,dcount-seq,REASON_EFFECT|REASON_EXCAVATE)
	Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)
	end
end