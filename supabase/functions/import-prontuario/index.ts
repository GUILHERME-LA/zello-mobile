// ============================================================
// ZELLO - Edge Function: Importar Dados de Prontuário
// Recebe texto extraído de arquivo (PDF, imagem, TXT) e usa
// Claude para estruturar os dados de saúde encontrados.
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

interface ImportRequest {
  text: string;
  fileName: string;
}

interface ImportResponse {
  summary: string;
  surgeries: Array<{ name: string; date: string; hospital: string; notes: string }>;
  hospitalizations: Array<{ reason: string; hospital: string; startDate: string; endDate: string; notes: string }>;
  symptoms: Array<{ name: string; frequency: string; intensity: string; notes: string }>;
  allergies: Array<{ name: string; type: string; reaction: string; notes: string }>;
  vaccines: Array<{ name: string; date: string; dose: string; notes: string }>;
  medications: string;
  conditions: string;
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
    const body: ImportRequest = await req.json();

    if (!body.text || body.text.trim().length < 10) {
      return new Response(
        JSON.stringify({ error: "Texto muito curto para análise. Forneça um documento com mais informações." }),
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

    const systemPrompt = `Você é um especialista em processamento de documentos de saúde brasileiros.
Sua função é extrair informações estruturadas de prontuários, receitas, exames, relatórios médicos e outros documentos de saúde.

Você DEVE responder APENAS com um JSON válido, sem texto adicional, seguindo este schema:
{
  "summary": "Resumo do que foi encontrado no documento em português",
  "surgeries": [
    { "name": "Nome da cirurgia", "date": "AAAA-MM-DD", "hospital": "Nome do hospital", "notes": "Observações" }
  ],
  "hospitalizations": [
    { "reason": "Motivo", "hospital": "Hospital", "startDate": "AAAA-MM-DD", "endDate": "AAAA-MM-DD", "notes": "Observações" }
  ],
  "symptoms": [
    { "name": "Sintoma", "frequency": "Frequência", "intensity": "Intensidade", "notes": "Observações" }
  ],
  "allergies": [
    { "name": "Alergia", "type": "medicamento|alimento|substancia|outro", "reaction": "Reação", "notes": "Observações" }
  ],
  "vaccines": [
    { "name": "Vacina", "date": "AAAA-MM-DD", "dose": "Dose", "notes": "Observações" }
  ],
  "medications": "Lista de medicamentos encontrados no documento",
  "conditions": "Condições médicas/diagnósticos encontrados no documento"
}

Regras:
1. Preencha APENAS os campos que você conseguir extrair com CONFIANÇA do documento.
2. Campos não encontrados devem vir vazios ou com array vazio.
3. Datas devem estar no formato AAAA-MM-DD.
4. Se encontrar medicações, liste todas em "medications" em formato legível.
5. Se encontrar diagnósticos ou condições médicas, liste em "conditions".
6. Seja conservador: não invente informações que não estejam no documento.
7. O summary deve descrever o tipo de documento e o que foi extraído.`;

    const userPrompt = `Analise o seguinte documento de saúde e extraia todas as informações estruturadas possíveis:

NOME DO ARQUIVO: ${body.fileName}

CONTEÚDO:
${body.text}

Extraia todos os dados de saúde presentes neste documento e retorne no formato JSON especificado.`;

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
        JSON.stringify({ error: "Erro ao consultar IA", details: errorText }),
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

    let jsonStr = content;
    const jsonMatch = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
    if (jsonMatch) {
      jsonStr = jsonMatch[1];
    }

    const result: ImportResponse = JSON.parse(jsonStr);

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
