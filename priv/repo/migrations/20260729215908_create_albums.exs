defmodule SongExplorer.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :string
      add :release_date, :date
      add :artist_id, references(:artists, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:albums, [:artist_id])
  end
end
