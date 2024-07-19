--Melffy Purrely
local s, id=GetID()
function s.initial_effect(c)
    --Becomes Level 2
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(2)
	c:RegisterEffect(e1)
    --Return to hand
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(s.thcon2)
	c:RegisterEffect(e4)
end

s.listed_names={id}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetBattleTarget():IsControler(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thfilter2(c)
    return c:IsType(TYPE_XYZ)
end
function s.thfilter(c, tp)
	if not (c:IsSetCard(0x18d) or c:IsSetCard(0x147)) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) then return false end
    if Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_MZONE, 0, 1, nil) then return true end
    return c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,c)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
            if not Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_MZONE, 0, 1, nil) then
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, sg)
            else
                aux.ToHandOrElse(sg, tp, aux.TRUE,function()
                    local x=Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_MZONE, 0, 1, 1)
                    Duel.Overlay(x, sg)
                end,aux.Stringid(id,0))
            end
		end
	end
end