NEXUS_IMPORTED = true

-- When making a Nexus Monster, include the following line at the top of your card's file: 
--if not NEXUS_IMPORTED then Duel.LoadScript("proc_nexus.lua") end

if not RPCONSTANT_IMPORTED then Duel.LoadScript("RPConstant.lua") end

if not aux.NexusProcedure then
    aux.NexusProcedure = {}
    Nexus = aux.NexusProcedure
end
if not Nexus then
    Nexus = aux.NexusProcedure
end

function Card.IsNexus(c)
    return c.Nexus
end

--Nexus Summon
--Parameters:
-- c: card
-- f: optional, material filter
-- def: flag for if using DEF instead of ATK
-- min: min materials
-- max: optional, max materials (Default = 99)
-- specialchk: optional, additional check for materials (for checks on the group of materials, for example if they must all be different or if there must be at least one that respects a condition)
function Nexus.AddProcedure(c,f,def,min,max,specialchk)
	if max==nil then max=99 end
	if c.nexus_type==nil then
		local mt=c:GetMetatable()
		mt.nexus_type=1
		mt.nexus_parameters={c,f,def,min,max,specialchk}
	end
    c:SetStatus(STATUS_NO_LEVEL,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1181)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Nexus.Condition(f,def,min,max,specialchk))
	e1:SetTarget(Nexus.Target(f,def,min,max,specialchk))
	e1:SetOperation(Nexus.Operation(f,def,min,max,specialchk))
    e1:SetValue(SUMMON_TYPE_NEXUS)
	c:RegisterEffect(e1)
	--remove Synchro type
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_REMOVE_TYPE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(TYPE_SYNCHRO)
	c:RegisterEffect(e0)
end

function Nexus.ConditionFilter(c, def, f, sc, tp)
	return Nexus.GetNexusCount(c, def, sc)>0 and (not f or f(c,sc,SUMMON_TYPE_SPECIAL,tp))
end
function Nexus.GetNexusCount(c, def)
    if def and c:GetDefense()>0 then
        return c:GetDefense()
    end
    if (not def) and c:GetAttack()>0 then
        return c:GetAttack()
    end
    return 0
end
function Card.GetNexusCount(c, def)
	return Nexus.GetNexusCount(c, def)
end

function Nexus.CheckGoal(tp, def, sg, lc, minc, f, specialchk, filt)
    for _,filt in ipairs(filt) do
        if not sg:IsExists(filt[2], 1, nil, filt[3], tp, sg, Group.CreateGroup(), lc, filt[1], 1) then return false end
    end
    return #sg>=minc and sg:CheckWithSumEqual(Nexus.GetNexusCount, lc:GetNexusCount(def), #sg, #sg, def)
        and (not specialchk or specialchk(sg, lc, SUMMON_TYPE_SPECIAL, tp)) and Duel.GetLocationCountFromEx(tp, tp, sg, lc)>0
end

function Nexus.CheckRecursive(c, tp, def, sg, mg, lc, minc, maxc, f, specialchk, og, emt, filt)
    if #sg>maxc then return false end
    filt=filt or {}
    sg:AddCard(c)
    for _,filt in ipairs(filt) do
        if not filt[2](c, filt[3], tp, sg, mg, lc, filt[1], 1) then
            sg:RemoveCard(c)
            return false
        end
    end
    if not og:IsContains(c) then
        res = aux.CheckValidExtra(c, tp, sg, mg, lc, emt, filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    local res = Nexus.CheckGoal(tp, def, sg, lc, minc, g, specialchk, filt)
        or (#sg<maxc and mg:IsExists(Nexus.CheckRecursive, 1, sg, tp, def, sg, mg, lc, minc, maxc, f, specialchk, og, emt, {table.unpack(filt)}))
        sg:RemoveCard(c)
        return res
end
function Nexus.CheckRecursive2(c, tp, def, sg, sg2, secondg, mg, lc, minc, maxc, f, specialchk, og, emt, filt)
    if #sg>maxc then return false end
    sg:AddCard(c)
    for _,filt in ipairs(filt) do
        if not filt[2](c, filt[3], tp, sg, mg, lc, filt[1], 1) then
            sg:RemoveCard(c)
            return false
        end
    end
    if not og:IsContains(c) then
        res = aux.CheckValidExtra(c, tp, sg, mg, lc, emt, filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    if #(sg2 - sg) == 0 then
        if secondg and #secondg>0 then
            local res = secondg:IsExists(Nexus.CheckRecursive, 1, sg, tp, def, sg, mg, lc, minc, maxc, f, specialchk, og, emt, {table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        else
            local res = Nexus.CheckGoal(tp, def, sg, lc, minc, f, specialchk, {table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        end
    end
    local res=Nexus.CheckRecursive2((sg2-sg):GetFirst(), tp, def, sg, sg2, secondg, mg, lc, minc, maxc, f, specialchk, og, emt, filt)
    sg:RemoveCard(c)
    return res
end

function Nexus.Condition(f, def, minc, maxc, specialchk)
    return function(e, c, must, g, min, max)
        if c==nil then return true end
        if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
        local tp=c:GetControler()
        if not g then
            g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
        end
        local mg = g:Filter(Nexus.ConditionFilter, nil, def, f, c, tp)
        local mustg = Auxiliary.GetMustBeMaterialGroup(tp, g, tp, c, mg, REASON_NEXUS)
        if must then mustg:Merge(must) end
        if min and min < minc then return false end
        if max and max > maxc then return false end
        min = min or minc
        max = max or maxc
        if mustg:IsExists(aux.NOT(Nexus.ConditionFilter), 1, nil, def, f, c, tp) or #mustg>max then return false end
        local emt, tg = aux.GetExtraMaterials(tp, mustg+mg, c, SUMMON_TYPE_NEXUS)
        tg:Match(Nexus.ConditionFilter, nil, def, f, c, tp)
        local mg_tg = mg+tg
        local res = mg_tg:Includes(mustg) and #mustg<=max
        if res then
            if #mustg==max then
                local sg = Group.CreateGroup()
                res = mustg:IsExists(Nexus.CheckRecursive, 1, sg, tp, def, sg, mg_tg, c, min, max, f, specialchk, mg, emt)
            elseif #mustg<max then
                local sg = mustg
                res = mg_tg:IsExists(Nexus.CheckRecursive, 1, sg, tp, def, sg, mg_tg, c, min, max, f, specialshk, mg, emt)
            end
        end
        aux.DeleteExtraMaterialGroups(emt)
        return res
    end
end

function Nexus.Target(f, def, minc, maxc, specialchk)
    return function(e, tp, eg, ep, ev, re, r, rp, chk, c, must, g, min, max)
        if not g then
            g=Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
        end
        if min and min < minc then return false end
        if max and max < maxc then return false end
        min = min or minc
        max = max or maxc
        local mg = g:Filter(Nexus.ConditionFilter, nil, def, f, c, tp)
        local mustg = Auxiliary.GetMustBeMaterialGroup(tp, g, tp, c, mg, REASON_NEXUS)
        if must then mustg:Merge(must) end
        local emt, tg = aux.GetExtraMaterials(tp, mustg + mg, c, SUMMON_TYPE_NEXUS)
        tg:Match(Nexus.ConditionFilter, nil, def, f, c, tp)
        local sg = Group.CreateGroup()
        local finish = false
        local cancel = false
        sg:Merge(mustg)
        local mg_tg = mg + tg
        while #sg < max do
            local filters={}
            if #sg > 0 then
                Nexus.CheckRecursive2(sg:GetFirst(), tp, def, Group.CreateGroup(), sg, mg_tg, mg_tg, c, min, max, g, specialchk, mg, emt, filters)
            end
            local cg = mg_tg:Filter(Nexus.CheckRecursive, sg, tp, def, sg, mg_tg, c, min, max, f, specialchk, mg, emt, {table.unpack(filters)})
            if #cg == 0 then break end
            finish = #sg >= min and #sg <= max and Nexus.CheckGoal(tp, def, sg, c, min, f, specialchk, filters)
            cancel = not og and Duel.IsSummonCancelable() and #sg == 0
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NMATERIAL)
            local tc = Group.SelectUnselect(cg, sg, tp, finish, cancel, 1, 1)
            if not tc then break end
            if #mustg == 0 or not mustg:IsContains(tc) then
                if not sg:IsContains(tc) then
                    sg:AddCard(tc)
                else
                    sg:RemoveCard(tc)
                end
            end
        end
        if #sg > 0 then
            local filters={}
            Nexus.CheckRecursive2(sg:GetFirst(), tp, def, Group.CreateGroup(), sg, mg_tg, mg_tg, c, min, max, f, specialchk, mg, emt, filters)
            sg:KeepAlive()
            e:SetLabelObject({sg, filters, emt})
            return true
        else
            aux.DeleteExtraMaterialGroups(emt)
            return false
        end
    end
end

function Nexus.Operation(f, def, minc, maxc, specialchk)
    return function(e, tp, eg, ep, ev, re, r, rp, c, must, g, min, max)
        local g, filt, emt=table.unpack(e:GetLabelObject())
        for _,ex in ipairs(filt) do
            if ex[3]:GetValue() then
                ex[3]:GetValue()(1, SUMMON_TYPE_SPECIAL, ex[3], ex[1]&g, c, tp)
            end
        end
        c:SetMaterial(g)
        Duel.SendtoGrave(g, REASON_MATERIAL+REASON_NEXUS)
        g:DeleteGroup()
        aux.DeleteExtraMaterialGroups(emt)
    end
end