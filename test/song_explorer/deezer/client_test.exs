defmodule SongExplorer.Deezer.ClientTest do
  @moduledoc """
  Tests pour le client HTTP Deezer.

  Utilise Bypass pour simuler l'API Deezer en local.
  """
  use ExUnit.Case

  alias SongExplorer.Deezer.Client

  setup do
    bypass = Bypass.open()
    Application.put_env(:song_explorer, :deezer_base_url, "http://localhost:#{bypass.port}")

    on_exit(fn ->
      Application.put_env(:song_explorer, :deezer_base_url, "https://api.deezer.com")
    end)

    {:ok, bypass: bypass}
  end

  describe "search_artist/1" do
    test "returns the most popular artist", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"id" => 1, "name" => "Drake", "nb_fan" => 38},
              %{"id" => 2, "name" => "Drake", "nb_fan" => 24_000_000}
            ]
          })
        )
      end)

      assert {:ok, %{name: "Drake", deezer_id: 2}} = Client.search_artist("drake")
    end

    test "returns :not_found when no artist matches", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"data" => []}))
      end)

      assert {:error, :not_found} = Client.search_artist("unknownartist")
    end

    test "returns error when API is unavailable", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, _reason} = Client.search_artist("drake")
    end

    test "returns error on non-200 status", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/search/artist", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(403, Jason.encode!(%{"error" => "rate limited"}))
      end)

      assert {:error, {:deezer_error, 403}} = Client.search_artist("drake")
    end
  end

  describe "get_albums/1" do
    test "returns albums from a single page", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/artist/13/albums", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"title" => "Album 1", "release_date" => "2020-01-01"},
              %{"title" => "Album 2", "release_date" => "2021-01-01"}
            ]
          })
        )
      end)

      assert {:ok, albums} = Client.get_albums(13)
      assert length(albums) == 2
      assert Enum.any?(albums, &(&1.title == "Album 1"))
    end

    test "handles pagination", %{bypass: bypass} do
      call_count = :counters.new(1, [:atomics])

      Bypass.expect(bypass, "GET", "/artist/13/albums", fn conn ->
        :counters.add(call_count, 1, 1)
        count = :counters.get(call_count, 1)

        response =
          if count == 1 do
            %{
              "data" => [
                %{"title" => "Album 1", "release_date" => "2020-01-01"}
              ],
              "next" => "http://localhost:#{bypass.port}/artist/13/albums?index=25"
            }
          else
            %{
              "data" => [
                %{"title" => "Album 2", "release_date" => "2021-01-01"}
              ]
            }
          end

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response))
      end)

      assert {:ok, albums} = Client.get_albums(13)
      assert length(albums) == 2
    end

    test "returns :not_found when no albums exist", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/artist/13/albums", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"data" => []}))
      end)

      assert {:error, :not_found} = Client.get_albums(13)
    end

    test "returns error when API is unavailable", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, _reason} = Client.get_albums(13)
    end

    test "returns error on non-200 status", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/artist/13/albums", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"error" => "internal server error"}))
      end)

      assert {:error, {:deezer_error, 500}} = Client.get_albums(13)
    end
  end
end
