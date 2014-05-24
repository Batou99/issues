defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to 
  the various functions that end up generating a 
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
    |> print
  end

  def print(list_of_issues) do
    print_header list_of_issues
    for issue <- list_of_issues do
      pretty_print issue
    end
  end

  def print_header(list_of_issues) do
    max = Enum.map(list_of_issues, fn issue -> String.length(issue["title"]) end)
    |> Enum.max
    num_header = String.ljust("",6,?-)
    date_header = String.ljust("",22,?-)
    title_header = String.ljust("",max+1,?-)
    IO.puts "Number| Created at           | Title" 
    IO.puts "#{num_header}+#{date_header}+#{title_header}"
  end

  def pretty_print(issue) do
    number = issue["number"]
    number = String.ljust("#{number}",5)
    created_at = issue["created_at"]
    title = issue["title"]
    IO.puts "#{number} | #{created_at} | #{title}"
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
    aliases: [h: :help])

    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [user, project, count], _ } -> { user, project, binary_to_integer(count) }
      { _, [user, project ], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt 0
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project) 
    |> decode_response
    |> convert_to_list_of_hashdicts
    |> sort_into_ascending_order
    |> Enum.take count
  end

  def decode_response({:ok, body}), do: :jsx.decode(body)
  def decode_response({:error, msg}) do
    error = :jsx.decode(msg)["message"]
    IO.puts "Error fetching from Github: #{error}"
    System.halt(2)
  end

  def convert_to_list_of_hashdicts(list) do
    list |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues, fn i1,i2 -> i1["created_at"] <= i2["created_at"] end
  end
end


