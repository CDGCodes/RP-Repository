--Duelist Cavalry - Iridescent Steed
if not NEXUS_IMPORTED then Duel.LoadScript("proc_nexus.lua") end

local s, id = GetID()
s.Nexus=true
function s.initial_effect(c)
    c:EnableReviveLimit()
    Nexus.AddProcedure(c, nil, true, 2, 99)
    -- Equip from grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id, 0})
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    -- Swap equips on field
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.speqtg)
    e2:SetOperation(s.speqop)
    c:RegisterEffect(e2)
    -- ATK up
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetCondition(function(e) return e:GetHandler():GetEquipTarget():IsSetCard(SET_DUELIST_ARMAMENTS) end)
    e3:SetValue(2000)
    c:RegisterEffect(e3)
    -- Inherit effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(LOCATION_MZONE, 0)
    e4:SetTarget(function(e, c) return c==e:GetHandler():GetEquipTarget() and c:IsSetCard(SET_DUELIST_ARMAMENTS) end)
    e4:SetLabelObject(e2)
    c:RegisterEffect(e4)
end

function s.eqcon(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_NEXUS)
end

function s.eqfilter(c, tp, sc)
    return c:IsEquipSpell() and c:IsSetCard(SET_DUELIST_ARMAMENTS) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(sc)
end

function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.eqfilter(chkc, tp, c) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter, tp, LOCATION_GRAVE|LOCATION_REMOVED, 0, 1, nil, tp, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.eqfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, 1, nil, tp, c)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, g, 1, 0, 0)
end

function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = Duel.GetFirstTarget()
    if not ec:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 then return end
    Duel.Equip(tp, ec, c)
end

function s.spfilter(c, e, tp)
    if c:IsFaceup() then
        if c:IsMonsterCard() and c:IsEquipSpell() then
            return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        elseif c:IsSetCard(SET_DUELIST_ARMAMENTS) and c:IsEquipSpell() then
            return Duel.IsPlayerCanSpecialSummonMonster(tp, c:GetCode(), SET_DUELIST_ARMAMENTS, 0x21, 1000, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT)
        else return false end
    end
    return false
end

function s.speqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_SZONE, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_SZONE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.speqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if tc:IsMonsterCard() and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        elseif Duel.IsPlayerCanSpecialSummonMonster(tp, tc:GetCode(), 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) then
            tc:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL+TYPE_TRAPMONSTER)
            Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP)
            tc:AddMonsterAttributeComplete()
            local e0=Effect.CreateEffect(tc)
            e0:SetType(EFFECT_TYPE_SINGLE)
            e0:SetCode(EFFECT_SET_BASE_ATTACK)
            e0:SetValue(1000)
            e0:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e0, true)
            local e1=e0:Clone()
            e1:SetCode(EFFECT_SET_BASE_DEFENSE)
            e1:SetValue(1000)
            tc:RegisterEffect(e1, true)
            local e2=e0:Clone()
            e2:SetCode(EFFECT_CHANGE_RACE)
            e2:SetValue(RACE_ILLUSION)
            tc:RegisterEffect(e2)
            local e3=e0:Clone()
            e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e3:SetValue(ATTRIBUTE_LIGHT)
            tc:RegisterEffect(e3)
            local e4=e0:Clone()
            e4:SetCode(EFFECT_CHANGE_LEVEL)
            e4:SetValue(2)
            tc:RegisterEffect(e4)
            Duel.SpecialSummonComplete()
        end
    end
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, 0, tc)
    if tc:IsLocation(LOCATION_MZONE) and #g>0 and Duel.SelectYesNo(tp, 1068) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.HintSelection(sg)
        local sc = sg:GetFirst()
        if Duel.Equip(tp, sc, tc) then
            --Equip limit registration
            local e0=Effect.CreateEffect(sc)
            e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0:SetCode(EFFECT_EQUIP_LIMIT)
			e0:SetValue(function(e,sc) return sc==tc end)
			e0:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e0)
        end
    end
end