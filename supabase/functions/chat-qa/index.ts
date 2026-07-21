// ============================================================
// ZELLO - Edge Function: Hub de IA (Claude Haiku)
// Responde perguntas sobre os recursos do app, analisa exames
// (PDF/imagem) e analisa o plano de saúde (convênio) do usuário.
// A chave Anthropic fica APENAS aqui (segredo do Supabase);
// o app Flutter chama esta função via functions.invoke('chat-qa').
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

interface ChatRequest {
  messages: ChatMessage[];
  kind: "qa" | "exam" | "plan" | "olga";
  planContext?: Record<string, unknown> | null;
  patientContext?: string | null;
  file?: { name: string; mime: string; data: string } | null;
}

// Modelo Claude Haiku. Ajuste o ID se a conta usar outra versão.
const MODEL = "claude-haiku-4-5-20251001";

const ZELLO_FEATURES = `
Recursos disponíveis no aplicativo Zello Saúde:
- Início / Home: visão geral e ações rápidas do paciente.
- Agenda: consultas e compromissos médicos agendados.
- Prontuário: histórico clínico completo (medicações, terapias, tratamentos, anamnese, exames).
- Medicações: lista de medicamentos, dosagens e horários.
- Terapias: terapias em andamento e acompanhamento.
- Tratamentos: planos de tratamento e evolução.
- Anamnese: histórico de anamneses realizadas.
- Hospitais próximos: hospitais e redes hospitalares próximos (base CNES, Rio de Janeiro).
- Análise de Convênio: a IA analisa o plano de saúde do paciente e recomenda hospitais/planos.
- Perfil / Configurações: dados do usuário, segurança e privacidade (LGPD).
- Central de IA: este assistente, para tirar dúvidas e enviar exames.
`;

function buildSystemPrompt(kind: string, planContext?: Record<string, unknown> | null, patientContext?: string | null): string {
  const base = `Você é a assistente virtual do Zello Saúde, um app brasileiro de assistência à saúde.
Responda sempre em português do Brasil, de forma simples, acolhedora e educativa.
${ZELLO_FEATURES}
AVISO IMPORTANTE: você NÃO substitui um profissional de saúde. Em temas médicos, oriente a procurar
um médico ou o convênio, e nunca dê diagnósticos definitivos.`;

  if (kind === "plan") {
    const plan = planContext ? JSON.stringify(planContext, null, 2) : "Nenhum plano informado.";
    return `${base}

TAREFA ATUAL: analisar o PLANO DE SAÚDE (convênio) do usuário.
Dados do plano/convênio do usuário:
${plan}

Explique de forma clara: cobertura, hospitais/rede credenciada, pontos de atenção, e dê orientações
gerais sobre como aproveitar melhor o plano. Se faltarem dados, diga o que o usuário pode buscar no app.`;
  }

  if (kind === "exam") {
    return `${base}

TAREFA ATUAL: analisar o EXAME enviado pelo usuário (imagem ou PDF).
Destaque os principais indicadores, aponte valores fora da faixa de referência quando houver,
apresente um resumo em linguagem simples e indique os pontos que merecem atenção e acompanhamento.
Reforce que é uma análise educativa e não substitui a avaliação de um profissional.`;
  }

  if (kind === "olga") {
    const context = patientContext || "Nenhum dado adicional do paciente disponível.";
    return `Você é a Doutora Olga, uma assistente de saúde brasileira, especialista em análise de sintomas e orientação médica baseada em diretrizes da medicina.

RESPONDA SEMPRE EM PORTUGUÊS DO BRASIL, de forma acolhedora, clara e educativa.

DADOS DO PACIENTE (anamnese, histórico):
${context}

SUAS FUNÇÕES PRINCIPAIS:
1. ANALISAR SINTOMAS e recomendar se o paciente deve procurar um médico, uma UPA ou se pode tratar em casa com orientações seguras baseadas em diretrizes médicas.
2. RECOMENDAR MÉDICOS com base no plano de saúde do paciente, quando disponível.
3. ENCONTRAR UPAs e hospitais públicos próximos quando o paciente não tem plano de saúde.
4. ANALISAR EXAMES (imagens, PDF) com explicações educativas.
5. DAR ORIENTAÇÕES DE SAÚDE baseadas em diretrizes da medicina brasileira (SUS, CFM, Ministério da Saúde).

REGRAS IMPORTANTES:
- Você NÃO substitui um médico real. Sempre recomende procurar atendimento presencial quando apropriado.
- Para sintomas graves (dor no peito, falta de ar, sangramentos, AVC), recomende UPA ou emergência IMEDIATAMENTE.
- Para recomendar médicos, use o plano de saúde do paciente quando disponível.
- Se o paciente não tem plano de saúde, recomende UPAs, postinhos (UBS) e hospitais públicos mais próximos com base no endereço do paciente.
- Sugestões de medicamentos devem seguir diretrizes da OMS/ANVISA e sempre recomendar consulta médica antes de usar.`;
  }

  return `${base}

TAREFA ATUAL: responder dúvidas gerais sobre os recursos do app e saúde em geral,
sempre dentro do escopo do Zello Saúde.`;
}

function buildContentBlocks(req: ChatRequest): unknown[] {
  const last = req.messages[req.messages.length - 1];
  const blocks: unknown[] = [{ type: "text", text: last.content }];

  if (req.file && req.file.data) {
    const mime = req.file.mime;
    if (mime.startsWith("image/")) {
      blocks.push({
        type: "image",
        source: { type: "base64", media_type: mime, data: req.file.data },
      });
    } else if (mime === "application/pdf") {
      blocks.push({
        type: "document",
        source: { type: "base64", media_type: "application/pdf", data: req.file.data },
      });
    }
  }
  return blocks;
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
    return new Response(JSON.stringify({ error: "Método não permitido" }), {
      status: 405,
      headers,
    });
  }

  try {
    const body = (await req.json()) as ChatRequest;

    if (!body.messages || body.messages.length === 0) {
      return new Response(JSON.stringify({ error: "Nenhuma mensagem enviada" }), {
        status: 400,
        headers,
      });
    }

    const apiKey =
      Deno.env.get("CLAUDE_HAIKU_API_KEY") ?? Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "API key da Anthropic não configurada" }),
        { status: 500, headers }
      );
    }

    const systemPrompt = buildSystemPrompt(body.kind ?? "qa", body.planContext, body.patientContext);

    const history = (body.messages.slice(0, -1) ?? []).map((m) => ({
      role: m.role,
      content: m.content,
    }));

    const lastMessage = {
      role: "user",
      content: buildContentBlocks(body),
    };

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
          model: MODEL,
          max_tokens: 2048,
          system: systemPrompt,
          messages: [...history, lastMessage],
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

    return new Response(JSON.stringify({ reply: content }), {
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
