 --Black Rose Magician Girl
 local s,id=GetID()
 function s.initial_effect(c)
 	--contact fusion
 	c:EnableReviveLimit()
 	Fusion.AddProcMix(c,true,true,38033121,73580471)
 	Fusion.AddContactProc(c,s.contactfil,c.contactop,s.splimit,nil,nil,nil,false)
 end
