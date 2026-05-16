require "openai"

class AiTranslator
  def initialize(client: nil)
    @client = client || OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # Translate English text to Urdu using the AI provider.
  # Returns plain text translation.
  def translate_to_urdu(text)
    prompt = <<~PROMPT
      Translate the following English text to Urdu. Keep tone natural and concise.

      Text: #{text}

      Urdu translation:
    PROMPT

    response = @client.chat(parameters: {
      model: ENV.fetch("AI_MODEL", "gpt-4o-mini"),
      messages: [{ role: "user", content: prompt }],
      temperature: 0.2,
      max_tokens: 800
    })

    # Parse provider response robustly
    content = response.dig("choices", 0, "message", "content") || response.dig(:choices, 0, :message, :content)
    content.to_s.strip
  end
end
