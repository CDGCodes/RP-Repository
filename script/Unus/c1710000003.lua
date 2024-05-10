--Unus Aqua LV1
local s, id=GetID()
function s.initial_effect(c)
    --Hand Size Limit
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_HAND_LIMIT)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1, 0)
	e0:SetValue(999)
	c:RegisterEffect(e0)
    --Cannot Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1, 1)
	c:RegisterEffect(e1)
    --Summon
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_HAND)
    e2:SetCost(s.spcost)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptgt)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DRAW)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_HAND)
    e3:SetCost(s.spcost)
    e3:SetCondition(s.spcon2)
    e3:SetTarget(s.sptgt2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
    --Cycle Summon
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptgt3)
    e4:SetOperation(s.spop3)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)
    local e6=e4:Clone()
    e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e6)
    --Cannot be destroyed by battle
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e7:SetCondition(s.proccon)
	e7:SetValue(1)
	c:RegisterEffect(e7)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.splimit)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SUMMON, s.splimit)
    Duel.AddCustomActivityCounter(id, ACTIVITY_FLIPSUMMON, s.splimit)
end

function s.splimit(c)
    return c:IsSetCard(0x866)
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 
        and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SUMMON)==0
        and Duel.GetCustomActivityCount(id, tp, ACTIVITY_FLIPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(function(_,c) return not s.splimit(c) end)
    Duel.RegisterEffect(e1, tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_SUMMON)
    Duel.RegisterEffect(e2, tp)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    Duel.RegisterEffect(e3, tp)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return tp==Duel.GetTurnPlayer() and Duel.GetDrawCount(tp)>0 and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)>0
end
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    return tp==Duel.GetTurnPlayer() and Duel.GetCurrentPhase()==PHASE_DRAW
end
function s.spfilter(c, e, tp)
    if c:GetControler()~=tp and Duel.GetLocationCount(tp, LOCATION_MZONE, 0)<=0 then return false end
    return c:IsFaceup() and c:IsAbleToDeck() and (c:IsAttribute(e:GetHandler():GetAttribute()) or c:IsLevel(e:GetHandler():GetLevel()) or c:IsRank(e:GetHandler():GetLevel()) or c:IsLink(e:GetHandler():GetLevel()))
end
function s.sptgt(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, e, tp)
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    local dt=Duel.GetDrawCount(tp)
    if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.sptgt2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, e, tp)
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    _replace_count=_replace_count+1
    if _replace_count<=_replace_max and c:IsRelateToEffect(e) then
        local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil, e, tp)
        if Duel.SendtoDeck(g, nil, 1, REASON_EFFECT)~=0 then
            if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~0 and Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)==0 then
                Duel.BreakEffect()
                Duel.Win(tp, 0x90)
            end
        end
    end
end
function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil, e, tp)
        if Duel.SendtoDeck(g, nil, 1, REASON_EFFECT)~=0 then
            if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~0 and Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)==0 then
                Duel.BreakEffect()
                Duel.Win(tp, 0x90)
            end
        end
    end
end

function s.spfilter2(c, e, tp)
    return c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptgt3(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.spop3(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, 1, REASON_EFFECT)~=0 then
        local g=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
        if Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)~0 and Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)==0 then
            Duel.BreakEffect()
            Duel.Win(tp, 0x90)
        end
    end
end

function s.proccon(e)
    return not Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end