defmodule SongExplorer.CatalogTest do
  use SongExplorer.DataCase

  alias SongExplorer.Catalog

  describe "artists" do
    alias SongExplorer.Catalog.Artist

    import SongExplorer.CatalogFixtures

    @invalid_attrs %{name: nil, deezer_id: nil}

    test "list_artists/0 returns all artists" do
      artist = artist_fixture()
      assert Catalog.list_artists() == [artist]
    end

    test "get_artist!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert Catalog.get_artist!(artist.id) == artist
    end

    test "get_artist_by_name/1 returns the artist with preloaded albums" do
      artist = artist_fixture(%{name: "Drake", deezer_id: 246_791})
      album_fixture(%{artist_id: artist.id})

      result = Catalog.get_artist_by_name(artist.name)

      assert result.name == artist.name
      assert result.deezer_id == artist.deezer_id
      assert length(result.albums) == 1
    end

    test "get_artist_by_name/1 returns nil when artist does not exist" do
      assert Catalog.get_artist_by_name("Inconnu") == nil
    end

    test "save_artist_with_albums/2 saves artist and albums" do
      artist_attrs = %{name: "Eminem", deezer_id: 13}

      albums_attrs = [
        %{title: "The Slim Shady LP", release_date: "1999-02-23"},
        %{title: "The Marshall Mathers LP", release_date: "2000-05-23"}
      ]

      assert {:ok, _result} = Catalog.save_artist_with_albums(artist_attrs, albums_attrs)

      artist = Catalog.get_artist_by_name("Eminem")
      assert artist.deezer_id == 13
      assert length(artist.albums) == 2
    end

    test "save_artist_with_albums/2 with invalid artist returns error" do
      artist_attrs = %{name: nil, deezer_id: nil}
      albums_attrs = [%{title: "Album", release_date: "2024-01-01"}]

      assert {:error, _changeset} = Catalog.save_artist_with_albums(artist_attrs, albums_attrs)
      assert Catalog.list_artists() == []
    end

    test "create_artist/1 with valid data creates a artist" do
      valid_attrs = %{name: "some name", deezer_id: 42}

      assert {:ok, %Artist{} = artist} = Catalog.create_artist(valid_attrs)
      assert artist.name == "some name"
      assert artist.deezer_id == 42
    end

    test "create_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_artist(@invalid_attrs)
    end

    test "update_artist/2 with valid data updates the artist" do
      artist = artist_fixture()
      update_attrs = %{name: "some updated name", deezer_id: 43}

      assert {:ok, %Artist{} = artist} = Catalog.update_artist(artist, update_attrs)
      assert artist.name == "some updated name"
      assert artist.deezer_id == 43
    end

    test "update_artist/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_artist(artist, @invalid_attrs)
      assert artist == Catalog.get_artist!(artist.id)
    end

    test "delete_artist/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = Catalog.delete_artist(artist)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_artist!(artist.id) end
    end

    test "change_artist/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = Catalog.change_artist(artist)
    end
  end

  describe "albums" do
    alias SongExplorer.Catalog.Album

    import SongExplorer.CatalogFixtures

    @invalid_attrs %{title: nil, release_date: nil}

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Catalog.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Catalog.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      artist = artist_fixture()
      valid_attrs = %{title: "some title", release_date: ~D[2026-07-28], artist_id: artist.id}

      assert {:ok, %Album{} = album} = Catalog.create_album(valid_attrs)
      assert album.title == "some title"
      assert album.release_date == ~D[2026-07-28]
      assert album.artist_id == artist.id
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      update_attrs = %{title: "some updated title", release_date: ~D[2026-07-29]}

      assert {:ok, %Album{} = album} = Catalog.update_album(album, update_attrs)
      assert album.title == "some updated title"
      assert album.release_date == ~D[2026-07-29]
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_album(album, @invalid_attrs)
      assert album == Catalog.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Catalog.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Catalog.change_album(album)
    end
  end
end
