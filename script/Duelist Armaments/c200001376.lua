--Duelist Cavalry - Iridescent Steed
if not NEXUS_IMPORTED then Duel.LoadScript("proc_nexus.lua") end

local s, id = GetID()
s.Nexus=true
function s.initial_effect(c)
    c:EnableReviveLimit()
    Nexus.AddProcedure(c, nil, true, 2, 99)
    -- Equip from grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    -- Swap equips on field
    -- Inherit effect
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
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc, tp, c) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter, tp, LOCATION_GRAVE, 0, 1, nil, tp, c) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local g = Duel.SelectTarget(tp, s.eqfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, tp, c)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE|CATEGORY_EQUIP, g, 1, 0, 0)
end
function s.eqop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = Duel.GetFirstTarget()
    if not ec:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 then return end
    Duel.Equip(tp, ec, c)
end