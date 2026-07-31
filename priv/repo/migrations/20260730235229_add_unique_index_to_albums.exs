defmodule SongExplorer.Repo.Migrations.AddUniqueIndexToAlbums do
  use Ecto.Migration

  def change do
    create unique_index(:albums, [:artist_id, :title], name: :albums_artist_id_title_index)
  end
end
