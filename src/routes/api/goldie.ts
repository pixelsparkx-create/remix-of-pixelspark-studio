import { createFileRoute } from "@tanstack/react-router";
import { convertToModelMessages, stepCountIs, streamText, tool, type UIMessage } from "ai";
import { z } from "zod";
import {
  createLovableAiGatewayProvider,
  getLovableAiGatewayResponseHeaders,
  getLovableAiGatewayRunId,
  withLovableAiGatewayRunIdHeader,
  LOVABLE_AIG_RUN_ID_HEADER,
} from "@/lib/ai-gateway.server";
import { buildSystemPrompt } from "@/lib/goldie/knowledge";

const briefSchema = z.object({
  client_name: z.string().nullish(),
  contact_email: z.string().nullish(),
  contact_phone: z.string().nullish(),
  business_name: z.string().nullish(),
  business_type: z.string().nullish(),
  location: z.string().nullish(),
  target_audience: z.string().nullish(),
  business_goals: z.array(z.string()).nullish(),
  existing_website: z.string().nullish(),
  project_type: z.string().nullish(),
  required_pages: z.array(z.string()).nullish(),
  required_features: z.array(z.string()).nullish(),
  required_integrations: z.array(z.string()).nullish(),
  design_direction: z.string().nullish(),
  content_available: z.string().nullish(),
  timeline: z.string().nullish(),
  budget: z.string().nullish(),
  recommended_plan: z.string().nullish(),
  estimated_range: z.string().nullish(),
  estimated_timeline: z.string().nullish(),
  complexity: z.string().nullish(),
  additional_requirements: z.array(z.string()).nullish(),
  conversation_summary: z.string().nullish(),
  proposal_markdown: z.string().nullish(),
  ready_for_review: z.boolean().nullish(),
});

export const Route = createFileRoute("/api/goldie")({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const body = (await request.json()) as { messages?: unknown };
        if (!Array.isArray(body.messages)) {
          return new Response("Messages are required", { status: 400 });
        }

        const key = process.env["LOVABLE_API_KEY"];
        if (!key) return new Response("AI is not configured", { status: 500 });

        const initialRunId = getLovableAiGatewayRunId(request);
        const gateway = createLovableAiGatewayProvider(key, initialRunId);

        try {
          const result = streamText({
            model: gateway("google/gemini-3.6-flash"),
            system: buildSystemPrompt(),
            messages: await convertToModelMessages(body.messages as UIMessage[]),
            stopWhen: stepCountIs(6),
            tools: {
              update_brief: tool({
                description:
                  "Save or refine what you now know about the visitor's project. Send only the fields you learned; they are merged into the stored project brief.",
                inputSchema: briefSchema,
                execute: async () => ({ saved: true }),
              }),
            },
          });

          const response = result.toUIMessageStreamResponse({
            originalMessages: body.messages as UIMessage[],
            onError: (error) => {
              console.error("[goldie] stream error", error);
              const message = error instanceof Error ? error.message : String(error);
              if (message.includes("429")) return "Goldie is a bit busy right now — please try again in a moment.";
              if (message.includes("402")) return "Goldie is temporarily unavailable. Please reach out on WhatsApp.";
              return "Something went wrong on Goldie's side. Please try again.";
            },
            headers: getLovableAiGatewayResponseHeaders(undefined, {
              ...(initialRunId ? { [LOVABLE_AIG_RUN_ID_HEADER]: initialRunId } : {}),
            }),
          });

          return withLovableAiGatewayRunIdHeader(response, gateway);
        } catch (error) {
          console.error("[goldie] failed", error);
          return new Response("Goldie is unavailable right now", { status: 500 });
        }
      },
    },
  },
});
