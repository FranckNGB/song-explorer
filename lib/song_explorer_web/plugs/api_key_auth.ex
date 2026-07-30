defmodule SongExplorerWeb.Plugs.ApiKeyAuth do
  import Plug.Conn

  def init(opts), do: opts

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
