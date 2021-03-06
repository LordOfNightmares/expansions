--墓穴の指名者
function c24224830.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24224830.target)
	e1:SetOperation(c24224830.activate)
	c:RegisterEffect(e1)
end
function c24224830.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c24224830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24224830.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c24224830.filter,tp,0,LOCATION_GRAVE,1,nil) 
		and Duel.IsExistingTarget(c24224830.filter,1-tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	
end
function c24224830.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectTarget(tp,c24224830.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	local g1=Duel.SelectTarget(1-tp,c24224830.filter,1-tp,0,LOCATION_GRAVE,1,1,nil)
	g:Merge(g1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,0)
	local tc=g:GetFirst()--Duel.GetFirstTarget()
	while tc do
		if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetTarget(c24224830.distg)
			e1:SetLabel(tc:GetOriginalCode())
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(c24224830.discon)
			e2:SetOperation(c24224830.disop)
			e2:SetLabel(tc:GetOriginalCode())
			e2:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e2,tp)
		end
		tc=g:GetNext()
	end
end
function c24224830.distg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function c24224830.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsActiveType(TYPE_MONSTER) and (code1==code or code2==code)
end
function c24224830.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
