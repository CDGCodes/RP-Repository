--Duelist Armaments - Black Armor
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SPELL), 2, 3, nil, nil, nil, nil, false, s.xyzcheck)
	--c:SetSPSummonOnce(id)
    --Equip card on field
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e0:SetTarget(s.xeqtgt)
	e0:SetOperation(s.xeqop)
	c:RegisterEffect(e0)
	--Target and destroy, or attach if Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, {id, 0})
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.desaltcost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Equip card from grave
	--local e2=Effect.CreateEffect(c)
    --e2:SetDescription(aux.Stringid(id,2))
	--e2:SetCategory(CATEGORY_EQUIP)
	--e2:SetType(EFFECT_TYPE_IGNITION)
	--e2:SetCode(EVENT_FREE_CHAIN)
	--e2:SetRange(LOCATION_MZONE)
	--e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e2:SetCountLimit(1, {id, 0})
	--e2:SetCondition(s.geqcon)
	--e2:SetCost(s.desaltcost)
	--e2:SetTarget(s.geqtgt)
	--e2:SetOperation(s.geqop)
	--c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e2)
    --Gains ATK equal to ATK of equipped monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end

function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.xyzfilter(c,xyz,tp)
	return c:IsCode(200001369)
end
function s.xyzcheck(g,tp,xyz)
	return g:IsExists(s.xyzfilter,1,nil,xyz,tp)
end

function s.xeqfilter(c, e, tp)
	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 and c:GetLocation()==LOCATION_MZONE then return false end
	if c==e:GetHandler() or not c:IsFaceup() then return false end
	if c:GetEquipTarget() and c:GetEquipTarget()==e:GetHandler() then return false end
    if c:IsControler(1-tp) and not c:IsAbleToChangeControler() then return false end
	return (c:CheckEquipTarget(e:GetHandler()) or c:IsType(TYPE_MONSTER)) and c:CheckUniqueOnField(tp)
end
function s.xeqtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return true end
	if chk==0 then return Duel.IsExistingTarget(s.xeqfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, e, tp) end
	local sg=Duel.SelectTarget(tp, s.xeqfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, sg, 1, 0, 0)
end
function s.xeqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsType(TYPE_EQUIP) and tc:IsControler(1-tp) then
			Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
		end
		c:EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end

function s.ovtgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(Card.IsSpellTrap, tp, LOCATION_HAND+LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
end
function s.ovop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap, tp, LOCATION_HAND+LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
		local tc=g:Select(tp, 1, 1, nil)
		tc:GetFirst():CancelToGrave()
		Duel.Overlay(c, tc, true)
		if tc:GetFirst():GetEquipTarget() then
			Duel.Equip(tp, tc:GetFirst(), nil)
		end
	end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.True,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.True,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end --~=0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsSpellTrap() and not tc:IsImmuneToEffect(e) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		--Duel.Overlay(c, tc, true)
	--end
end
function s.cfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.desaltcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
    if chk==0 then return c:GetEquipGroup():IsExists(s.cfilter, 1, nil) or c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
	if c:CheckRemoveOverlayCard(tp, 1, REASON_COST) then
		if c:GetEquipGroup():IsExists(s.cfilter, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=c:GetEquipGroup():FilterSelect(tp,s.cfilter,1,1,nil)
			Duel.SendtoGrave(g,REASON_COST)
			return
		else
			c:RemoveOverlayCard(tp,1,1,REASON_COST)
			return
		end
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,s.cfilter,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
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
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)
end