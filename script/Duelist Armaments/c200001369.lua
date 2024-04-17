--Duelist Armaments - Gauntlet
local s, id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1, 0, id)
	aux.AddEquipProcedure(c)
	--ATK/DEF up (Equip)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
    local params = {nil,Fusion.OnFieldMat,s.fextra, nil, nil, s.stage2}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_ONFIELD)
    e3:SetCondition(function(e) return e:GetHandler():IsType(TYPE_EFFECT) or e:GetHandler():GetEquipTarget() end)
	e3:SetCountLimit(1, {id, 0})
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if se:GetHandler():IsSpell() then return false end
	return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_HAND))
end
function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(0xFEDC) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_SZONE,0,nil),s.checkmat
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==2 then
		local e1=Effect.CreateEffect(e:GetHandler())
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