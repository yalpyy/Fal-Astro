/**
 * LLM Provider Abstraction Layer
 * Supports OpenAI and Anthropic (Claude) APIs
 */

export interface LLMMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface LLMResponse {
  content: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  model: string;
}

export interface LLMProviderConfig {
  provider: 'openai' | 'anthropic';
  apiKey: string;
  model?: string;
  maxTokens?: number;
  temperature?: number;
}

export interface ILLMProvider {
  generateCompletion(
    messages: LLMMessage[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse>;

  generateWithImages(
    messages: LLMMessage[],
    imageUrls: string[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse>;
}

// OpenAI Provider Implementation
class OpenAIProvider implements ILLMProvider {
  private apiKey: string;
  private model: string;
  private defaultMaxTokens: number;
  private defaultTemperature: number;

  constructor(config: LLMProviderConfig) {
    this.apiKey = config.apiKey;
    this.model = config.model || 'gpt-4o';
    this.defaultMaxTokens = config.maxTokens || 2048;
    this.defaultTemperature = config.temperature || 0.7;
  }

  async generateCompletion(
    messages: LLMMessage[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse> {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: this.model,
        messages: messages.map((m) => ({ role: m.role, content: m.content })),
        max_tokens: options?.maxTokens || this.defaultMaxTokens,
        temperature: options?.temperature || this.defaultTemperature,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    return {
      content: data.choices[0].message.content,
      usage: {
        promptTokens: data.usage.prompt_tokens,
        completionTokens: data.usage.completion_tokens,
        totalTokens: data.usage.total_tokens,
      },
      model: data.model,
    };
  }

  async generateWithImages(
    messages: LLMMessage[],
    imageUrls: string[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse> {
    // Build content array with images for the last user message
    const formattedMessages = messages.map((m, index) => {
      if (m.role === 'user' && index === messages.length - 1) {
        const content: Array<{ type: string; text?: string; image_url?: { url: string } }> = [
          { type: 'text', text: m.content },
        ];
        for (const url of imageUrls) {
          content.push({
            type: 'image_url',
            image_url: { url },
          });
        }
        return { role: m.role, content };
      }
      return { role: m.role, content: m.content };
    });

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: this.model,
        messages: formattedMessages,
        max_tokens: options?.maxTokens || this.defaultMaxTokens,
        temperature: options?.temperature || this.defaultTemperature,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    return {
      content: data.choices[0].message.content,
      usage: {
        promptTokens: data.usage.prompt_tokens,
        completionTokens: data.usage.completion_tokens,
        totalTokens: data.usage.total_tokens,
      },
      model: data.model,
    };
  }
}

// Anthropic (Claude) Provider Implementation
class AnthropicProvider implements ILLMProvider {
  private apiKey: string;
  private model: string;
  private defaultMaxTokens: number;
  private defaultTemperature: number;

  constructor(config: LLMProviderConfig) {
    this.apiKey = config.apiKey;
    this.model = config.model || 'claude-sonnet-4-20250514';
    this.defaultMaxTokens = config.maxTokens || 2048;
    this.defaultTemperature = config.temperature || 0.7;
  }

  async generateCompletion(
    messages: LLMMessage[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse> {
    // Extract system message
    const systemMessage = messages.find((m) => m.role === 'system')?.content || '';
    const chatMessages = messages
      .filter((m) => m.role !== 'system')
      .map((m) => ({ role: m.role, content: m.content }));

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: this.model,
        max_tokens: options?.maxTokens || this.defaultMaxTokens,
        temperature: options?.temperature || this.defaultTemperature,
        system: systemMessage,
        messages: chatMessages,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Anthropic API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    return {
      content: data.content[0].text,
      usage: {
        promptTokens: data.usage.input_tokens,
        completionTokens: data.usage.output_tokens,
        totalTokens: data.usage.input_tokens + data.usage.output_tokens,
      },
      model: data.model,
    };
  }

  async generateWithImages(
    messages: LLMMessage[],
    imageUrls: string[],
    options?: { maxTokens?: number; temperature?: number }
  ): Promise<LLMResponse> {
    // Extract system message
    const systemMessage = messages.find((m) => m.role === 'system')?.content || '';

    // Build content with images for Anthropic format
    const chatMessages = [];
    for (const m of messages.filter((m) => m.role !== 'system')) {
      if (m.role === 'user') {
        const content: Array<{
          type: string;
          text?: string;
          source?: { type: string; media_type: string; data: string };
        }> = [];

        // Add images first
        for (const url of imageUrls) {
          // Fetch image and convert to base64
          const imageResponse = await fetch(url);
          const imageBuffer = await imageResponse.arrayBuffer();
          const base64 = btoa(
            new Uint8Array(imageBuffer).reduce((data, byte) => data + String.fromCharCode(byte), '')
          );
          const mediaType = imageResponse.headers.get('content-type') || 'image/jpeg';

          content.push({
            type: 'image',
            source: {
              type: 'base64',
              media_type: mediaType,
              data: base64,
            },
          });
        }

        content.push({ type: 'text', text: m.content });
        chatMessages.push({ role: m.role, content });
      } else {
        chatMessages.push({ role: m.role, content: m.content });
      }
    }

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: this.model,
        max_tokens: options?.maxTokens || this.defaultMaxTokens,
        temperature: options?.temperature || this.defaultTemperature,
        system: systemMessage,
        messages: chatMessages,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Anthropic API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    return {
      content: data.content[0].text,
      usage: {
        promptTokens: data.usage.input_tokens,
        completionTokens: data.usage.output_tokens,
        totalTokens: data.usage.input_tokens + data.usage.output_tokens,
      },
      model: data.model,
    };
  }
}

// Factory function to create provider
export function createLLMProvider(config: LLMProviderConfig): ILLMProvider {
  switch (config.provider) {
    case 'openai':
      return new OpenAIProvider(config);
    case 'anthropic':
      return new AnthropicProvider(config);
    default:
      throw new Error(`Unknown LLM provider: ${config.provider}`);
  }
}

// Get provider from environment
export function getLLMProviderFromEnv(): ILLMProvider {
  const provider = Deno.env.get('LLM_PROVIDER') || 'openai';
  const apiKey =
    provider === 'openai'
      ? Deno.env.get('OPENAI_API_KEY')
      : Deno.env.get('ANTHROPIC_API_KEY');

  if (!apiKey) {
    throw new Error(`Missing API key for provider: ${provider}`);
  }

  return createLLMProvider({
    provider: provider as 'openai' | 'anthropic',
    apiKey,
    model: Deno.env.get('LLM_MODEL'),
    maxTokens: parseInt(Deno.env.get('LLM_MAX_TOKENS') || '2048'),
    temperature: parseFloat(Deno.env.get('LLM_TEMPERATURE') || '0.7'),
  });
}
