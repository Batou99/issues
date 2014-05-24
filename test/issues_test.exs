defmodule IssuesTest do
  use ExUnit.Case

  import Issues.CLI, only: [ 
                             parse_args: 1,
                             sort_into_ascending_order: 1,
                             convert_to_list_of_hashdicts: 1
                           ]

  test ":help returned by option parsing with --help or -h" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "Three values returned if tree given" do
    assert parse_args(["user","project","99"]) == { "user", "project", 99 }
  end

  test "count is defaulted if 2 values given" do
    assert parse_args(["user","project"]) == { "user", "project", 4 }
  end

  test "Sort in ascending order the correct way" do
    result = sort_into_ascending_order(fake_created_at_list(["c","a","b"]))
    issues = for issue <- result, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp fake_created_at_list(values) do
    data = for value <- values,
      do: [{"created_at", value}, {"other_data", "xxx"}]
    convert_to_list_of_hashdicts data
  end
end
