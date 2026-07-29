defmodule SongExplorer.Deezer.Client do
  @base_url "https://api.deezer.com"
  @doc """
  Recherche un artiste par nom et retourne le plus populaire (nb_fan).
  """
  def search_artist(name) do
    case Req.get("#{@base_url}/search/artist", params: [q: name]) do
      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        %{"name" => artist_name, "id" => artist_id} =
          Enum.max_by(data, fn %{"nb_fan" => nb_fan} -> nb_fan end)

        {:ok, %{name: artist_name, deezer_id: artist_id}}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Récupère les albums d'un artiste via son Deezer ID.
  """
  def get_albums(deezer_id) do
    fetch_all_albums("#{@base_url}/artist/#{deezer_id}/albums", [])
  end

  defp fetch_all_albums(url, acc) do
    case Req.get(url) do
      {:ok, %{status: 200, body: %{"data" => data, "next" => next_page_url}}}
      when data != [] ->
        fetch_all_albums(next_page_url, extract_albums(data, acc))

      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        {:ok, Enum.reverse(extract_albums(data, acc))}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        if acc == [], do: {:error, :not_found}, else: {:ok, Enum.reverse(acc)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_albums(data, acc) do
    Enum.reduce(data, acc, fn %{"title" => title, "release_date" => release_date}, acc ->
      [%{title: title, release_date: release_date} | acc]
    end)
  end
end
