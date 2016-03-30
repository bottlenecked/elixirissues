defmodule Issues.CLI do
    @default_count  4
    
    @moduledoc """
    Handles command line parsing and dispatch
    """
    
    def run(argv) do
        argv
        |> parse_args
        |> process
        |> decode_response
        #|> convert_to_list_of_maps
        |> sort_into_ascending_order
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
    
    def process(:help) do
        IO.puts """
            usage issues <user> <project> [<count> | #{@default_count}]
        """
        System.halt(0)
    end
    
    def process ({user, project, _count}) do
        Issues.GithubIssues.fetch(user, project)
        |> decode_response
    end
    
    def decode_response({:ok, body}) do
        body
    end
    
    def decode_response({:error, error}) do
        {_, message} = List.keyfind(error, "message", 0)
        IO.puts "Error fetching from github: #{message}"
        System.halt(2)
    end
    
    def convert_to_list_of_maps(list) do
        list
        |> Enum.map(&Enum.into(&1, Map.new))
    end
    
    def sort_into_ascending_order(list) do
        Enum.sort list, fn i1, i2 -> i1["created_at"] <= i2["created_at"] end
    end
end