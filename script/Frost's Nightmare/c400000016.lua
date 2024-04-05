-- Nightmare gene
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	local params = {nil,Fusion.CheckWithHandler(Fusion.InHandMat(aux.FilterBoolFunction(Card.IsSetCard,0x1A2B))),nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
