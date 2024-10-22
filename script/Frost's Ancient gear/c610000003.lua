--Ancient Gear Double Bite Hound Dog
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,42878636,2)
	--actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52846880,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	e5:SetCondition(s.damcon)
	c:RegisterEffect(e5)
	
    --Activate
    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCountLimit(1,{id,2})
    e6:SetCost(s.cost)
    e6:SetTarget(s.target)
    e6:SetOperation(s.activate)
    c:RegisterEffect(e6)

end
s.material_setcode=0x7
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.ctfilter(c,tp)
	return c:IsControler(1-tp) and c:GetCounter(0x1102)==0
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.ctfilter,1,nil,tp) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.ctfilter,nil,tp)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1102,1)
		tc=g:GetNext()
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	local g=Group.CreateGroup()
	if tc:GetCounter(0x1102)>0 then
		g:AddCard(tc)
	end
	if bc:GetCounter(0x1102)>0 then
		g:AddCard(bc)
	end
	g:KeepAlive()
	e:SetLabelObject(g)
	return #g>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g and g:IsExists(Card.IsDestructable,1,nil) end
	g:KeepAlive()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desfilter(c)
	return c:IsRelateToBattle() and c:GetCounter(0x1102)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.desfilter,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() end
    Duel.SendtoDeck(c, nil, 0, REASON_COST)
end
function s.mgfilter(c,e,tp,fusc,mg)
    return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
        and (c:GetReason()&0x40008)==0x40008 and c:GetReasonCard()==fusc
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE+65536)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetMaterial()
    if chk==0 then
        local ct=#g
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if e:GetHandler():GetSequence()<5 then ft=ft+1 end
        return ct>0 and ft>=ct and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
            and g:FilterCount(s.mgfilter,nil,e,tp,e:GetHandler(),g)==ct
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    local g=e:GetHandler():GetMaterial()
    local ct=#g
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
        and g:FilterCount(s.mgfilter,nil,e,tp,e:GetHandler(),g)==ct then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

 
 
 