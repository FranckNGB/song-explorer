defmodule SongExplorerWeb.Plugs.ApiKeyAuth do
  @moduledoc """
  Plug d'authentification par clé API.

  Vérifie la présence et la validité du header `x-api-key` sur chaque requête.
  La clé attendue est configurée via la variable d'environnement `SE_API_KEY`.

  ## Comportement
    - Si le header `x-api-key` est présent et correspond à la clé configurée, la requête passe.
    - Sinon, la requête est rejetée avec un statut `401 Unauthorized`.

  ## Utilisation dans le router

      pipeline :api do
        plug SongExplorerWeb.Plugs.ApiKeyAuth
      end
  """
  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc """
  Vérifie le header `x-api-key` de la requête.

  Retourne la connexion inchangée si la clé est valide,
  ou une réponse 401 avec un message d'erreur si elle est absente ou invalide.
  """
  def call(conn, _opts) do
    api_key = Application.get_env(:song_explorer, :se_api_key)

    case get_req_header(conn, "x-api-key") do
      [^api_key] ->
        conn

      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: "Invalid or missing API key"})
        |> halt()
    end
  end
end
