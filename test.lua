local test = {}
----Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, Vector(Enum.UnitOrder.DOTA_UNIT_ORDER_NONE), detonate, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, mine)
local enable = Menu.AddOptionBool({"Test"}, "Test", false)

function test.OnUpdate()
	if not Menu.IsEnabled(enable) or not Engine.IsInGame() or not Heroes.GetLocal() then return end
	local myHero = Heroes.GetLocal()
	test.Work(myHero)
end

function test.Work(myHero)
	for _, h in pairs(Heroes.GetAll()) do
		if Entity.IsAlive(h) and not Entity.IsSameTeam(myHero, h) and not NPC.IsIllusion(h) and NPC.IsVisible(h) then
			local unitsInRadius = Entity.GetUnitsInRadius(h, 420, Enum.TeamType.TEAM_ENEMY)
			local mines = {}
			local mineAbility = {}
			local mineCount = 0
			if unitsInRadius then
				for _, mine in pairs(unitsInRadius) do
					if NPC.GetUnitName(mine) ==  "npc_dota_techies_remote_mine" and Ability.IsCastable(NPC.GetAbilityByIndex(mine, 0), 0)then
						local detonate = NPC.GetAbilityByIndex(mine, 0)
						table.insert(mineAbility, detonate)
						table.insert(mines, mine)
						mineCount = mineCount+1
					end
				end
				if mineCount >= test.GetMinesForKill(myHero, h) then
					for i = 0, test.GetMinesForKill(myHero, h) do
						Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, Vector(Enum.UnitOrder.DOTA_UNIT_ORDER_NONE), mineAbility[i], Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, mines[i])
					end
				end
			end
		end
	end
end

function test.GetMinesForKill(myHero, npc)
	local defDMG = Ability.GetLevelSpecialValueForFloat(NPC.GetAbilityByIndex(myHero, 5), "damage")
	if NPC.HasItem(myHero, "item_ultimate_scepter") then
		defDMG = defDMG + 150
	end
	defDMG = defDMG*NPC.GetMagicalArmorDamageMultiplier(npc)
	return math.ceil(Entity.GetHealth(npc)/defDMG)
end
--Entity.GetHealth(h)
return test
