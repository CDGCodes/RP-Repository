--The Corrupted Wind
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be normal summoned/set
    c:EnableUnsummonable()
    c:AddMustBeSpecialSummonedByCardEffect()
    --Special summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Track activation of the card with ID 3000000002 and WIND attribute choice
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)
    --if not s.global_check then
    --    s.global_check=true
    --    local ge1=Effect.CreateEffect(c)
    --    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    --    ge1:SetCode(EVENT_CHAINING)
    --    ge1:SetOperation(s.checkop)
    --    Duel.RegisterEffect(ge1,0)
    --end

    --Quick effect: Move a WIND monster to the spell and trap zone or vice versa
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.stztg)
    e3:SetOperation(s.stzop)
    c:RegisterEffect(e3)

    -- Once per turn, Main Phase (in hand): reveal this card; add 1 "2100040002" from your Deck to your hand, then shuffle 1 card from your hand into your Deck
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_HAND)
    e4:SetCountLimit(1,id+1)
    e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        local ph=Duel.GetCurrentPhase()
        return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
    end)
    e4:SetCost(s.revcost)
    e4:SetTarget(s.revthtg)
    e4:SetOperation(s.revthop)
    c:RegisterEffect(e4)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(2100040002) then
        --Debug.Message(Duel.GetFlagEffectLabel(1, 3000000002))
        Duel.RegisterFlagEffect(rp,id,0,0,0,Duel.GetFlagEffectLabel(1, 2100040002))
    end
end

--Calculate the ATK reduction for opponent's monsters based on WIND monsters you control
function s.atkval(e,c)
    local tp=e:GetHandler():GetControler()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WIND),tp,LOCATION_MZONE,0,nil)
    return -g:GetCount() * 300
end

--Filter for monsters set as Continuous Spells
function s.ctfilter(c)
    return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsOriginalType(TYPE_MONSTER)
end

--Special summon condition function
function s.spcon(e)
    local c=e:GetHandler()
    if c==nil then return true end
    local tp=c:GetControler()
    -- attribute flag must be set to WIND by the card 2100040002 earlier in the duel
    if not ((Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp, id)==ATTRIBUTE_WIND) 
        or (Duel.HasFlagEffect(1-tp, id) and Duel.GetFlagEffectLabel(1-tp, id)==ATTRIBUTE_WIND)) then
        return false
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
    -- If in hand, no tributes required; if in GY, require 2 WIND monsters on field to send to GY
    if c:IsLocation(LOCATION_HAND) then
        return true
    else
        return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
    end
end

--Special summon operation function
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- If activating from GY, send 2 WIND monsters on your field to the GY as cost
    if c:IsRelateToEffect(e) then
        if c:IsLocation(LOCATION_GRAVE) then
            if Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
                if Duel.SendtoGrave(g,REASON_COST)~=2 then return end
            else return end
        end
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Filter to check WIND attribute monsters on the field, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDestructable() and not c:IsCode(id)
end

--Condition to check if it's the controller's end phase
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return tp==Duel.GetTurnPlayer()
end

--Target function for special summoning WIND attribute monster from the graveyard
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WIND) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation function for special summoning WIND attribute monster from the graveyard
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_WIND)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Target function for moving WIND monster to spell and trap zone or vice versa
function s.stztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_MZONE,0,1,nil, e, tp)
        or Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_SZONE,0,1,nil, e, tp) end
end

--Operation function for moving WIND monster to spell and trap zone or vice versa
function s.stzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local g=Duel.SelectMatchingCard(tp,s.stzfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil, e, tp)
    local tc=g:GetFirst()
    if tc then
        if tc:IsLocation(LOCATION_MZONE) then
            if Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
                Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
            elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
                --Treat it as a Continuous Spell
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_CHANGE_TYPE)
                e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
                e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
                tc:RegisterEffect(e1)
            end
        else
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

--Filter for WIND monsters on the field
function s.stzfilter(c,e,tp)
    if c:IsAttribute(ATTRIBUTE_WIND) then
        if c:IsLocation(LOCATION_MZONE) then return true end
        return c:IsMonsterCard() and c:IsContinuousSpell() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
end

-- List the searched card
s.listed_names={2100040002}

-- New in-hand reveal search: reveal this card then add 1 card (ID 2100040002) from Deck to hand, then shuffle 1 card from your hand into your Deck
function s.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.revthfilter(c)
    return c:IsCode(2100040002) and c:IsAbleToHand()
end
function s.revthtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.revthfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.revthop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.revthfilter,tp,LOCATION_DECK,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.revthfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
