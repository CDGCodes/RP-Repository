-- HERO Evolution
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x8) and Duel.GetMZoneCount(tp,c)>0
end

function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spfilter2(c,e,tp,att,code)
	return c:IsSetCard(0x8) and c:IsAttribute(att) and c:GetOriginalCode()~=code and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spfilter3(c,e,tp,att,lv,code)
	return c:IsSetCard(0x8) and c:IsAttribute(att) and (c:GetLevel()==lv or c:GetLevel()==lv+1) and c:GetOriginalCode()~=code and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp)
	end

	local sel=0
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	local tc=g:GetFirst()
	local att=tc:GetAttribute()
	local code=tc:GetOriginalCode()
	local lv=tc:GetLevel()
	Duel.Release(g,REASON_COST)

	if Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) then sel=sel+1 end
	if Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,att,code) then sel=sel+2 end
	if Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_DECK,0,1,nil,e,tp,att,lv,code) then sel=sel+4 end

	e:SetLabel(sel)
	return sel~=0
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sel=e:GetLabel()
	local opt=0

	if sel==1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0))+1
	elseif sel==2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+2
	elseif sel==3 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1
	elseif sel==4 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+3
	elseif sel==5 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,2))+1
	elseif sel==6 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+2
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))+1
	end

	local att=Duel.GetOperatedGroup():GetFirst():GetAttribute()
	local code=Duel.GetOperatedGroup():GetFirst():GetOriginalCode()
	local lv=Duel.GetOperatedGroup():GetFirst():GetLevel()
	local g=nil

	if opt==1 then
		g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	elseif opt==2 then
		g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,att,code)
	else
		g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_DECK,0,1,1,nil,e,tp,att,lv,code)
	end

	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
