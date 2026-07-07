// ============================================================
// ZELLO - Edge Function: Análise de Prontuário com IA
// Chama a API Anthropic (Claude Sonnet 4) para analisar todo
// o histórico de saúde do paciente e gerar recomendações.
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

interface ProntuarioRequest {
  profile: {
    weight: number;
    height: number;
    bloodType: string;
    medicalConditions: string;
    familyHistory: string;
    chronicConditions: string;
    medications: string;
  };
  surgeries: Array<{
    name: string;
    date: string;
    hospital: string;
    doctor: string;
    notes: string;
  }>;
  hospitalizations: Array<{
    reason: string;
    hospital: string;
    startDate: string;
    endDate: string;
    notes: string;
  }>;
  symptoms: Array<{
    name: string;
    frequency: string;
    intensity: string;
    notes: string;
  }>;
  allergies: Array<{
    name: string;
    type: string;
    reaction: string;
    notes: string;
  }>;
  vaccines: Array<{
    name: string;
    date: string;
    dose: string;
    location: string;
    notes: string;
    isPending: boolean;
  }>;
}

interface ProntuarioResponse {
  summary: string;
  attentionPoints: string[];
  suggestions: string[];
  preventiveCare: string[];
  lifestyleRecommendations: string[];
  overallRisk: "baixo" | "moderado" | "alto";
}

serve(async (req: Request) => {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método não permitido" }),
      { status: 405, headers }
    );
  }

  try {
    const body: ProntuarioRequest = await req.json();

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "API key da Anthropic não configurada" }),
        { status: 500, headers }
      );
    }

    // Monta o texto do prontuário para enviar ao Claude
    const prontuarioText = formatProntuario(body);

    const systemPrompt = `Você é um médico assistente especialista em análise de prontuários no Brasil.
Sua função é analisar o histórico completo de saúde de um paciente e gerar um relatório detalhado.

Você DEVE responder APENAS com um JSON válido, sem texto adicional, seguindo este schema exato:
{
  "summary": "Resumo geral do estado de saúde do paciente em português, destacando os pontos mais relevantes.",
  "attentionPoints": [
    "Lista de pontos que merecem atenção médica imediata ou prioritária"
  ],
  "suggestions": [
    "Lista de sugestões de exames, consultas ou procedimentos recomendados"
  ],
  "preventiveCare": [
    "Lista de cuidados preventivos baseados no perfil e histórico"
  ],
  "lifestyleRecommendations": [
    "Lista de recomendações de estilo de vida (alimentação, exercícios, etc.)"
  ],
  "overallRisk": "baixo | moderado | alto"
}

Regras importantes:
1. Seja honesto e ético: não invente condições ou recomende procedimentos desnecessários.
2. Destaque ALERGIAS como pontos de atenção prioritários.
3. Correlacione condições crônicas com sintomas relatados.
4. Considere histórico familiar ao fazer recomendações preventivas.
5. Sugira exames de rotina com base na idade presumida e perfil.
6. Se o IMC indicar sobrepeso/obesidade, inclua recomendações específicas.
7. NUNCA substitua uma consulta médica real — deixe isso claro no summary.
8. O overallRisk deve considerar a gravidade combinada das condições.`;

    const userPrompt = `Analise o seguinte prontuário completo do paciente:\n\n${prontuarioText}\n\nGere um relatório completo com base nestes dados.`;

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

    // Extrai JSON da resposta (pode vir em code blocks)
    let jsonStr = content;
    const jsonMatch = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      jsonStr = jsonMatch[1];
    }

    const result: ProntuarioResponse = JSON.parse(jsonStr);

    if (!result.summary || !result.attentionPoints) {
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

function formatProntuario(data: ProntuarioRequest): string {
  let text = "=== PRONTUÁRIO DO PACIENTE ===\n\n";

  // Perfil
  const p = data.profile;
  text += "--- DADOS DE SAÚDE ---\n";
  const imc = p.height > 0 ? (p.weight / ((p.height / 100) * (p.height / 100))) : 0;
  text += `Peso: ${p.weight || "N/I"} kg\n`;
  text += `Altura: ${p.height || "N/I"} cm\n`;
  text += `IMC: ${imc > 0 ? imc.toFixed(1) : "N/I"}\n`;
  text += `Tipo Sanguíneo: ${p.bloodType || "N/I"}\n`;
  text += `Condições Médicas: ${p.medicalConditions || "Nenhuma"}\n`;
  text += `Condições Crônicas: ${p.chronicConditions || "Nenhuma"}\n`;
  text += `Histórico Familiar: ${p.familyHistory || "N/I"}\n`;
  text += `Medicações em Uso: ${p.medications || "Nenhuma"}\n\n`;

  // Cirurgias
  text += `--- CIRURGIAS (${data.surgeries.length}) ---\n`;
  if (data.surgeries.length === 0) text += "Nenhuma cirurgia registrada.\n";
  else {
    for (const s of data.surgeries) {
      text += `- ${s.name} (${s.date}), Hospital: ${s.hospital || "N/I"}, Médico: ${s.doctor || "N/I"}\n`;
      if (s.notes) text += `  Obs: ${s.notes}\n`;
    }
  }
  text += "\n";

  // Internações
  text += `--- INTERNAÇÕES (${data.hospitalizations.length}) ---\n`;
  if (data.hospitalizations.length === 0) text += "Nenhuma internação registrada.\n";
  else {
    for (const h of data.hospitalizations) {
      text += `- ${h.reason}, ${h.startDate} a ${h.endDate || "em andamento"}, Hospital: ${h.hospital || "N/I"}\n`;
      if (h.notes) text += `  Obs: ${h.notes}\n`;
    }
  }
  text += "\n";

  // Sintomas
  text += `--- SINTOMAS RECORRENTES (${data.symptoms.length}) ---\n`;
  if (data.symptoms.length === 0) text += "Nenhum sintoma registrado.\n";
  else {
    for (const s of data.symptoms) {
      text += `- ${s.name} | Frequência: ${s.frequency || "N/I"} | Intensidade: ${s.intensity || "N/I"}\n`;
      if (s.notes) text += `  Obs: ${s.notes}\n`;
    }
  }
  text += "\n";

  // Alergias
  text += `--- ALERGIAS (${data.allergies.length}) ---\n`;
  if (data.allergies.length === 0) text += "Nenhuma alergia registrada.\n";
  else {
    for (const a of data.allergies) {
      text += `- ${a.name} (${a.type}) | Reação: ${a.reaction || "N/I"}\n`;
      if (a.notes) text += `  Obs: ${a.notes}\n`;
    }
  }
  text += "\n";

  // Vacinas
  text += `--- VACINAS (${data.vaccines.length}) ---\n`;
  if (data.vaccines.length === 0) text += "Nenhuma vacina registrada.\n";
  else {
    for (const v of data.vaccines) {
      text += `- ${v.name} (${v.date}) | Dose: ${v.dose || "N/I"} | ${v.isPending ? "PENDENTE" : "Aplicada"}\n`;
      if (v.notes) text += `  Obs: ${v.notes}\n`;
    }
  }
  text += "\n=== FIM DO PRONTUÁRIO ===";

  return text;
}
