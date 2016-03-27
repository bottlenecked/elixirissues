defmodule Issues.CLI do
    @default_count  4
    
    @moduledoc """
    Handles command line parsing and dispatch
    """
    
    def run(argv) do
        parse_args(argv)
    end
    
    @doc """
    `argv` can be -h or --help which returns :help
    
    Otherwise it is a github username, project name and (optionally) number of entries to format
        example: issues.run "Microsoft" "Aspnet.core" 5
        
    Returns a tuple of `{user, project, count}` or `:help`
    
    """
    def parse_args(argv) do
        parse = OptionParser.parse(argv, switches: [help: :boolean],
                                           aliases:  [h: :help])
        case parse do
            { [help: true], _, _} -> :help
            {_, [user, project, count], _} -> {user, project, String.to_integer count}
            {_, [user, project], _} -> {user, project, @default_count}
            _ -> :help
        end
    end
    
end