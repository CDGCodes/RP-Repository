-- Caldor, Nightmare Knight
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
			
	-- Draw Effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	
end

--mana dragon's Spell trap effect
function s.cfilter(c,tp)
	return c:IsSetCard(0x1A2B) and (c:GetPreviousTypeOnField()&TYPE_SPELL==TYPE_SPELL or c:GetPreviousTypeOnField()&TYPE_TRAP==TYPE_TRAP)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.setfilter(c)
	return c:IsSetCard(0x1A2B) and c:IsSpellTrap() and not c:IsType(TYPE_FIELD) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSSetable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			--Set 1 of your spells/traps, that is banished or in GY
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end
	end
end
--Draw Function
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and c:IsAbleToDeck() end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drfilter(c)
	return c:IsSetCard(0x1A2B) and c:IsSpellTrap() and c:IsAbleToDeck()
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tdg=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.HintSelection(tdg,true)
	end
	
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local tdg=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoDeck(tdg,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT) 
	end
end