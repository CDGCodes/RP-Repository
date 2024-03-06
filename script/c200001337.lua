--Black Hole Dragon
--updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,aux.FilterSummonCode(CARD_STARDUST_DRAGON),aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),0)
	c:SetStatus(STATUS_NO_LEVEL,true)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	--multi destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.mtcon)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
s.material={CARD_STARDUST_DRAGON}
s.listed_names={CARD_STARDUST_DRAGON}
function s.indct(e,re,r,rp)
	if (r)~=0 then
		return 1
	else return 0 end
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	local tt=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	local gt=g:FilterCount(Card.IsType,nil,TYPE_MONSTER)
	local ct=gt-tt
	Duel.ShuffleDeck(tp)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local f=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		local sg=f:Select(tp,ct,math.min(ct,#g),nil)
		local dmg = Duel.Destroy(sg,REASON_EFFECT)
		if dmg>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(dmg*500)
			c:RegisterEffect(e1)
		end
	end
end
