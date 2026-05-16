class TranslationsController < ApplicationController
  def index
  end

  def create
    text = params.require(:text)
    translator = AiTranslator.new
    translation = translator.translate_to_urdu(text)

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
