defmodule IssuesTest do
  use ExUnit.Case

  import Issues.CLI, only: [parse_args: 1]

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
end
