--Duelist Armaments - Violet Armor
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c, true, true, s.ffilter2, 1, s.ffilter, 2)
	c:SetSPSummonOnce(id)
    --Equip card on field
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e0:SetTarget(s.feqtgt)
	e0:SetOperation(s.feqop)
	c:RegisterEffect(e0)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e0)
    --Negate and Destroy/Equip
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, {id, 0})
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtgt)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e1)
    --Equip card from grave
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, {id, 0})
	e2:SetCondition(s.geqcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.geqtgt)
	e2:SetOperation(s.geqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e2)
    --Gains ATK equal to ATK of equipped monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Return to Extra Deck is it leaves the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(function(e)return e:GetHandler():IsFaceup()end)
	e4:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e4)
end

function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.ffilter(c, fc, sumtype, tp)
	return c:IsType(TYPE_SPELL,fc,sumtype,tp) and c:IsOnField()
end
function s.ffilter2(c, fc, sumtype, tp)
    return c:IsCode(200001369) and c:IsOnField()
end

function s.feqfilter(c, e, tp)
	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 and c:GetLocation()==LOCATION_MZONE then return false end
	if c==e:GetHandler() or not c:IsFaceup() then return false end
	if c:GetEquipTarget() and c:GetEquipTarget()==e:GetHandler() then return false end
    if c:IsControler(1-tp) and not c:IsAbleToChangeControler() then return false end
	return (c:CheckEquipTarget(e:GetHandler()) or c:IsType(TYPE_MONSTER)) and c:CheckUniqueOnField(tp)
end
function s.feqtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return true end
	if chk==0 then return Duel.IsExistingTarget(s.feqfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, e, tp) end
	local sg=Duel.SelectTarget(tp, s.feqfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, sg, 1, 0, 0)
end
function s.feqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsType(TYPE_EQUIP) and tc:IsControler(1-tp) then
			Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
		end
		c:EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if re:GetHandlerPlayer()==tp then return false end
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcostfilter(c)
	return c:IsSpell() and c:GetEquipTarget() and c:IsAbleToGraveAsCost()
end
function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter, tp, LOCATION_ONFIELD, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.GetMatchingGroup(s.negcostfilter, tp, LOCATION_ONFIELD, 0, nil)
	local tc=g:Select(tp, 1, 1, nil)
	Duel.SendtoGrave(tc, REASON_COST)
end
function s.negtgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
	if (rc:IsMonster() or rc:IsType(TYPE_EQUIP)) and rc:IsAbleToChangeControler() and rc:IsLocation(LOCATION_ONFIELD) then
		Duel.SetPossibleOperationInfo(0, CATEGORY_EQUIP, rc, 1, 0, 0)
	end
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		if (rc:IsMonster() or rc:IsType(TYPE_EQUIP)) and rc:IsAbleToChangeControler() and rc:IsOnField() and rc:CheckUniqueOnField(tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
			if rc:IsType(TYPE_EQUIP) then
				Duel.MoveToField(rc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
			end
			e:GetHandler():EquipByEffectAndLimitRegister(e, tp, rc, id)
		else
			Duel.Destroy(eg, REASON_EFFECT)
		end
	end
end

function s.geqcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
end
function s.gfeqfilter(c, sc)
	if c:IsType(TYPE_EQUIP) then
    	return sc:CheckEquipTarget(c)
	end
	return true
end
function s.geqfilter(c, e, tp)
	if not c:CheckUniqueOnField(tp) then return false end
	if c:IsType(TYPE_EQUIP) then return Duel.IsExistingMatchingCard(s.gfeqfilter, tp, LOCATION_MZONE, 0, 1, nil, c) end
	return c:IsType(TYPE_MONSTER)
end
function s.geqtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return true end
	if chk==0 then return Duel.IsExistingTarget(s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp) end
	local sg=Duel.SelectTarget(tp, s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, sq, 1, 0, 0)
end
function s.geqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local g=Duel.GetMatchingGroup(s.gfeqfilter, tp, LOCATION_MZONE, 0, nil, tc)
        local sc=g:Select(tp, 1, 1, nil)
		sc:GetFirst():EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end

function s.atkvalfilter(c)
	return c:IsOriginalType(TYPE_MONSTER)
end
function s.atkval(e, c)
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)/2
end