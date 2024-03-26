--Evil HERO Moonfall
local s, id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c, true, true, s.fusfilter, 2)
end
function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
	return c:IsSetCard(0x8, fc, sumtype, tp) and (c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp) or c:IsType(TYPE_NORMAL, tc, sumtype, tp))
end
