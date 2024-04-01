--Malefic Firewall Dragon
local s, id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1, 1, aux.MaleficUniqueFilter(c), LOCATION_MZONE)
	aux.AddMaleficSummonProcedure(c, 5043010, LOCATION_EXTRA)
	--Attack Restriction
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(s.descon)
	c:RegisterEffect(e7)
	--Negate attack
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetCondition(s.atkcon)
	e8:SetCost(s.atkcost)
	e8:SetTarget(s.atktg)
	e8:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e8)
	--Self Destruct
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e9:SetTargetRange(LOCATION_MZONE,0)
	e9:SetTarget(s.antarget)
	c:RegisterEffect(e9)
end
s.listed_names={5043010}

function s.descon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.atkfilter(c)
	return c:IsSetCard(0x23) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true)
end
function s.atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.GetSelectMatchingCard(tp, s.atkfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
end

function s.antarget(e, c)
	return c~=e:GetHandler()
end
