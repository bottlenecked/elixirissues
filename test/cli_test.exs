defmodule CliTest do
    use ExUnit.Case
    doctest Issues
    
    import Issues.CLI, only: [
                           parse_args: 1,
                           sort_into_ascending_order: 1,
                           convert_to_list_of_maps: 1
                       ]
    
    test ":help returned when specifying --help or -h options" do
        assert parse_args(["-h", "anything"]) == :help
        assert parse_args(["--help", "anything"]) == :help
    end
    
    test "three values returned if all params specified" do
        assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
    end
    
    test "count defaults to '4' if only two params specified" do
        {_, __, count} = parse_args(["user", "project"])
        assert  count==4 
    end
    
    test "sort ascending order the correct way" do
        result = ["c", "a", "b"]
                    |> fake_created_at_list
                    |> sort_into_ascending_order
        
        issues = for issue <- result, do: issue["created_at"]
        assert issues == ~w{a b c}
    end
    
    defp fake_created_at_list(values) do
        data = for value <- values,
                do: [{"created_at", value}, {"other_data", "xxx"}]
        convert_to_list_of_maps data
    end
end