--super ra
local m=10000010
local cm=_G["c"..m]
function cm.initial_effect(c)
    --inactivatable
    local e01=Effect.CreateEffect(c)
    e01:SetType(EFFECT_TYPE_SINGLE)
    e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e01:SetCode(EFFECT_CANNOT_INACTIVATE)
    e01:SetValue(cm.efilter)
    aux.RegisterEffect(e01,c,tp)
    local e02=e01:Clone()
    e02:SetCode(EFFECT_CANNOT_DISEFFECT)
    aux.RegisterEffect(e02,c,tp)
    local e03=e01:Clone()
    e03:SetCode(EFFECT_CANNOT_DISABLE)
    aux.RegisterEffect(e03,c,tp)
    --summon with 3 tribute
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    e1:SetCondition(cm.ttcon)
    e1:SetOperation(cm.ttop)
    e1:SetValue(SUMMON_TYPE_ADVANCE)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LIMIT_SET_PROC)
    e2:SetCondition(cm.setcon)
    c:RegisterEffect(e2)
    --summon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e3)
    --summon success
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetOperation(cm.sumsuc)
    c:RegisterEffect(e4)
    --tribute check
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(cm.valcheck)
    c:RegisterEffect(e6)
    --give atk effect only when tribute summon
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_SUMMON_COST)
    e7:SetOperation(cm.facechk)
    e7:SetLabelObject(e6)
    c:RegisterEffect(e7)
    --destroy
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(m,1))
    e8:SetCategory(CATEGORY_DESTROY)
    e8:SetType(EFFECT_TYPE_IGNITION)
    -- e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CARD_TARGET)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCost(cm.descost)
    e8:SetTarget(cm.destg)
    e8:SetOperation(cm.desop)
    c:RegisterEffect(e8)
    --LP to Base ATK/DEF
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(m,2))
    e9:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    -- e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e9:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetCost(cm.atkcost)
    e9:SetOperation(cm.atkop)
    c:RegisterEffect(e9)
    --to grave
    local e11=Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(m,0))
    e11:SetCategory(CATEGORY_TOGRAVE)
    -- e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e11:SetRange(LOCATION_MZONE)
    e11:SetCountLimit(1)
    e11:SetCode(EVENT_PHASE+PHASE_END)
    e11:SetCondition(cm.tgcon)
    e11:SetTarget(cm.tgtg)
    e11:SetOperation(cm.tgop)
    c:RegisterEffect(e11)
    -- --summon success reg
    -- local e12=Effect.CreateEffect(c)
    -- e12:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    -- e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    -- e12:SetCode(EVENT_SPSUMMON_SUCCESS)
    -- e12:SetOperation(cm.spsumsuc)
    -- c:RegisterEffect(e12)
    -- e12:SetLabelObject(e11)
end
function cm.ttcon(e,c,minc)
    if c==nil then return true end
    return minc<=3 and Duel.CheckTribute(c,3)
end
function cm.ttop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectTribute(tp,c,3,3)
    c:SetMaterial(g)
    Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
function cm.setcon(e,c,minc)
    if not c then return true end
    return false
end
function cm.genchainlm(c)
    return  function (e,rp,tp)
                return e:GetHandler()==c
            end
end
function cm.sumsuc(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetChainLimitTillChainEnd(cm.genchainlm(e:GetHandler()))
end
function cm.efilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    return te:GetHandler()==e:GetHandler()
end
function cm.facechk(e, tp, eg, ep, ev, re, r, rp)
    e:GetLabelObject():SetLabel(1)
end
function cm.valcheck(e,c)
    local g=c:GetMaterial()
    local tc=g:GetFirst()
    local atk=0
    local def=0
    while tc do
        local catk=tc:GetTextAttack()
        local cdef=tc:GetTextDefense()
        atk=atk+(catk>=0 and catk or 0)
        def=def+(cdef>=0 and cdef or 0)
        tc=g:GetNext()
    end
    if e:GetLabel()==1 then
        e:SetLabel(0)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+0xff0000)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE)
        e2:SetValue(def)
        c:RegisterEffect(e2)
    end
end
function cm.adop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local mg=c:GetMaterial()
    local atk=mg:GetSum(Card.GetTextAttack)
    local def=mg:GetSum(Card.GetTextDefense)
    if atk>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
    if def>0 then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetValue(def)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
    end
end
function cm.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    Duel.SetChainLimit(aux.FALSE)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function cm.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLP(tp)>100 end
    local lp=Duel.GetLP(tp)
    e:SetLabel(lp-100)
    Duel.PayLPCost(tp,lp-100)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_SET_BASE_ATTACK)
        e1:SetValue(e:GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_BASE_DEFENSE)
        c:RegisterEffect(e2)
    end
end
function cm.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and not (e:GetHandler():GetFlagEffect(m)>0) --and e:GetLabel()==100
end 
function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
    Duel.SetChainLimit(aux.FALSE)
end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end
-- function cm.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
--     -- not (not not re and re:GetHandler():IsRace(RACE_DIVINE))
--     if not (e:GetHandler():GetFlagEffect(m)>0) then
--         e:GetLabelObject():SetLabel(100)
--     else
--         e:GetLabelObject():SetLabel(1)
--     end
-- end