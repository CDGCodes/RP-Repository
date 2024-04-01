--Malefic Odd-Eyes Pendulum Dragon
local s, id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1, 1, aux.MaleficUniqueFilter(c), LOCATION_MZONE)
	aux.AddMaleficSummonProcedure(c, 16178681, LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
	--Double Damage
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e7:SetCondition(s.damcon)
	e7:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e7)
	--Attack Restriction
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_SELF_DESTROY)
	e8:SetCondition(s.descon)
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
s.listed_names={16178681}

function s.descon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.antarget(e, c)
	return c~=e:GetHandler()
end
