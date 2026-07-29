defmodule SongExplorerTest do
  use ExUnit.Case
  doctest SongExplorer

  test "greets the world" do
    assert SongExplorer.hello() == :world
  end
end
