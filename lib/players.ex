defmodule NbaEx.Players do

  def find_player_id(last_name, first_name) do
    all()
    |> find_player_match("#{last_name}, #{first_name}")
  end

  def all do
    HTTPoison.get!("http://stats.nba.com/stats/commonallplayers/?LeagueID=00&Season=2017-18&IsOnlyCurrentSeason=1", [
                            "user-agent": ('Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'),
                            "Dnt": "1",
                            "Accept": "application/json",
                            "Accept-Language": "en",
                            "origin": "http://stats.nba.com"
                          ], [timeout: 10_000, recv_timeout: 10_000]).body
    |> Poison.decode!
    |> get_players
  end
  defp get_players(%{"resultSets" => [%{"rowSet" => all_players}]}), do: all_players

  # lowercase names before matching
  # Use Enum.at?
  defp find_player_match([head | tail], formatted_name) do
    case Enum.find(head, fn(player_name) -> player_name == formatted_name end) do
      nil -> find_player_match(tail, formatted_name)
      _ -> head |> List.first
    end
  end
  defp find_player_match([], _formatted_name), do: "Player not found"
end
