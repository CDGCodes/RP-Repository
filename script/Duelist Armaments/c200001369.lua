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
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_ONFIELD)
    e3:SetCondition(function(e) return e:GetHandler():IsType(TYPE_EFFECT) or e:GetHandler():GetEquipTarget() end)
	e3:SetCountLimit(1, {id, 0})
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_ONFIELD)
    e4:SetCondition(function(e) return e:GetHandler():IsType(TYPE_EFFECT) or e:GetHandler():GetEquipTarget() end)
	e4:SetCountLimit(1, {id, 0})
	e4:SetTarget(s.xstarget)
	e4:SetOperation(s.xsop)
	c:RegisterEffect(e4)
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
		e1:SetDescription(aux.Stringid(id, 4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end

function s.xsfilter(c, tp)
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_EQUIP) and Duel.IsPlayerCanSpecialSummonMonster(tp, c:GetCode(), 0xFEDC, 0x21, 1000, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT)
end
function s.xstarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingTarget(s.xsfilter, tp, LOCATION_SZONE, 0, 1, nil, tp) end
	if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
		local g=Duel.SelectTarget(tp, s.xsfilter, tp, LOCATION_SZONE, 0, 1, 1)
		if #g>0 then
			Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
		end
	else
		local g=Duel.SelectTarget(tp, s.xsfilter, tp, LOCATION_SZONE, 0, 1, math.min(2, Duel.GetLocationCount(tp, LOCATION_MZONE)), nil, tp)
		if #g>0 then
			Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
		end
	end
end
function s.exfilter(c)
	return (c:IsSynchroSummonable() or c:IsXyzSummonable()) and c:IsSetCard(0xFEDC)
end
function s.xsop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if (#g>1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)) or #g>Duel.GetLocationCount(tp, LOCATION_MZONE) then return end
	if #g>0 then
		for tc in aux.Next(g) do
			if tc:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp, tc:GetCode(), 0xFEDC, 0x21, 1500, 1000, 2, RACE_ILLUSION, ATTRIBUTE_LIGHT) then
				tc:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL+TYPE_TRAPMONSTER)
				Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP)
				tc:AddMonsterAttributeComplete()
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_SINGLE)
				e0:SetCode(EFFECT_SET_BASE_ATTACK)
				e0:SetValue(1000)
				e0:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e0, true)
				local e1=e0:Clone()
				e1:SetCode(EFFECT_SET_BASE_DEFENSE)
				e1:SetValue(1000)
				tc:RegisterEffect(e1, true)
				local e2=e0:Clone()
				e2:SetCode(EFFECT_CHANGE_RACE)
				e2:SetValue(RACE_ILLUSION)
				tc:RegisterEffect(e2)
				local e3=e0:Clone()
				e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e3:SetValue(ATTRIBUTE_LIGHT)
				tc:RegisterEffect(e3)
				local e4=e0:Clone()
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(2)
				tc:RegisterEffect(e4)
			end
		end
		Duel.SpecialSummonComplete()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1, 0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
	local sg=Duel.GetMatchingGroup(s.exfilter, tp, LOCATION_EXTRA, 0, nil)
	if #sg>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local sc=sg:Select(tp, 1, 1, nil):GetFirst()
		if sc then
			Duel.BreakEffect()
			if sc:IsType(TYPE_SYNCHRO) then
				Duel.SynchroSummon(tp, sc)
			elseif sc:IsType(TYPE_XYZ) then
				Duel.XyzSummon(tp, sc)
			end
		end
	end
end