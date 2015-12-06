defmodule Issues.GithubIssues do
  @moduledoc false

  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"}]

  # use a module attribute to fetch the value at compile time
  @github_url  Application.get_env(:issues,:github_url)

  def fetch(user , project) do
    issues_url(user,project)
    |>  HttpPoison.get(@user_agent)
    |>  handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response(%{statues_code: 200 , body: body}) ,
  do: { :ok , :jsx.decode(body) }

  def handle_response(%{status_code: ____, body: body }),
  do: { :error , :jsx.decode(body) }
end