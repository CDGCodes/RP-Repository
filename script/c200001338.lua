--Black Rose Magician Girl
local s,id=GetID()
function s.initial_effect(c)
	--contact fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,38033121,73580471)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--gain atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--destroy monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.material={38033121,73580471}
s.listed_names={38033121,73580471}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function s.valfilter(c)
	return c:IsSetCard(0x20a2) and c:IsFaceup()
end
function s.val(e, c)
	return Duel.GetMatchingGroupCount(s.valfilter, e:GetHandlerPlayer(), LOCATION_MZONE, LOCATION_MZONE, nil)*200
end

function s.cfilter(c, tp)
	return c:IsReason(REASON_DESTROY) and c:IsCode(38033121)
end
function s.descon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.Destroy(tc,REASON_EFFECT)
end
