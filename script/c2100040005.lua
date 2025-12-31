--The Corrupted DARK
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

    -- Track activation of "Soul Corruption" and DARK attribute declaration
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)

    -- Inflict 500 damage per DARK monster controlled (Once per turn)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+200)
    e3:SetTarget(s.damtg)
    e3:SetOperation(s.damop)
    c:RegisterEffect(e3)

    -- Equip 1 face-up monster on field to this card
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,4))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_START)
    e4:SetCountLimit(1,{id,4})
    e4:SetCondition(s.eqcon)
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)

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
end

-- Track "Soul Corruption" activation and DARK declaration
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
    local flagok = (Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp,id)==ATTRIBUTE_DARK)
        or (Duel.HasFlagEffect(1-tp,id) and Duel.GetFlagEffectLabel(1-tp,id)==ATTRIBUTE_DARK)
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

-- Filter for DARK monsters to send to GY as cost (for GY summon)
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end

-- Damage effect target
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=Duel.GetMatchingGroupCount(s.darkfilter,tp,LOCATION_MZONE,0,nil)
    local dam=ct*500
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end

-- Damage effect operation
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.darkfilter,tp,LOCATION_MZONE,0,nil)
    local dam=ct*500
    Duel.Damage(1-tp,dam,REASON_EFFECT)
end

-- Filter for DARK monsters
function s.darkfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c
end
function s.eqfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.equipop(c,e,tp,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(tc:GetAttack())
	c:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		s.equipop(c,e,tp,tc)
	end
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
