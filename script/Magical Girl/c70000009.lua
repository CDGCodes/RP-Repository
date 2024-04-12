local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(s.attcon)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e3)

end

function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.attconfilter,1,nil,tp)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsType(TYPE_XYZ) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToChangeControler),tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsType(TYPE_XYZ) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToChangeControler),tp,0,LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.Overlay(tc,g)
	end
end