--Duelist Armaments - Violet Robe
local s,id=GetID()
function s.initial_effect(c)
	--Summon Restrictions
	c:SetUniqueOnField(1, 0, s.arcfusfilter(c)
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
	e1:SetConditions(s.sumcon)
	e1:SetTarget(s.sumtgt)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
end

function s.armfusfilter(c)
	return c:IsSetCode(0xFEDC) and c:IsType(TYPE_FUSION)
end

function s.sumfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.sumcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)
	return #g>=2 and aux.SelectUnselectGroup(g, e, tp, 2, 2, true, 0)
end
function s.sumtgt(e, tp, eg, ep, ev, re, r, rp, c)
	local g=Duel.GetMatchingGroup(s.sumfilter, tp, LOCATION_ONFIELD, 0, nil)
	local sg=aux.SelectUnselectGroup(g, e, tp, 2, 2, true, 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
	if #sg>0 then
		sg:KeepAlive()
		e:GetLabelObject(sg)
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
