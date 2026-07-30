defmodule SongExplorerWeb.ArtistController do
  use SongExplorerWeb, :controller

  alias SongExplorer.Catalog
  alias SongExplorer.Deezer.Client

  def albums(conn, %{"name" => name}) do
    name
    |> Catalog.get_artist_by_name()
    |> case do
      %{albums: albums} ->
        conn
        |> json(%{albums: albums})

      nil ->
        with {:ok, %{name: artist_name, deezer_id: deezer_id}} <- Client.search_artist(name),
             {:ok, albums} <- Client.get_albums(deezer_id) do
          IO.puts(
            "[ARTIST CONTROLLER] TODO: save artist #{artist_name} (#{deezer_id}) with #{length(albums)} albums"
          )

          conn
          |> json(%{albums: albums})
        else
          {:error, :not_found} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Artist not found"})

          {:error, reason} ->
            IO.puts("[ARTIST CONTROLLER] Error on Deezer API with reason #{inspect(reason)}")

            conn
            |> put_status(:service_unavailable)
            |> json(%{error: "Deezer API unavailable"})
        end
    end
  end
end
