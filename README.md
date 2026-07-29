# SongExplorer

Application Elixir/Phoenix (API REST) permettant d'explorer le catalogue musical via l'API publique de Deezer.

## Prérequis

- Elixir 1.18.4
- Erlang/OTP 28
- PostgreSQL
- Docker & Docker Compose

## Installation

```bash
mix deps.get
```

## Configuration

Copier le fichier d'environnement et l'adapter si besoin :

```bash
cp .env.example .env
```

## Base de données

Lancer PostgreSQL via Docker :

```bash
docker compose up -d
# ou selon votre installation
docker-compose up -d
```

Créer la base de données :

```bash
mix ecto.create
```

## Lancement

Via le script (charge automatiquement le `.env`) :

```bash
./start_server.sh
```

Ou manuellement :

```bash
source .env
mix phx.server
```

L'API est disponible sur `http://localhost:4000`.

## Tests

```bash
mix test
```
