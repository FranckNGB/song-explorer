defmodule SongExplorer.Repo.Migrations.UpdateAlbumsOnDeleteCascade do
  use Ecto.Migration

  def change do
    alter table(:albums) do
      modify :artist_id, references(:artists, on_delete: :delete_all),
        from: references(:artists, on_delete: :nothing)
    end
  end
end
