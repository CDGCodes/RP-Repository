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
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.feqtgt)
	e2:SetOperation(s.feqop)
	c:RegisterEffect(e2)
	--Equip card from grave
	--Gains ATK equal to ATK of equipped monsters
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
	return c:CheckEquipTarget(e:GetHandler())
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
		Duel.Equip(p, tc, c)
	end
end
