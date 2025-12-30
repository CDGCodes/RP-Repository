--The Corrupted Shadow
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
    
    --Cannot be special summoned by other ways
    --local e2=Effect.CreateEffect(c)
    --e2:SetType(EFFECT_TYPE_SINGLE)
    --e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    --e2:SetCode(EFFECT_SPSUMMON_CONDITION)
    --e2:SetValue(aux.FALSE)
    --c:RegisterEffect(e2)

    --Track activation of the card with ID 3000000002 and DARK attribute choice
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

    --Special summon a DARK attribute monster from the graveyard once per turn during the end phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0)) -- Adding description
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.epcon)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)

    -- Give up your normal draw to search 1 card (ID 2100040002)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PREDRAW)
    e6:SetRange(LOCATION_HAND)
    e6:SetCondition(s.thcon)
    e6:SetCost(s.thcost)
    e6:SetTarget(s.thtg)
    e6:SetOperation(s.thop)
    c:RegisterEffect(e6)

    -- NEW: Once per turn, when this card is Special Summoned, reveal 1 Monster in your Extra Deck;
    -- if you do, equip it to this card, copy its effect, and set this card's original ATK/DEF to match it.
    -- When this card is sent from the field to the GY, banish that equipped monster.
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,4))
    e7:SetCategory(CATEGORY_EQUIP)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCountLimit(1,id)
    e7:SetTarget(s.eqtg)
    e7:SetOperation(s.eqop)
    c:RegisterEffect(e7)

    -- When sent from field to GY, banish the monster equipped by this card's effect
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e8:SetCode(EVENT_TO_GRAVE)
    e8:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        return c:IsPreviousLocation(LOCATION_ONFIELD)
    end)
    e8:SetOperation(s.rmop)
    c:RegisterEffect(e8)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(2100040002) then
        --Debug.Message(Duel.GetFlagEffectLabel(1, 3000000002))
        Duel.RegisterFlagEffect(rp,id,0,0,0,Duel.GetFlagEffectLabel(1, 2100040002))
    end
end

--Special summon condition function
function s.spcon(e)
    local c=e:GetHandler()
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
        and ((Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp, id)==ATTRIBUTE_DARK) 
        or (Duel.HasFlagEffect(1-tp, id) and Duel.GetFlagEffectLabel(1-tp, id)==ATTRIBUTE_DARK))
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
    if Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
        if Duel.Destroy(g,REASON_COST)~=2 then return end
    end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Filter to check DARK attribute monsters on the field, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDestructable() and not c:IsCode(id)
end

--Condition to check if it's the controller's end phase
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return tp==Duel.GetTurnPlayer()
end

--Target function for special summoning DARK attribute monster from the graveyard
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation function for special summoning DARK attribute monster from the graveyard
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_DARK)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- NEW: Extra Deck equip helpers
function s.eqfilter(c)
    return c:IsType(TYPE_MONSTER)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    Duel.ConfirmCards(1-tp,tc)
    -- Move the selected Extra Deck monster to S/T zone
    if not Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,false) then return end
    -- Turn it into an Equip Spell (Continuous equip)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetValue(TYPE_SPELL+TYPE_EQUIP)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    -- Equip limit to this card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    e2:SetValue(function(ef,ec) return ec==c end)
    tc:RegisterEffect(e2)
    -- Equip it to this card
    Duel.Equip(tp,tc,c)
    -- Copy the equipped monster's original effect(s) onto this card
    c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD)
    -- Set this card's original ATK/DEF to the equipped monster's
    local atk=tc:GetBaseAttack()
    local def=tc:GetBaseDefense()
    if atk and atk>=0 then
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e3:SetCode(EFFECT_SET_BASE_ATTACK)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        e3:SetValue(atk)
        c:RegisterEffect(e3)
    end
    if def and def>=0 then
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e4:SetCode(EFFECT_SET_BASE_DEFENSE)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD)
        e4:SetValue(def)
        c:RegisterEffect(e4)
    end
    -- Mark equipped card for banish when this card hits GY and link it to this card
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    c:SetCardTarget(tc)
end

-- When this card is sent from the field to the GY, banish the equipped monster (if marked)
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetEquipGroup()
    if not g or #g==0 then return end
    local sg=g:Filter(function(card) return card:GetFlagEffect(id)>0 end,nil)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end

-- List the searched card
s.listed_names={2100040002}

-- Search helpers (searches deck for card ID 2100040002)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
        and Duel.GetDrawCount(tp)>0 and (Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.thfilter(c)
    return c:IsCode(2100040002) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local dt=Duel.GetDrawCount(tp)
    if dt==0 then return false end
    _replace_count=1
    _replace_max=dt
    -- Give up your normal draw this turn
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_DRAW_COUNT)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE|PHASE_DRAW)
    e1:SetValue(0)
    Duel.RegisterEffect(e1,tp)
    if _replace_count>_replace_max then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
