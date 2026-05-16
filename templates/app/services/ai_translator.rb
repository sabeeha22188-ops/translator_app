require "openai"

class AiTranslator
  def initialize(client: nil)
    @client = client || OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # Translate English text to Urdu using the AI provider.
  # Translate text to a target language using the AI provider.
  # - `target_language` examples: "Urdu", "Hindi", "Spanish".
  # - `model` and `temperature` are passed to the provider.
  # Returns plain text translation.
  def translate(text, target_language: "Urdu", model: nil, temperature: 0.2)
    model ||= ENV.fetch("AI_MODEL", "gpt-4o-mini")

    prompt = <<~PROMPT
      Detect the source language automatically. Translate the following text to #{target_language}.
      Keep tone natural and concise.

      Text: #{text}

      #{target_language} translation:
    PROMPT

    response = @client.chat(parameters: {
      model: model,
      messages: [{ role: "user", content: prompt }],
      temperature: temperature.to_f,
      max_tokens: 800
    })

    # Parse provider response robustly
    content = response.dig("choices", 0, "message", "content") || response.dig(:choices, 0, :message, :content)
    content.to_s.strip
  end
end
