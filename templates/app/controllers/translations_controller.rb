class TranslationsController < ApplicationController
  def index
  end

  def create
    text = params.require(:text)
    target = params[:target_language].presence || "Urdu"
    model = params[:model].presence
    temperature = params[:temperature].presence || 0.2

    cache_key = ["translation", Digest::SHA1.hexdigest(text), target, model, temperature].join("/")
    translation = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      AiTranslator.new.translate(text, target_language: target, model: model, temperature: temperature)
    end

    # store simple history in session (last 10)
    session[:translation_history] ||= []
    session[:translation_history].unshift({ text: text, target: target, translation: translation, model: model, temperature: temperature.to_f, at: Time.current.to_s })
    session[:translation_history] = session[:translation_history].take(10)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("translation_result", partial: "translation_result", locals: { translation: translation }) }
      format.html { redirect_to translations_path, notice: "Translated." }
    end
  rescue StandardError => e
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("translation_result", partial: "translation_result", locals: { translation: "Error: #{e.message}" }) }
      format.html { redirect_to translations_path, alert: "Error: #{e.message}" }
    end
  end
end
