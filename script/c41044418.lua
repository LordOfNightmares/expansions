--千年の啓示
function c41044418.initial_effect(c)
	aux.AddCodeList(c,10000010)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41044418,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,41044418)
	e1:SetCost(c41044418.thcost)
	e1:SetTarget(c41044418.thtg)
	e1:SetOperation(c41044418.thop)
	c:RegisterEffect(e1)
	--togy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41044418,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,41044418+100)
	e2:SetOperation(c41044418.rbop1)
	c:RegisterEffect(e2)
	--keep on field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetDescription(aux.Stringid(41044418,2))
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,41044418+101)
	e3:SetCondition(c41044418.rbcon2)
	e3:SetTarget(c41044418.rbtg2)
	e3:SetOperation(c41044418.rbop2)
	c:RegisterEffect(e3)
end
function c41044418.costfilter(c)
	return c:IsRace(RACE_DIVINE) and c:IsAbleToGraveAsCost()
end
function c41044418.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c41044418.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c41044418.thfilter(c)
	return c:IsCode(83764718) and c:IsAbleToHand()
end
function c41044418.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c41044418.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41044418.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c41044418.rbop1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGrave() end
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
function c41044418.rbfilt(c)
	return c:IsCode(10000000) or c:IsCode(10000010) or c:IsCode(10000020)
end
function c41044418.rbcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c41044418.rbtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c41044418.rbfilt,tp,LOCATION_MZONE,0,1,nil) end
	-- if chk==0 then return Duel.GetFlagEffect(tp,41044418)==0 end
end
function c41044418.rbop2(e,tp,eg,ep,ev,re,r,rp)
	-- if Duel.GetFlagEffect(tp,41044418)~=0 then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c41044418.rbfilt,tp,LOCATION_MZONE,0,nil,tp)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD,0,0)	
		tc=g:GetNext()
	end
	-- --rebirth
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetType(EFFECT_TYPE_FIELD)
	-- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e1:SetCode(41044418)
	-- e1:SetTargetRange(1,0)
	-- e1:SetReset(RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(e1,tp)
	-- --to grave
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e2:SetCode(EVENT_PHASE+PHASE_END)
	-- e2:SetCountLimit(1)
	-- e2:SetCondition(c41044418.tgcon)
	-- e2:SetOperation(c41044418.tgop)
	-- e2:SetReset(RESET_PHASE+PHASE_END)
	-- Duel.RegisterEffect(e2,tp)
	-- Duel.RegisterFlagEffect(tp,41044418,RESET_PHASE+PHASE_END,0,1)
end
-- function c41044418.tgfilter(c)
-- 	return c:IsFaceup() and c:IsCode(10000010) and c:IsSummonType(SUMMON_TYPE_SPECIAL+200)
-- end
-- function c41044418.tgcon(e,tp,eg,ep,ev,re,r,rp)
-- 	return Duel.IsExistingMatchingCard(c41044418.tgfilter,tp,LOCATION_MZONE,0,1,nil)
-- end
-- function c41044418.tgop(e,tp,eg,ep,ev,re,r,rp)
-- 	local g=Duel.GetMatchingGroup(c41044418.tgfilter,tp,LOCATION_MZONE,0,nil)
-- 	Duel.HintSelection(g)
-- 	Duel.SendtoGrave(g,REASON_RULE)
-- end
