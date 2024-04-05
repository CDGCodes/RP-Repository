-- Gildra, The Daughter Of Nigtmares
local s,id=GetID()
function s.initial_effect(c)
		--on normal summon target 1 "nightmare" spell/trap in gy add to hand 
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
		c:RegisterEffect(e1)
	
		-- Draw Effect
	
		local c = e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetCategory(CATEGORY_DRAW)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
			e2:SetRange(LOCATION_MZONE)
			e2:SetProperty(EFFECT_FLAG_OATH)
			e2:SetCode(EVENT_EVENT_FREE_CHAIN)
			e2:SetCountLimit(1)
			e2:SetTarget(s.drtg)
			e2:SetOperation(s.drop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_LEAVE+RESET_TEMP_REMOVE+RESET_TURN_SET)+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
	
end

function s.thfilter(c)
	return c:IsSetCard(0x1A2B) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Draw Function
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end