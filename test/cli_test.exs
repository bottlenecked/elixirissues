defmodule CliTest do
    use ExUnit.Case
    doctest Issues
    
    import Issues.CLI, only: [parse_args: 1]
    
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
end