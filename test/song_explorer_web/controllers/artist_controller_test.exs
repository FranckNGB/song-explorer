defmodule SongExplorerWeb.ArtistControllerTest do
  @moduledoc """
  Tests pour le controller ArtistController.

  Vérifie les réponses HTTP (status, format JSON) et l'authentification par API Key.
  La logique métier (orchestration DB/Deezer) est testée dans ArtistLookupTest.
  """
  use SongExplorerWeb.ConnCase

  @api_key "test_api_key"

  setup do
    bypass = Bypass.open()
    Application.put_env(:song_explorer, :deezer_base_url, "http://localhost:#{bypass.port}")
    Application.put_env(:song_explorer, :se_api_key, @api_key)

    on_exit(fn ->
      Application.put_env(:song_explorer, :deezer_base_url, "https://api.deezer.com")
    end)

    {:ok, bypass: bypass}
  end

  defp with_api_key(conn) do
    put_req_header(conn, "x-api-key", @api_key)
  end

  describe "GET /api/artists/:name/albums" do
    test "returns 200 with albums list", %{conn: conn, bypass: bypass} do
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
              %{"title" => "The Slim Shady LP", "release_date" => "1999-02-23"}
            ]
          })
        )
      end)

      response =
        conn
        |> with_api_key()
        |> get("/api/artists/eminem/albums")
        |> json_response(200)

      assert is_list(response["albums"])
      assert hd(response["albums"])["title"] == "The Slim Shady LP"
      assert hd(response["albums"])["release_date"] == "1999-02-23"
    end

    test "returns 404 when artist not found", %{conn: conn, bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"data" => []}))
      end)

      response =
        conn
        |> with_api_key()
        |> get("/api/artists/unknownartist/albums")
        |> json_response(404)

      assert response["error"] == "Artist not found"
    end

    test "returns 503 when Deezer API is unavailable", %{conn: conn, bypass: bypass} do
      Bypass.down(bypass)

      response =
        conn
        |> with_api_key()
        |> get("/api/artists/drake/albums")
        |> json_response(503)

      assert response["error"] == "Deezer API unavailable"
    end
  end

  describe "API Key authentication" do
    test "returns 401 when API key is missing", %{conn: conn} do
      response =
        conn
        |> get("/api/artists/drake/albums")
        |> json_response(401)

      assert response["error"] == "Invalid or missing API key"
    end

    test "returns 401 when API key is invalid", %{conn: conn} do
      response =
        conn
        |> put_req_header("x-api-key", "wrong_key")
        |> get("/api/artists/drake/albums")
        |> json_response(401)

      assert response["error"] == "Invalid or missing API key"
    end
  end
end
