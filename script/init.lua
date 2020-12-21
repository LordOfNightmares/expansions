EFFECT_FLAG2_AVAILABLE_BD=0x2000000 --The effect is also applicable when the battle damage is confirmed
PENDULUM_CHECKLIST=Auxiliary.PendulumChecklist
RACE_DIVINE=0x200000
-- RUSH_EVENT=EVENT_CUSTOM+515959000 --necessary for rush summoning
--Mega RegisterEffect
function Auxiliary.RegisterEffect(e,c,tp)
    c:RegisterEffect(e)
    Duel.RegisterEffect(e,tp)
end
--GetID implementation
function GetID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return cod,id
end
function getID() return GetID() end
function getid() return GetID() end
function count(base, pattern)
    return select(2, string.gsub(base, pattern, ""))
end
function int2bin(n)
  local result = {}
  while n ~= 0 do
    if n % 2 == 0 then
      result[#result+1] = '0'
    else
      result[#result+1] = '1'
    end
    n = math.floor(n / 2)
  end
  return table.concat(result)
end
--Global Card Effect Table
if not global_card_effect_table_global_check then
--[[Example
    function cannot_prevention(e,c)
      if global_card_effect_table[c] then
            for key,value in pairs(global_card_effect_table[c]) do
                if (value:GetCode()==EFFECT_CANNOT_ACTIVATE 
                 or value:GetCode()==EFFECT_DISABLE)
                and value:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) 
                and value:GetType()==EFFECT_TYPE_FIELD then
                 Debug.Message(c:GetCode())
                 return c
                end
            end
        end 
    end]]
    global_card_effect_table_global_check=true
    global_card_effect_table={}
    Card.register_global_card_effect_table = Card.RegisterEffect
    function Card:RegisterEffect(e)
        if not global_card_effect_table[self] then global_card_effect_table[self]={} end
        table.insert(global_card_effect_table[self],e)
        self.register_global_card_effect_table(self,e)
    end
end
--MasterRule
local function masterRule(tp)
    --check for negations
    local e0=Effect.GlobalEffect()
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_CHAINING)
    e0:SetTargetRange(1,0)
    e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
                        if (re:IsActiveType(TYPE_MONSTER) 
                                or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))  
                            and (re:IsHasCategory(CATEGORY_DISABLE_SUMMON) 
                                or re:IsHasCategory(CATEGORY_NEGATE)
                                or re:IsHasCategory(CATEGORY_DISABLE)) then
                            Duel.RegisterFlagEffect(rp,5159590001,RESET_PHASE+PHASE_END,0,0)
                        end
                    end)
    Duel.RegisterEffect(e0,tp)
    --cannot negate
    local e01=Effect.GlobalEffect()
    e01:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e01:SetCode(EFFECT_CANNOT_ACTIVATE)
    e01:SetTargetRange(1,0)
    e01:SetValue(function(e,re,rp,tp)
                    local turn=Duel.GetTurnCount()
                    local val=math.floor(turn/2)+1
                    return (re:IsActiveType(TYPE_MONSTER) 
                    or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))  
                    and re:IsHasCategory(CATEGORY_NEGATE+CATEGORY_DISABLE+CATEGORY_DISABLE_SUMMON)
                    and (Duel.GetFlagEffect(rp,5159590001) >= val) and val<=4 
                end)
    Duel.RegisterEffect(e01,tp)
    --Extra to main
    local e1=Effect.GlobalEffect()
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
    e1:SetTargetRange(1,0)
    e1:SetValue(1)
    Duel.RegisterEffect(e1,tp)
    --Extra monsters must not be spsummoned in Extra monster Zone
    local e2=Effect.GlobalEffect()
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_MUST_USE_MZONE)
    e2:SetTargetRange(LOCATION_EXTRA,0)
    e2:SetValue(func_emz)
    Duel.RegisterEffect(e2,tp)
    --redraw
    -- Debug.Message("test")
    local e3=Effect.GlobalEffect()
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCountLimit(1)
    e3:SetCondition(function(e) return Duel.GetTurnCount()==1 end)
    e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
        Duel.SetTargetPlayer(tp)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
    end)
    e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if not Duel.SelectYesNo(tp, aux.Stringid(10000000,3)) then return end
        local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(p,aux.TRUE,p,LOCATION_HAND,0,0,3,nil)
        if g:GetCount()>0 then
            local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
            Duel.ShuffleDeck(p)
            Duel.BreakEffect()
            Duel.Draw(p,ct,REASON_EFFECT)
        end
    end)
    Duel.RegisterEffect(e3,tp)

    -- --Rush Summon
    -- local e3=Effect.GlobalEffect()
    -- e3:SetDescription(aux.Stringid(10000000,2))
    -- e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    -- e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    -- e3:SetCode(EVENT_SUMMON_SUCCESS)
    -- e3:SetTargetRange(LOCATION_HAND,0)
    -- e3:SetCondition(RushCondition)
    -- e3:SetOperation(RushOperation)
    -- Duel.RegisterEffect(e3,tp)
    -- --Limit RushSummon
    -- local espsum=Effect.GlobalEffect()
    -- espsum:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    -- espsum:SetCode(EVENT_SPSUMMON_SUCCESS)
    -- espsum:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(rush_special_summon_fil,1,nil,nil,tp) end)
    -- espsum:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetTargetCard(eg) end)
    -- espsum:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
    --                     local tc=eg:GetFirst()
    --                     while tc do
    --                         local tc_seq=2^tc:GetSequence()
    --                         if tc:GetOwner()~=tp or Duel.GetTurnPlayer()~=tc:GetOwner() then tc_seq=tc_seq<<16 end
    --                         RushSpSequence=RushSpSequence|tc_seq
    --                         -- Debug.Message(string.format("[%s,%s,%s] sp[%s]rs[%s]",tc_seq,RushSequence,RushSpSequence,int2bin(RushSpSequence),int2bin(RushSequence)))
    --                         if tc_seq&RushSequence==tc_seq then
    --                             local e1=Effect.CreateEffect(tc)
    --                             e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
    --                             e1:SetType(EFFECT_TYPE_SINGLE)
    --                             e1:SetCode(EFFECT_DISABLE)
    --                             e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    --                             tc:RegisterEffect(e1)
    --                             local e2=e1:Clone()
    --                             e2:SetCode(EFFECT_DISABLE_EFFECT)
    --                             tc:RegisterEffect(e2)
    --                             if tc:IsType(TYPE_TRAPMONSTER) then
    --                                 local e3=e1:Clone()
    --                                 e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
    --                                 tc:RegisterEffect(e3)
    --                             end
    --                             local espsum=e1:Clone()
    --                             espsum:SetCode(EFFECT_CANNOT_ACTIVATE)
    --                             tc:RegisterEffect(espsum)
    --                         end
    --                         tc=eg:GetNext()
    --                     end
    --                 -- Debug.Message(string.format("n-[%s,%s] seq=%s,amount=%d",RushSpSequence,~RushSpSequence,int2bin(RushSpSequence),count(int2bin(RushSpSequence),0)))
    --                 -- Debug.Message(string.format("s-[%s,%s] seq=%s,amount=%d",RushSequence,~RushSequence,int2bin(RushSequence),count(int2bin(RushSequence),0)))
    --                 end)
    -- Duel.RegisterEffect(espsum,tp)
    -- local eadd=Effect.GlobalEffect()
    -- eadd:SetDescription(aux.Stringid(3113836,0))
    -- eadd:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    -- eadd:SetCode(EVENT_ADJUST)
    -- eadd:SetCondition(function(e,tp) return Duel.GetFlagEffect(tp,5159590002)==0 end)
    -- eadd:SetOperation(function(e,tp)
    --                   RushSequence=0
    --                   RushSpSequence=0
    --                   Duel.RegisterFlagEffect(tp,5159590002,RESET_PHASE+PHASE_END,0,0)
    --                   end)
    -- Duel.RegisterEffect(eadd,tp)
end
-- RushSequence=0
-- RushSpSequence=0
-- function rush_special_summon_fil(c,e,tp)
--     return c:IsControler(tp) and (not e or c:IsRelateToEffect(e)) 
-- end
-- function RushCondition(e,tp,eg,ep,ev,re,r,rp)
--     return Duel.GetFlagEffect(tp,5159590002)==1 and eg:IsExists(rush_special_summon_fil,1,nil,nil,tp) and Duel.IsExistingMatchingCard(RushFilter,tp,LOCATION_HAND,0,1,nil)
-- end
-- function RushCondition2(e,tp,eg,ep,ev,re,r,rp)
--     return eg:IsExists(rush_special_summon_fil,1,nil,nil,tp) and Duel.IsExistingMatchingCard(RushFilter,tp,LOCATION_HAND,0,1,nil)
-- end
-- function RushFilter(c)
--     return c:IsSummonable(true,nil)
-- end
-- function RushOperation(e,tp,eg)
--     local continue = 0
--     if Duel.GetFlagEffect(tp,5159590002)==1 then 
--         if not Duel.SelectYesNo(tp, aux.Stringid(10000000,2)) then return end 
--         -- Duel.Hint(HINT_MESSAGE,1-tp, aux.Stringid(10000000,2))
--         continue=1
--     end
--     Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
--     Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
--     if continue==0 and not Duel.SelectYesNo(tp, aux.Stringid(10000000,3)) then return end 
--     local g=Duel.SelectMatchingCard(tp,RushFilter,tp,LOCATION_HAND,0,0,1,nil)
--     local tc=g:GetFirst()
--     if not tc then Duel.RegisterFlagEffect(tp,5159590002,RESET_PHASE+PHASE_END,0,0) return end
--     if tc then
--         Duel.HintSelection(eg)
--         Duel.RegisterFlagEffect(tp,5159590002,RESET_PHASE+PHASE_END,0,0)
--         local e1=Effect.CreateEffect(tc)
--         e1:SetDescription(aux.Stringid(10000000,2))
--         e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
--         e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
--         e1:SetCode(RUSH_EVENT)
--         e1:SetRange(LOCATION_HAND,0)
--         e1:SetCountLimit(1)
--         e1:SetCondition(RushCondition2)
--         e1:SetOperation(RushOperation)
--         e1:SetReset(RESET_PHASE+PHASE_END)
--         Duel.RegisterEffect(e1,tp)
--         Duel.Summon(tp,tc,true,nil)
--         --cannot special summon
--         local seq=tc:GetSequence()     
--         if tc:GetLocation()~=4 then 
--             seq=tc:GetPreviousSequence()
--         end 
--         if tc:GetControler()~=tp then
--             seq=(2^seq)<<16
--         else
--             seq=2^seq
--         end
--         RushSequence=RushSequence|seq
--         local e2=Effect.CreateEffect(tc)
--         e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
--         e2:SetType(EFFECT_TYPE_SINGLE)
--         e2:SetCode(EFFECT_SPSUMMON_CONDITION)
--         e2:SetValue(aux.FALSE)
--         e2:SetReset(RESET_PHASE+PHASE_END)
--         tc:RegisterEffect(e2,true)
--         Duel.RaiseEvent(g,RUSH_EVENT,re,r,rp,ep,0)
--         -- Duel.RaiseEvent(eg,RUSH_EVENT,e,r,rp,ep,e:GetLabel())
--         -- Debug.Message(string.format("R-[%s,%s] rs[%s]",RushSequence,~RushSequence,int2bin(RushSequence)))
--         -- Debug.Message(string.format("R-[%s,%s] sp[%s]",RushSpSequence,~RushSpSequence,int2bin(RushSpSequence)))
--     end
-- end
function func_linkfil(c,tp)
    return c:GetSequence()>4 and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
function func_emz(e,c,fp,rp,r)
    local lval=0x600060
    local mg=Duel.GetMatchingGroup(func_linkfil,tp,LOCATION_MZONE,0,nil,tp)
    if mg and mg:GetCount()>0 then
        local tc = mg:GetFirst()
        while tc do
          lval=tc:GetLinkedZone()|lval
          tc = mg:GetNext()
        end
    end
    if not c:IsType(TYPE_LINK) then
        return 0x9FFF9F
    else 
        return lval
    end
end
function Auxiliary.extramonsterzonefiter(c)
    return c:GetSequence()>4
end
--pendulum fix for MasterRule
function Auxiliary.PendOperation()
    return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
                local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
                local lscale=c:GetLeftScale()
                local rscale=rpz:GetRightScale()
                if lscale>rscale then lscale,rscale=rscale,lscale end
                local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
                local tg=nil
                local loc=0
                local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
                local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
                local ft=Duel.GetUsableMZoneCount(tp)
                local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
                if ect and ect<ft2 then ft2=ect end
                if not Duel.IsExistingMatchingCard(aux.extramonsterzonefiter,tp,LOCATION_MZONE,0,1,nil) then 
                    ft2=ft2-1
                    ft=ft-1
                end
                if Duel.IsPlayerAffectedByEffect(tp,59822133) then
                    if ft1>0 then ft1=1 end
                    if ft2>0 then ft2=1 end
                    ft=1
                end
                if ft1>0 then loc=loc|LOCATION_HAND end
                if ft2>0 then loc=loc|LOCATION_EXTRA end
                if og then
                    tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
                else
                    tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
                end
                local ce=nil
                local b1=Auxiliary.PendulumChecklist&(0x1<<tp)==0
                local b2=#eset>0
                if b1 and b2 then
                    local options={1163}
                    for _,te in ipairs(eset) do
                        table.insert(options,te:GetDescription())
                    end
                    local op=Duel.SelectOption(tp,table.unpack(options))
                    if op>0 then
                        ce=eset[op]
                    end
                elseif b2 and not b1 then
                    local options={}
                    for _,te in ipairs(eset) do
                        table.insert(options,te:GetDescription())
                    end
                    local op=Duel.SelectOption(tp,table.unpack(options))
                    ce=eset[op+1]
                end
                if ce then
                    tg=tg:Filter(Auxiliary.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
                end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                Auxiliary.GCheckAdditional=Auxiliary.PendOperationCheck(ft1,ft2,ft)
                local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
                Auxiliary.GCheckAdditional=nil
                if not g then return end
                if ce then
                    Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
                    ce:Reset()
                else
                    Auxiliary.PendulumChecklist=Auxiliary.PendulumChecklist|(0x1<<tp)
                end
                sg:Merge(g)
                Duel.HintSelection(Group.FromCards(c))
                Duel.HintSelection(Group.FromCards(rpz))
            end
end
--MasterRule activation
if Duel.GetFlagEffect(0,515959000)==0 then
    masterRule(0)
    Duel.RegisterFlagEffect(0,515959000,0,0,1)
end
if Duel.GetFlagEffect(1,515959000)==0 then
    masterRule(1)
    Duel.RegisterFlagEffect(1,515959000,0,0,1)
end
