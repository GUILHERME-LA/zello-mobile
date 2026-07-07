// ============================================================
// ZELLO - Edge Function: Análise de Convênio com IA
// Chama a API Anthropic (Claude Sonnet 4) para analisar planos
// de saúde e recomendar hospitais.
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

interface AnalysisRequest {
  provider: string;
  planName: string;
  planType: string;
  symptoms: string;
  state: string;
}

interface Hospital {
  name: string;
  address: string;
  phone: string;
  specialties: string[];
  acceptsPlan: boolean;
  rating: number;
}

interface PlanAnalysis {
  currentPlan: string;
  recommendation: "manter" | "upgrade" | "downgrade";
  justification: string;
  suggestedPlanType: string;
  estimatedCostImpact: string;
}

interface AnalysisResponse {
  hospitals: Hospital[];
  planAnalysis: PlanAnalysis;
}

serve(async (req: Request) => {
  // CORS headers
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json",
  };

  // Handle preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  // Only accept POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método não permitido" }),
      { status: 405, headers }
    );
  }

  try {
    const body: AnalysisRequest = await req.json();

    // Validate required fields
    if (!body.provider || !body.planName) {
      return new Response(
        JSON.stringify({ error: "Operadora e plano são obrigatórios" }),
        { status: 400, headers }
      );
    }

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "API key da Anthropic não configurada" }),
        { status: 500, headers }
      );
    }

    // Build the prompt in Portuguese
    const systemPrompt = `Você é um especialista brasileiro em planos de saúde e rede hospitalar.
Sua função é analisar convênios médicos e recomendar hospitais com base no plano e nas condições de saúde do paciente.

Você DEVE responder APENAS com um JSON válido, sem texto adicional, seguindo este schema exato:
{
  "hospitals": [
    {
      "name": "Nome do Hospital",
      "address": "Endereço completo",
      "phone": "Telefone com DDD",
      "specialties": ["Especialidade1", "Especialidade2"],
      "acceptsPlan": true,
      "rating": 4.5
    }
  ],
  "planAnalysis": {
    "currentPlan": "Análise do plano atual em português",
    "recommendation": "manter" | "upgrade" | "downgrade",
    "justification": "Justificativa detalhada em português",
    "suggestedPlanType": "Tipo de plano sugerido (ex: Apartamento, Premium, Enfermaria)",
    "estimatedCostImpact": "Impacto estimado no custo (ex: R$ 200-400/mês a mais)"
  }
}

Regras importantes:
1. Liste apenas hospitais REAIS que existem no estado informado e que aceitam o plano informado.
2. Seja honesto sobre a cobertura: se o plano não cobre determinados procedimentos, mencione.
3. A recommendation deve ser "manter" se o plano já atende as necessidades, "upgrade" se precisa de um plano mais caro, ou "downgrade" se um plano mais barato seria suficiente.
4. Inclua HOTÉIS HOSPITALARES e não apenas grandes hospitais.
5. O rating deve ser de 0 a 5.
6. Responda APENAS com o JSON, sem texto antes ou depois.`;

    const userPrompt = `Analise o seguinte caso:

OPERADORA: ${body.provider}
NOME DO PLANO: ${body.planName}
TIPO DO PLANO: ${body.planType || "Não informado"}
ESTADO: ${body.state || "Não informado"}
CONDIÇÕES DE SAÚDE / SINTOMAS: ${body.symptoms || "Não informado"}

Com base nestas informações:
1. Quais hospitais no estado ${body.state || "do Brasil"} aceitam este plano e são recomendados?
2. O plano atual é suficiente para as condições relatadas?
3. O paciente deveria fazer upgrade, downgrade ou manter o plano?`;

    // Call Anthropic API
    const anthropicResponse = await fetch(
      "https://api.anthropic.com/v1/messages",
      {
        method: "POST",
        headers: {
          "x-api-key": apiKey,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 4096,
          system: systemPrompt,
          messages: [
            {
              role: "user",
              content: userPrompt,
            },
          ],
        }),
      }
    );

    if (!anthropicResponse.ok) {
      const errorText = await anthropicResponse.text();
      return new Response(
        JSON.stringify({
          error: "Erro ao consultar IA",
          details: errorText,
        }),
        { status: 502, headers }
      );
    }

    const anthropicData = await anthropicResponse.json();
    const content = anthropicData.content?.[0]?.text;

    if (!content) {
      return new Response(
        JSON.stringify({ error: "Resposta vazia da IA" }),
        { status: 502, headers }
      );
    }

    // Parse the JSON from Claude's response
    // It might be wrapped in markdown code blocks, so we extract it
    let jsonStr = content;
    const jsonMatch = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      jsonStr = jsonMatch[1];
    }

    const result: AnalysisResponse = JSON.parse(jsonStr);

    // Validate the result structure
    if (!result.hospitals || !result.planAnalysis) {
      return new Response(
        JSON.stringify({
          error: "Resposta da IA em formato inválido",
          rawResponse: content,
        }),
        { status: 502, headers }
      );
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: "Erro interno do servidor",
        details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers }
    );
  }
});
