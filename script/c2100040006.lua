--The Corrupted FIRE
local s,id=GetID()
s.listed_names={2100040002} -- this card lists 2100040002
function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    c:AddMustBeSpecialSummonedByCardEffect()

    -- Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e1:SetCountLimit(1,id) -- once per turn (special summon)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Track activation of "Soul Corruption" and FIRE attribute declaration
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)

    -- Once per turn, Main Phase (in hand): reveal this card; add 1 "2100040002" from your Deck to your hand, then shuffle 1 card from your hand into your Deck
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_HAND)
    e6:SetCountLimit(1,id+1)
    e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        local ph=Duel.GetCurrentPhase()
        return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
    end)
    e6:SetCost(s.revcost)
    e6:SetTarget(s.revthtg)
    e6:SetOperation(s.revthop)
    c:RegisterEffect(e6)

    -- FIRE monsters can't be destroyed by opponent's card effects
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTargetRange(LOCATION_MZONE,0)
    e7:SetTarget(s.protectfilter)
    e7:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
    c:RegisterEffect(e7)

    -- Quick effect: send 1 card from each field to the grave
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,5))
    e8:SetCategory(CATEGORY_TOGRAVE)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1,id+2)
    e8:SetTarget(s.sendtg)
    e8:SetOperation(s.sendop)
    c:RegisterEffect(e8)
end

-- Track "Soul Corruption" activation and FIRE declaration
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(2100040002) then -- Assuming "Soul Corruption" has this ID
        Duel.RegisterFlagEffect(rp,id,0,0,0,Duel.GetFlagEffectLabel(1,2100040002))
    end
end

-- Special Summon condition function (updated)
function s.spcon(e)
    local c=e:GetHandler()
    if c==nil then return true end
    local tp=c:GetControler()
    local flagok = (Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp,id)==ATTRIBUTE_FIRE)
        or (Duel.HasFlagEffect(1-tp,id) and Duel.GetFlagEffectLabel(1-tp,id)==ATTRIBUTE_FIRE)
    if not flagok then return false end
    if c:IsLocation(LOCATION_HAND) then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    elseif c:IsLocation(LOCATION_GRAVE) then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
    end
    return false
end

-- Special Summon target function
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

-- Special Summon operation function (updated)
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        if not Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil) then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
        if #g~=2 then return end
        if Duel.SendtoGrave(g,REASON_COST)~=2 then return end
    end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Filter for FIRE monsters to send to GY as cost (for GY summon)
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end

--reveal search: reveal this card then add 1 card (ID 2100040002) from Deck to hand, then shuffle 1 card from your hand into your Deck
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

-- Filter for FIRE monsters to protect
function s.protectfilter(e,c)
    return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Quick effect target: send 1 from each field
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,0)
end

-- Quick effect operation: send cards to grave
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    g:Merge(Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil))
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
    g:Merge(Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_MZONE,0,1,1,nil))
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
