--Duelist Armaments - Violet Robe
local s,id=GetID()
function s.initial_effect(c)
	--Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	c:SetSPSummonOnce(id)
	--Equip card on field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.feqtgt)
	e2:SetOperation(s.feqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e2)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, 1-tp, tc, id, true) end, e2)
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
	--Return to Extra Deck is it leaves the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCondition(function(e)return e:GetHandler():IsFaceup()end)
	e5:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e5)
end


function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0xFEDC,fc,sumtype,tp) and c:IsOnField()
end

function s.sumcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)>=3
end
function s.sumtgt(e, tp, eg, ep, ev, re, r, rp, c)
	local g=Duel.GetMatchingGroup(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)
	local sg=g:Select(tp, 3, 3, nil)
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
	return e:GetHandler():GetEquipGroup():Filter(s.atkvalfilter, nil):GetSum(Card.GetTextAttack)
end
