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
	local e3=e2:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
    local params = {nil,Fusion.OnFieldMat,s.fextra}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_ONFIELD)
    e2:SetCondition(function(e) return e:GetHandler():IsType(TYPE_EFFECT) or e:GetHandler():GetEquipTarget())
	e2:SetCountLimit(1)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end

function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(0xFEDC) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_SZONE,0,nil),s.checkmat
end