local s,id=GetID()
function s.initial_effect(c)
    -- Fusion Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)

    -- Return 1 "HERO" Fusion Monster to the Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1,EFFECT_COUNT_CODE_OATH)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.filter1(c,e)
    return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end

function s.filter2(c,e,tp,m)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and c:CheckFusionMaterial(m,nil,tp) and c.material_count==2
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
        local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil,e)
        mg1:Merge(mg2)
        return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
    local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil,e)
    mg1:Merge(mg2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg1)
    local tc=sg:GetFirst()
    if not tc then return end
    local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
    tc:SetMaterial(mat1)
    Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    Duel.BreakEffect()
    Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
    tc:CompleteProcedure()

    -- Lock for the rest of the turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
    return not c:IsSetCard(0x8)
end

function s.thfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x8) and c:IsAbleToExtra()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
end
