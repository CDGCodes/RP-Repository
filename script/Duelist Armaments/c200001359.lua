--Duelist Armaments - Violet Robe
local s,id=GetID()
function s.initial_effect(c)
	--Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Special Summoning Condition
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--Special Summoning Procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtgt)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--Equip card on field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.feqtgt)
	e2:SetOperation(s.feqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, 1-tp, tc, id, true) end, e2)
	--Equip card from grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
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
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_FUSION)
end

function s.sumfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.sumcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)>=2
end
function s.sumtgt(e, tp, eg, ep, ev, re, r, rp, c)
	local g=Duel.GetMatchingGroup(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)
	local sg=g:Select(tp, 2, 2, nil)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.sumop(e, tp, eg, ep, ev, re, r, rp)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g, REASON_COST)
	g:DeleteGroup()
end

function s.feqfilter(c, e, tp)
	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 and c:GetLocation()==LOCATION_MZONE and c:GetControler()==tp then return false end
	if Duel.GetLocationCount(1 - tp, LOCATION_SZONE)<=0 and c:GetLocation()==LOCATION_MZONE and c:GetControler()==(1-tp) then return false end
	if c==e:GetHandler() or not c:IsFaceup() then return false end
	if c:GetEquipTarget() and c:GetEquipTarget()==e:GetHandler() then return false end
	return (c:CheckEquipTarget(e:GetHandler()) or not c:IsType(TYPE_EQUIP) )
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
		local p=tc:GetControler()
		c:EquipByEffectAndLimitRegister(e, p, tc, id)
	end
end

function s.geqcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
end
function s.geqfilter(c, e)
	if c:IsType(TYPE_EQUIP) then return c:CheckEquipTarget(e:GetHandler()) end
	return c:IsType(TYPE_MONSTER)
end
function s.geqtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return true end
	if chk==0 then return Duel.IsExistingTarget(s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e) end
	local sg=Duel.SelectTarget(tp, s.geqfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e)
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
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)
end
