--Duelist Armaments - White Robe
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_SPELL), 1, 99)
	c:SetSPSummonOnce(id)
    --Equip card from deck/grave
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_SINGLE)
    e1:SetCondition(s.geqcon)
    e1:SetTarget(s.deqtgt)
    e1:SetOperation(s.deqop)
    c:RegisterEffect(e1)
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
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.feqfilter(c, tp)
    return Duel.IsExistingMatchingCard(s.deqfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil, c, tp)
end
function s.deqfilter(c, sc, tp)
    if not c:CheckUniqueOnField(tp) then return false end
    return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(sc)
end
function s.deqtgt(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingTarget(s.feqfilter, tp, LOCATION_MZONE, 0, 1, nil, tp) end
    local sg=Duel.SelectTarget(tp, s.feqfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_GRAVE|LOCATION_DECK)
end
function s.deqop(e, tp, eg, ep, ev, re, r, rp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.deqfilter), tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1, nil, tc, tp)
	local gc=g:GetFirst()
	if gc then
		Duel.Equip(tp,gc,c)
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
