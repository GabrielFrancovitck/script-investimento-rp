
-----------------------------------------------------------------------------------------------------------------------------------------
--Author@GabrielFranco
--https://github.com/GabrielFrancovitck
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- Configurações
local investimentoInicial = 10000 -- Valor fixo para investir
local taxaDeRetorno = 0.05 -- Taxa de retorno diária (10%)
local tempoDeInvestimento = 7 -- Tempo de investimento em dias
local chanceFalha = 0.2 -- Chance de falha do investimento (20%)

-- Tabela para armazenar os tempos de uso do comando para cada jogador
local cooldowns = {}

-- Tabela para armazenar o histórico de investimentos
local historicoInvestimentos = {}

-- Função para calcular o retorno do investimento
function calcularRetornoInvestimento(investimento, taxa, tempo)
  local retorno = investimento * taxa * tempo
  return investimento + retorno
end

-- Comando para o jogador investir seu dinheiro
RegisterCommand("franco", function(source, args)
  local player = source
  local user_id = vRP.getUserId(player)

  -- Verificar se o jogador tem dinheiro suficiente para investir
  if user_id then
    local currentMoney = vRP.getMoney(user_id)
    
    if currentMoney >= investimentoInicial then
      -- Verificar se o jogador está no cooldown
      if cooldowns[user_id] and os.time() < cooldowns[user_id] then
        -- Ainda está no cooldown, notificar o jogador
        local timeRemaining = cooldowns[user_id] - os.time()
        TriggerClientEvent("Notify", player, "negado", "Você precisa aguardar mais " .. timeRemaining .. " segundos antes de usar esse comando novamente.")
      else
        -- Gerar um número aleatório entre 0 e 1
        local randomValue = math.random()

        -- Verificar se o investimento falha
        if randomValue < chanceFalha then
          -- Investimento falhou, jogador perde o dinheiro
          vRP.tryPayment(user_id, investimentoInicial)
          TriggerClientEvent("Notify", player, "negado", "Seu investimento falhou. Você perdeu R$" .. investimentoInicial .. ".")
          
          -- Adicionar o investimento falho ao histórico
          local dataInvestimento = os.date("%Y-%m-%d %H:%M:%S") -- Data atual
          local investimento = {
            valor = investimentoInicial,
            retorno = 0,
            data = dataInvestimento,
            sucedido = false
          }
          table.insert(historicoInvestimentos, investimento)
        else
          -- Investimento bem-sucedido, calcular o retorno
          local valorFinal = calcularRetornoInvestimento(investimentoInicial, taxaDeRetorno, tempoDeInvestimento)
          vRP.tryPayment(user_id, investimentoInicial)
          vRP.giveMoney(user_id, valorFinal)
          TriggerClientEvent("Notify", player, "sucesso", "Você investiu R$" .. investimentoInicial .. " e recebeu um retorno de R$" .. (valorFinal - investimentoInicial) .. " em " .. tempoDeInvestimento .. " dias.")

          -- Adicionar o investimento ao histórico
          local dataInvestimento = os.date("%Y-%m-%d %H:%M:%S") -- Data atual
          local investimento = {
            valor = investimentoInicial,
            retorno = valorFinal - investimentoInicial,
            data = dataInvestimento,
            sucedido = true
          }
          table.insert(historicoInvestimentos, investimento)
        end

        -- Definir o novo tempo de cooldown para 24 horas
        cooldowns[user_id] = os.time() + 24 * 60 * 60
      end
    else
      -- O jogador não tem dinheiro suficiente para investir
      TriggerClientEvent("Notify", player, "negado", "Você não tem dinheiro suficiente para investir.")
    end
  end
end)

    -- Comando para exibir o histórico de investimentos
RegisterCommand("historicoinvestimentos", function(source, args)
  local player = source
  local user_id = vRP.getUserId(player)
  
  -- Verificar se o jogador tem permissão para visualizar o histórico
  if user_id then
    -- Verificar se há investimentos no histórico
    if #historicoInvestimentos > 0 then
      -- Enviar uma mensagem para o jogador com cada investimento
      for i, investimento in ipairs(historicoInvestimentos) do
        local mensagem = "^3^*[Histórico de Investimentos]^7 Investimento #" .. i .. ": Valor: R$" .. investimento.valor .. ", Retorno: R$" .. investimento.retorno .. ", Data: " .. investimento.data
        if investimento.sucedido then
          mensagem = mensagem .. " (Bem-sucedido)"
        else
          mensagem = mensagem .. " (Mal-sucedido)"
        end
        TriggerClientEvent("chatMessage", player, "", {255, 255, 0}, mensagem)
      end
    else
      -- Não há investimentos no histórico
      TriggerClientEvent("chatMessage", player, "", {255, 255, 0}, "^3^*[Histórico de Investimentos]^7 Nenhum investimento registrado.")
    end
  end
end)


--Author@GabrielFranco
--https://github.com/GabrielFrancovitck