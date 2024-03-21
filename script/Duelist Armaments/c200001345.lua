--Duelist Armaments - Shield
local s, id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--ATK/DEF up (Equip)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.spgycon)
	c:RegisterEffect(e5)
	--Copy Equip effects as monster
	local e6=e2:Clone()
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.effcon)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.effcon)
	c:RegisterEffect(e7)
	--Allow direct attacks
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(1)
	e8:SetCondition(s.dircon)
	c:RegisterEffect(e8)
	--Protection
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_EQUIP)
	e9:SetCode(EFFECT_INDESTRUCTABLE)
	e9:SetValue(s.prval)
	e9:SetCondition(s.prcon)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e10)
	--Redirect equip
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e11:SetCode(EVENT_ATTACK_ANNOUNCE)
	e11:SetRange(LOCATION_ONFIELD)
	e11:SetCountLimit(1, id, 0)
	e11:SetCondition(s.atkcon)
	e11:SetTarget(s.atktgt)
	e11:SetOperation(s.atkop)
	c:RegisterEffect(e11)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if se:GetHandler():IsSpell() then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL)
		Duel.SpecialSummonStep(c, 0, tp, tp, true, false, POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id, 1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end
function s.spgycon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE)>Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)
end

function s.effcon(e)
	return e:GetHandler():IsType(TYPE_EFFECT)
end
function s.dircon(e)
	return e:GetHandler():IsAttackPos() and s.effcon
end

function s.prcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_SZONE) and c:GetEquipTarget()) or (c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT))
end
function s.prtg(e, c)
	return c:IsSetCard(0xFEDC)
end
function s.prval(e, re, r, rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end

function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
	--if not s.prcon then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a:IsControler(1-tp) and d and d:IsControler(tp) and d:IsFaceup()
end
function s.atktgt(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.GetAttacker():CreateEffectRelation(e)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsRelateToEffect(e) and d:IsRelateToBattle() then
		Duel.Equip(tp, c, d)
	end
end
