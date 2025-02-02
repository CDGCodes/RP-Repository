--Duelist Armaments - Black Robe
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SPELL), 2, 2)
	c:SetSPSummonOnce(id)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_SINGLE)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.desaltcost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Equip card from grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1, id, EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.geqcon)
	e3:SetTarget(s.geqtgt)
	e3:SetOperation(s.geqop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e3)
	--Gains ATK equal to ATK of equipped monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end

function s.armfusfilter(c)
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.cfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.desaltcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
    if chk==0 then return c:GetEquipGroup():IsExists(s.cfilter, 1, nil) or c:CheckRemoveOverlayCard(tp, 1, REASON_COST) end
	if c:CheckRemoveOverlayCard(tp, 1, REASON_COST) then
		if c:GetEquipGroup():IsExists(s.cfilter, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
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
function s.geqfilter(c, e, tp)
	if not c:CheckUniqueOnField(tp) then return false end
	if c:IsType(TYPE_EQUIP) then return c:CheckEquipTarget(e:GetHandler()) end
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
		c:EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end

function s.atkvalfilter(c)
	return c:IsOriginalType(TYPE_MONSTER)
end
function s.atkval(e, c)
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)/2
end
