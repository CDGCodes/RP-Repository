--Duelist Armaments - Violet Armor
local s, id=GetID()
function initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c, true, true, s.ffilter2, 1, s.ffilter, 2)
	c:SetSPSummonOnce(id)
    --Equip card on field
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id, 0))
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetTarget(s.feqtgt)
	e0:SetOperation(s.feqop)
	c:RegisterEffect(e0)
	aux.AddEREquipLimit(c, nil, aux.True, function(c, e, tp, tc) c:EquipByEffectAndLimitRegister(e, tp, tc, id, true) end, e0)
end

function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.ffilter(c, fc, sumtype, tp)
	return c:IsType(TYPE_SPELL,fc,sumtype,tp) and c:IsOnField()
end
function s.ffilter2(c, fc, sumtype, tp)
    return c:IsCode(200001369, fc, sumtype, tp) and c:IsOnField()
end

function s.feqfilter(c, e, tp)
	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 and c:GetLocation()==LOCATION_MZONE then return false end
	if c==e:GetHandler() or not c:IsFaceup() then return false end
	if c:GetEquipTarget() and c:GetEquipTarget()==e:GetHandler() then return false end
    if c:IsControler(1-tp) and not c:IsAbleToChangeControler() then return false end
	return (c:CheckEquipTarget(e:GetHandler()) or not c:IsType(TYPE_EQUIP))
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
		c:EquipByEffectAndLimitRegister(e, tp, tc, id)
	end
end