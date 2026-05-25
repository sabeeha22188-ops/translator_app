require "openai"
require "digest"
require "thread"

class AiTranslator
  def initialize(client: nil)
    @client = client || OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    @cache = {}
    @cache_mutex = Mutex.new
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

    cache_key = Digest::SHA256.hexdigest([text, target_language, model, temperature].join("|"))

    # Return cached translation when available and fresh
    cached = nil
    @cache_mutex.synchronize do
      entry = @cache[cache_key]
      if entry && (Time.now.to_i - entry[:ts]) <= (ENV.fetch("AI_TRANSLATOR_CACHE_TTL", "300").to_i)
        cached = entry[:value]
      end
    end
    return cached if cached

    response = with_retries do
      @client.chat(parameters: {
        model: model,
        messages: [{ role: "user", content: prompt }],
        temperature: temperature.to_f,
        max_tokens: 800
      })
    end

    content = parse_content(response)

    # Store in cache
    @cache_mutex.synchronize do
      @cache[cache_key] = { value: content, ts: Time.now.to_i }
    end

    content
  end

  private

  def parse_content(response)
    response.dig("choices", 0, "message", "content") || response.dig(:choices, 0, :message, :content).to_s.to_s.strip
  end

  def with_retries(max_attempts: (ENV.fetch("AI_TRANSLATOR_RETRIES", "3").to_i), base: 0.5)
    attempts = 0
    begin
      attempts += 1
      return yield
    rescue => e
      raise if attempts >= max_attempts
      sleep_time = base * (2 ** (attempts - 1))
      sleep(sleep_time)
      retry
    end
  end
end
