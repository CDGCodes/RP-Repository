--Magical Girl Rouge Lv5
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 5, 2, s.ovfilter, aux.Stringid(id,0))
	
	end
	
	
	function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,70000011)
end