--Prple, Chaos Emissary of Dark World
local s, id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
    --Cannot be destroyed by battle
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --Special Summon itself from GY
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetValue(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --Banish when leaves field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(3300)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e3:SetCondition(s.rcon)
    e3:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e3)
	--Special Summon on discard
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1, {id, 0})
	e4:SetCondition(s.sptcon)
	e4:SetTarget(s.spttg)
	e4:SetOperation(s.sptop)
	c:RegisterEffect(e4)
	--Discard 1 card
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id, 1})
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end

s.listed_series={0x6}
s.listed_names={id}

function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsLevelAbove(7) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)
	g:DeleteGroup()
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end

function s.sptcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and (r&0x4040)==0x4040
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x6) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	if tp==rp or tp~=e:GetLabel() or Duel.GetLocationCount(tp,LOCATION_MZONE)==1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	else
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
	end
end
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end

function s.disfilter(c) 
	return c:IsMonster() and c:IsSetCard(0x6) and c:IsDiscardable(REASON_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)>0 then
		local dc=Duel.GetOperatedGroup():GetFirst():GetCode()
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(dc)
		c:RegisterEffect(e1)
	end
end