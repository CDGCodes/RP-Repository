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
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptgt)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return tp==Duel.GetTurnPlayer() and Duel.GetDrawCount(tp)>0 and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)>0
end
function s.spfilter(c, e, tp)
    if c:GetControler()~=tp and Duel.GetLocationCount(tp, LOCATION_MZONE, 0)<=0 then return false end
    return c:IsAbleToDeck() and (c:IsAttribute(e:GetHandler():GetAttribute()) or c:IsLevel(e:GetHandler():GetLevel()) or c:IsRank(e:GetHandler():GetLevel()) or c:IsLink(e:GetHandler():GetLevel()))
end
function s.sptgt(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, e, tp) end
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
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    _replace_count=_replace_count+1
    if _replace_count<=_replace_max and c:IsRelateToEffect(e) then
        local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil, e, tp)
        if Duel.SendtoDeck(g, nil, 1, REASON_EFFECT)~=0 then
            if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~0 and Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)==0 then
                Duel.BreakEffect()
                Duel.Win(tp, 0x900)
            end
        end
    end
end