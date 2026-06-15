# TraceOrigin

TraceOrigin risponde a una domanda precisa che capita spesso nei progetti Rails:

**Quale percorso applicativo ha creato questo record?**

Quando trovi un record nel database e, anche leggendo i log, non è chiaro quale controller, service o job l'abbia generato, TraceOrigin salva al momento della creazione uno stack applicativo leggibile che puoi consultare in seguito.

## Filosofia

TraceOrigin **non è una gemma di auditing**. È una gemma di **debugging e observability tecnica**, pensata per capire rapidamente da dove nasce un record senza scavare nei log o negli strumenti di observability.

## Requisiti

- Ruby >= 3.0
- Rails >= 6.1 (testata con Rails 7.0.6)

## Installazione

Aggiungi la gemma al `Gemfile` dell'applicazione:

```ruby
gem "trace_origin"
```

Per sviluppo locale:

```ruby
gem "trace_origin", path: "../trace-origin/trace_origin"
```

Poi installa la gemma e genera migration e initializer:

```bash
bundle install
rails generate trace_origin:install
rails db:migrate
```

Il generator crea:

- `db/migrate/..._create_trace_origins.rb` — tabella dedicata gestita dalla gemma
- `config/initializers/trace_origin.rb` — file di configurazione

## Configurazione

In `config/initializers/trace_origin.rb`:

```ruby
TraceOrigin.configure do |config|
  config.enabled = true
  config.depth = 5
  config.retention_days = 14
end
```

### Opzioni

| Opzione | Default | Descrizione |
|---------|---------|-------------|
| `enabled` | `true` | Abilita o disabilita la cattura dei trace |
| `depth` | `5` | Numero massimo di frame applicativi da salvare |
| `retention_days` | `14` | Giorni di conservazione dei trace (0 = disabilitato) |
| `raise_errors` | `false` | Se `true`, propaga errori di cattura/salvataggio trace |

### Abilitazione per ambiente

Solo in development:

```ruby
config.enabled = Rails.env.development?
```

Tramite variabile d'ambiente:

```ruby
config.enabled = ENV.fetch("TRACE_ORIGIN_ENABLED", Rails.env.development? ? "true" : "false") == "true"
config.depth = ENV.fetch("TRACE_ORIGIN_DEPTH", 5).to_i
config.retention_days = ENV.fetch("TRACE_ORIGIN_RETENTION_DAYS", 14).to_i
```

Variabili supportate:

- `TRACE_ORIGIN_ENABLED`
- `TRACE_ORIGIN_DEPTH`
- `TRACE_ORIGIN_RETENTION_DAYS`

## Utilizzo

Dichiara sui modelli che vuoi tracciare:

```ruby
class Order < ApplicationRecord
  trace_origin
end
```

Quando viene creato un record, la gemma cattura il percorso applicativo e lo salva nella tabella `trace_origins`.

### Leggere l'origine di un record

Trace completo come stringa:

```ruby
order.trace_origin
# => "Api::OrdersController#create > CreateOrderService#call > ImportOrdersJob"
```

Record persistito nella tabella della gemma:

```ruby
order.trace_origin_record
# => #<TraceOrigin::Entry id: 1, record_type: "Order", record_id: 42, trace: "...">
```

## Formato del trace

TraceOrigin usa `caller_locations` per ricostruire uno stack leggibile.

Esempio tipico:

```text
Api::OrdersController#create > CreateOrderService#call > ImportOrdersJob
```

### Come viene costruito

Per ogni frame rilevante, la gemma usa `caller_location.label` e il path del file per ricostruire classe e metodo:

```text
app/services/create_order_service.rb  +  label "call"
=> CreateOrderService#call
```

Se non è possibile ricostruire correttamente classe e metodo, usa un fallback con path e riga:

```text
app/services/create_order_service.rb:12
```

### Supporto Job

I job compaiono chiaramente nel trace, anche senza indicare il metodo:

```text
ImportOrdersJob
SyncOrdersJob
ProcessPaymentsJob
```

## Filtri dello stack

TraceOrigin filtra automaticamente il rumore dello stack e mantiene principalmente codice applicativo in `app/` e `lib/`.

Frame esclusi (non esaustivo):

- Ruby stdlib e internals
- Bundler e gems
- ActiveRecord, ActiveSupport, Railties
- Codice interno di TraceOrigin (filtrato automaticamente dal path della gemma)

La profondità del trace è configurabile con `config.depth`.

## Architettura

TraceOrigin **non aggiunge colonne** ai modelli tracciati. Usa una tabella dedicata:

### Tabella `trace_origins`

| Colonna | Tipo | Descrizione |
|---------|------|-------------|
| `record_type` | string | Nome della classe del record (es. `Order`) |
| `record_id` | bigint | ID del record |
| `trace` | text | Percorso applicativo serializzato |
| `created_at` | datetime | Timestamp di creazione |
| `updated_at` | datetime | Timestamp di aggiornamento |

Indici:

- `[record_type, record_id]` — lookup rapido per record
- `created_at` — cleanup per retention

La retention è configurabile. I trace scaduti possono essere eliminati con un rake task.

## Retention e cleanup

Elimina i trace più vecchi del periodo configurato:

```bash
rails trace_origin:cleanup
```

Utile da schedulare periodicamente (cron, Whenever, job schedulato):

```ruby
# config/schedule.rb (whenever)
every 1.day, at: "3:00 am" do
  rake "trace_origin:cleanup"
end
```

Con `retention_days = 0` il cleanup non elimina nulla.

## Esempio completo

```ruby
# config/initializers/trace_origin.rb
TraceOrigin.configure do |config|
  config.enabled = Rails.env.development? || ENV["TRACE_ORIGIN_ENABLED"] == "true"
  config.depth = 5
  config.retention_days = 14
end

# app/models/order.rb
class Order < ApplicationRecord
  trace_origin
end

# console
order = Order.last
order.trace_origin
# => "Api::OrdersController#create > CreateOrderService#call"
```

## Test

La suite RSpec copre:

- configurazione
- builder del trace
- filtri dei path
- rispetto della profondità
- integrazione ActiveRecord
- recupero del trace
- percorsi end-to-end (controller, service, job, delayed job style runner)
- resilienza agli errori
- preload senza N+1
- cleanup della retention
- casi con Job
- casi edge (fallback path, block labels, trace vuoto)

## Limitazioni

- Traccia solo la **creazione** del record (`after_create`), non update o destroy.
- Un trace per record creato; non è un audit trail completo.
- I job sono riconosciuti quando il file è in `app/jobs/` e termina con `_job.rb`.
- Se lo stack filtrato è vuoto, il trace non viene salvato e la creazione del record prosegue normalmente.
- Errori durante cattura o salvataggio del trace non interrompono il flusso applicativo (salvo `raise_errors = true`).
- Create asincroni o cross-thread possono produrre stack non rappresentativi del request originale.

## License

MIT
