defmodule SongExplorer.Services.ArtistLookupTest do
  @moduledoc """
  Tests pour le service ArtistLookup.

  Utilise Bypass pour simuler l'API Deezer et vérifie l'orchestration
  entre la base de données et l'API Deezer.
  """
  use SongExplorer.DataCase

  alias SongExplorer.Catalog
  alias SongExplorer.Services.ArtistLookup

  setup do
    bypass = Bypass.open()
    Application.put_env(:song_explorer, :deezer_base_url, "http://localhost:#{bypass.port}")

    on_exit(fn ->
      Application.put_env(:song_explorer, :deezer_base_url, "https://api.deezer.com")
    end)

    {:ok, bypass: bypass}
  end

  describe "fetch_albums/1" do
    test "returns albums from database when artist exists", _context do
      {:ok, artist} = Catalog.create_artist(%{name: "Drake", deezer_id: 246_791})

      Catalog.create_album(%{
        title: "Scorpion",
        release_date: ~D[2018-06-29],
        artist_id: artist.id
      })

      assert {:ok, :from_db, albums} = ArtistLookup.fetch_albums("Drake")
      assert length(albums) == 1
      assert hd(albums).title == "Scorpion"
    end

    test "returns albums from Deezer when artist is not in database",
         %{bypass: bypass} do
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

      assert {:ok, :from_deezer, albums, artist_data} = ArtistLookup.fetch_albums("eminem")
      assert length(albums) == 2
      assert artist_data.name == "Eminem"
      assert artist_data.deezer_id == 13
    end

    test "returns :not_found when artist does not exist on Deezer",
         %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"data" => []}))
      end)

      assert {:error, :not_found} = ArtistLookup.fetch_albums("unknownartist")
    end

    test "returns error when Deezer API is unavailable", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, _reason} = ArtistLookup.fetch_albums("drake")
    end
  end
end
