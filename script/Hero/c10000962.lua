-- HEROic Rebirth
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Add "Polymerization" or "Fusion" Spell Card from Deck to hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    -- Check for the presence of a Fusion monster to enable destruction
    local des=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION)
    if des then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
    end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- Check again for Fusion Monster to proceed with destruction
        if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
                if #dg>0 then
                    Duel.HintSelection(dg)
                    Duel.Destroy(dg,REASON_EFFECT)
                end
            end
        end
    end
end

function s.thfilter(c)
    return (c:IsCode(24094653) or c:IsSetCard(0x46)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
