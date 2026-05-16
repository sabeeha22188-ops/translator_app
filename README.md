English → Urdu Translator (Rails + Hotwire + AI)

Overview
- Minimal Rails app scaffold instructions to build an English→Urdu translator using Hotwire and an AI backend (OpenAI).

Principles
- Clean, concise code; follow Rails conventions.
- Use latest stable Rails you have available locally.
- Always use Hotwire (Turbo + Stimulus) for UI updates.

Quick start
1. Install latest Rails if needed:

```bash
gem install rails
```

2. Create a new Rails app (example):

```bash
rails new english_urdu_translator -T -d postgresql -j esbuild --css=bootstrap
cd english_urdu_translator
```

3. Add required gems and install Hotwire + OpenAI client:

```bash
bundle add hotwire-rails openai
bin/rails hotwire:install
bundle install
```

4. Generate controller and route:

```bash
bin/rails g controller Translations index create
```

5. Copy the templates from `templates/` in this repo into the matching `app/` files in your Rails app (controller, views, service), and update `config/routes.rb` as shown.

6. Set environment variable:

```bash
export OPENAI_API_KEY="your_api_key"
```

7. Start the server:

```bash
bin/rails db:create db:migrate
bin/rails server
```

Files provided
- `templates/app/controllers/translations_controller.rb`
- `templates/app/views/translations/index.html.erb`
- `templates/app/views/translations/_translation_result.html.erb`
- `templates/app/services/ai_translator.rb`
- `templates/config/routes.rb` (snippet)
- `templates/.env.example`

Notes
- The AI service expects `OPENAI_API_KEY` in the environment. No API key or secrets are stored in the repo.
- The provided `AiTranslator` is a small wrapper that calls an LLM to perform the translation and returns plain text. Tweak model and parameters to match your provider and policy.
