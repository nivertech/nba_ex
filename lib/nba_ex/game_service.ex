defmodule NbaEx.GameService do
  alias NbaEx.{Game, PlayByPlay, PlayerStat, Scoreboard, TeamStat, Utils}

  @boxscore   "boxscore.json"
  @pbp        "pbp"
  @scoreboard "scoreboard.json"

  def get_boxscore(date, game_id) do
    @boxscore
    |> Utils.build_url(date, game_id)
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!(
      as: %{
        "basicGameData" => %Game{},
        "stats" => %{
          "vTeam" => %TeamStat{},
          "hTeam" => %TeamStat{},
          "activePlayers" => [%PlayerStat{}]
        }
      }
    )
    |> build_boxscore
  end

  def play_by_play(date, game_id, period) do
    @pbp
    |> Utils.build_url(date, game_id, period)
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!(as: %PlayByPlay{})
  end

  def get_scoreboard(date) do
    with %HTTPoison.Response{body: body, status_code: 200} <-
      @scoreboard
      |> Utils.build_url(date)
      |> HTTPoison.get!()
    do
      Poison.decode!(body, as: %Scoreboard{games: [%Game{}]})
    else
      _ -> {:error, "#{date} is not a valid date. Proper format is: YYYYMMDD"}
    end
  end
  def get_scoreboard, do: get_scoreboard(Utils.current_date())

  defp build_boxscore(%{
         "basicGameData" => game,
         "stats" => %{
           "vTeam" => away_team_stats,
           "hTeam" => home_team_stats,
           "activePlayers" => player_stats
         }
       })
  do
    %NbaEx.Boxscore{
      game: game,
      away_team_stats: away_team_stats,
      home_team_stats: home_team_stats,
      player_stats: player_stats
    }
  end
end