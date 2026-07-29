# SongExplorer

Application Elixir/Phoenix (API REST) permettant d'explorer le catalogue musical via l'API publique de Deezer.

## Prérequis

- Elixir 1.18.4
- Erlang/OTP 28
- PostgreSQL

## Installation

```bash
mix deps.get
mix ecto.create
```

## Lancement

```bash
mix phx.server
```

Ou en mode interactif :

```bash
iex -S mix phx.server
```

L'API est disponible sur `http://localhost:4000`.

## Tests

```bash
mix test
```
