defmodule SongExplorer.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SongExplorer.Catalog` context.
  """

  @doc """
  Generate a artist.
  """
  def artist_fixture(attrs \\ %{}) do
    {:ok, artist} =
      attrs
      |> Enum.into(%{
        deezer_id: 42,
        name: "some name"
      })
      |> SongExplorer.Catalog.create_artist()

    artist
  end

  @doc """
  Generate a album.
  """
  def album_fixture(attrs \\ %{}) do
    artist = artist_fixture()

    {:ok, album} =
      attrs
      |> Enum.into(%{
        release_date: ~D[2026-07-28],
        title: "some title",
        artist_id: artist.id
      })
      |> SongExplorer.Catalog.create_album()

    album
  end
end
