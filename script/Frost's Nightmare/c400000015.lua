-- Nightmare Droid
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--if used for a fusion
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.fscon)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	
	--equip effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)

end


function s.spcstfilter(c)
	return c:IsSpell() 
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spchkfilter, tp, LOCATION_HAND, 0, 1, nil, e) end
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1A2B, 0x21, 500, 1000, 4, RACE_FIEND, ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0x1A2B, 0x21, 500, 1000, 4, RACE_FIEND, ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL+TYPE_TRAPMONSTER+TYPE_MONSTER)
		Duel.SpecialSummon(c, 0, tp, tp, true, false, POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end
end

--if used for a fusion
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_FUSION)==REASON_FUSION 
		and c:IsLocation(LOCATION_GRAVE) and c:IsFaceup() and c:GetReasonCard():IsRace(RACE_FIEND)
end
function s.fsfilter(c,e,tp)
	return c:IsSetCard(0x1A2B) 
end
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.fsfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	--local g=Duel.SelectTarget(tp,s.fsfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
--	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local fc=c:GetReasonCard()
	if fc then
		local e1=Effect.CreateEffect(e:GetHandler())
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_UPDATE_ATTACK)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	    e1:SetValue(500)
		fc:RegisterEffect(e1)
		
	end
end

function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not tc or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
		
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	--untargetable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_DISCARD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_ADD_TYPE)
	e6:SetValue(TYPE_EFFECT)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e6,true)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqfilter,1,nil,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if not re then return false end
	return re:IsActiveType(TYPE_MONSTER)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3205)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.eftg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end