  --Malefic Eye of Timaeus
  local s, id=GetID()
  function s.initial_effect(c)
	  --Activate
	  local e1=Effect.CreateEffect(c)
	  e1:SetCategory(CATEGORY_REMOVE)
	  e1:SetType(EFFECT_TYPE_ACTIVATE)
	  e1:SetCode(EVENT_FREE_CHAIN)
	  e1:SetTarget(s.target)
	  e1:SetOperation(s.operation)
	  c:RegisterEffect(e1)
	  --Change Code
	  local e2=Effect.CreateEffect(c)
	  e2:SetType(EFFECT_TYPE_SINGLE)
	  e2:SetCode(EFFECT_CHANGE_CODE)
	  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	  e2:SetRange(LOCATION_FZONE+LOCATION_HAND+LOCATION_GRAVE)
	  e2:SetValue(27564031)
	  c:RegisterEffect(e2)
	  --Immune
	  local e3=Effect.CreateEffect(c)
	  e3:SetType(EFFECT_TYPE_SINGLE)
	  e3:SetCode(EFFECT_IMMUNE_EFFECT)
	  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	  e3:SetRange(LOCATION_FZONE)
	  e3:SetValue(s.imfilter)
	  c:RegisterEffect(e3)
	 --Malefic Change
	 local e4=Effect.CreateEffect(c)
	 e4:SetType(EFFECT_TYPE_FIELD)
	 e4:SetCode(75223115)
	 e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	 e4:SetTargetRange(1,1)
	 e4:SetRange(LOCATION_FZONE)
	 c:RegisterEffect(e4)
	 --Unaffected
	 local e5=Effect.CreateEffect(c)
	 e5:SetType(EFFECT_TYPE_FIELD)
	 e5:SetCode(EFFECT_IMMUNE_EFFECT)
	 e5:SetTargetRange(LOCATION_MZONE,0)
	 e5:SetRange(LOCATION_FZONE)
	 e5:SetCondition(function(e) return Duel.IsBattlePhase() end)
	 e5:SetTarget(function(e,c) return c:IsSetCard(0x23) end)
	 e5:SetValue(s.immval)
	 c:RegisterEffect(e5)
  end
  
  function s.filter(c, e)
	 if c:IsLocation(LOCATION_FZONE) and not c:IsAbleToGraveAsCost() then return false end
	  return c:IsCode(27564031) and c:IsAbleToRemove() and c~=e:GetHandler()
  end
  function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	  if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD, 0, 1, nil, e) end
	  Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD)
  end
  function s.operation(e, tp, eg, ep, ev, re, r, rp)
	  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	  local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD, 0, 1, 1, nil, e)
	  if #g>0 then
		  Duel.Remove(g, POS_FACEUP, REASON_COST)
	  end
  end
  
  function s.imfilter(e, te)
	  return te:GetOwner()~=e:GetOwner()
  end
  function s.immval(e,te)
	 return e:GetHandler()~=te:GetHandler()
 end
 