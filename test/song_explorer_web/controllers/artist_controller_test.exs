defmodule SongExplorerWeb.ArtistControllerTest do
  @moduledoc """
  Tests pour le controller ArtistController.

  Utilise Bypass pour simuler l'API Deezer en local et éviter les appels
  HTTP réels pendant les tests.
  """
  use SongExplorerWeb.ConnCase

  # Configure Bypass pour intercepter les appels à l'API Deezer.
  # La base URL est redirigée vers le serveur Bypass local.
  # À la fin de chaque test, la configuration originale est restaurée.
  setup do
    bypass = Bypass.open()
    Application.put_env(:song_explorer, :deezer_base_url, "http://localhost:#{bypass.port}")

    on_exit(fn ->
      Application.put_env(:song_explorer, :deezer_base_url, "https://api.deezer.com")
    end)

    {:ok, bypass: bypass}
  end

  describe "GET /api/artists/:name/albums" do
    @doc """
    Vérifie que l'endpoint retourne les albums depuis l'API Deezer
    lorsque l'artiste n'est pas encore en base de données.
    """
    test "returns albums from Deezer API when artist is not in database",
         %{conn: conn, bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(
          200,
          Jason.encode!(%{
            "data" => [%{"id" => 13, "name" => "Eminem", "nb_fan" => 20_000_000}]
          })
        )
      end)

      Bypass.expect(bypass, "GET", "/artist/13/albums", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"title" => "The Slim Shady LP", "release_date" => "1999-02-23"},
              %{"title" => "The Marshall Mathers LP", "release_date" => "2000-05-23"}
            ]
          })
        )
      end)

      conn = get(conn, "/api/artists/eminem/albums")
      response = json_response(conn, 200)

      assert length(response["albums"]) == 2
      assert Enum.any?(response["albums"], &(&1["title"] == "The Slim Shady LP"))
    end

    @doc """
    Vérifie que l'endpoint retourne une erreur 404
    lorsque l'artiste n'est pas trouvé sur l'API Deezer.
    """
    test "returns 404 when artist not found on Deezer", %{conn: conn, bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"data" => []}))
      end)

      conn = get(conn, "/api/artists/unknownartist/albums")
      assert json_response(conn, 404)["error"] == "Artist not found"
    end

    @doc """
    Vérifie que l'endpoint retourne les albums directement depuis la base de données
    lorsque l'artiste est déjà enregistré, sans appeler l'API Deezer.
    """
    test "returns albums from database when artist already exists", %{conn: conn} do
      {:ok, artist} =
        SongExplorer.Catalog.create_artist(%{name: "Drake", deezer_id: 246_791})

      SongExplorer.Catalog.create_album(%{
        title: "Scorpion",
        release_date: ~D[2018-06-29],
        artist_id: artist.id
      })

      conn = get(conn, "/api/artists/Drake/albums")
      response = json_response(conn, 200)

      assert length(response["albums"]) == 1
      assert hd(response["albums"])["title"] == "Scorpion"
    end
  end
end
