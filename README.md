# SongExplorer

Application Elixir/Phoenix (API REST) permettant d'explorer le catalogue musical via l'API publique de Deezer.

## Prérequis

- Elixir 1.18.4
- Erlang/OTP 28
- Docker & Docker Compose

## Installation

Copier le fichier d'environnement et l'adapter si besoin :

```bash
cp .env.example .env
```

Installer les dépendances :

```bash
mix deps.get
```

## Base de données

Lancer PostgreSQL via Docker :

```bash
docker compose up -d
# ou selon votre installation
docker-compose up -d
```

Créer la base de données et lancer les migrations :

```bash
mix ecto.create
mix ecto.migrate
```

## Lancement

```bash
./start_server.sh
```

L'API est disponible sur `http://localhost:4000`.

## Utilisation

### Récupérer les albums d'un artiste

```
GET /api/artists/:name/albums
```

Exemple :

```bash
curl http://localhost:4000/api/artists/drake/albums
```

Réponse :

```json
{
  "albums": [
    {"title": "Scorpion", "release_date": "2018-06-29"},
    {"title": "Views", "release_date": "2016-05-06"}
  ]
}
```

### Comportement

- Si l'artiste est déjà en base de données, les albums sont retournés directement depuis la base.
- Sinon, l'API Deezer est interrogée, les albums sont retournés et l'artiste est sauvegardé en base de manière asynchrone.
- En cas d'homonymes, l'artiste avec le plus de fans est sélectionné.
- La pagination de l'API Deezer est gérée automatiquement.

## Tests

```bash
mix test
```

## Qualité du code

```bash
mix format
mix credo
```

## Architecture

- **`SongExplorer.Deezer.Client`** — Client HTTP pour l'API publique de Deezer (recherche artiste, récupération albums avec pagination)
- **`SongExplorer.Catalog`** — Contexte métier (persistance artistes et albums en PostgreSQL)
- **`SongExplorerWeb.ArtistController`** — Controller REST exposant l'endpoint `/api/artists/:name/albums`
