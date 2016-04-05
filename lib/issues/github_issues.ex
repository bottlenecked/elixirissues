defmodule Issues.GithubIssues do
    require Logger
    
    @user_agent [{"User-agent", "Elixir test project issues"}]
    
    def fetch(user, project) do
        Logger.info "fetching user's #{user} project #{project}"
        issues_url(user, project)
        |> HTTPoison.get(@user_agent)
        |> handle_response
    end
    
    @github_url Application.get_env(:issues, :github_url)
    
    def issues_url(user, project) do
        "#{@github_url}/repos/#{user}/#{project}/issues"
    end
    
    def handle_response({:ok, %{status_code: 200, body: body}}) do
        {:ok, Poison.Parser.parse!(body)}
    end
    
    def handle_response({_, %{status_code: status, body: body}}) do
        Logger.error " Error #{status} returned"
        {:error, Poison.Parser.parse!(body)}
    end
    
end