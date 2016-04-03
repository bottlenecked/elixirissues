defmodule Issues.CLI do
    @default_count  4
    
    @moduledoc """
    Handles command line parsing and dispatch
    """
    
    def run(argv) do
        argv
        |> parse_args
        |> process
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
    
    def process ({user, project, count}) do
        items = Issues.GithubIssues.fetch(user, project)
        |> decode_response
        |> convert_to_list_of_maps
        |> sort_into_ascending_order
        |> Enum.take(count)
        |> get_req_fields
        |> append_headers
        
        len = count_lengthiest items
        
        [ljhead|ljtail] = for item<-items do
            {String.ljust(elem(item, 0), elem(len,0)), String.ljust(elem(item, 1), elem(len,1)), String.ljust(elem(item, 2), elem(len,2))}
        end
        
        final = [ljhead | [{ String.rjust("", elem(len,0), ?-), String.rjust("", elem(len,1), ?-), String.rjust("-", elem(len,2), ?-)} | ljtail]]
        
        for item<-final, do: print elem(item, 0), elem(item, 1), elem(item, 2)
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
    
    def get_req_fields(list) do
        for map<-list do
            {Integer.to_string(map["number"])<>" ", " "<>map["created_at"]<>" ", " "<>map["title"]}
        end
    end
    
    def append_headers(list) do
        [{" # ", " created_at ", " title "} | list]
    end
    
    def count_lengthiest(list, a\\0, b\\0, c\\0)
    
    def count_lengthiest([], a, b, c) do
        {a,b,c}
    end
    
    def count_lengthiest([head|tail], a, b ,c) do
        count_lengthiest tail, max(a, String.length elem(head, 0)), max(b, String.length elem(head, 1)), max(c, String.length elem(head, 2))
    end
    
    def print(number="-"<>_, date, title), do: IO.puts "#{number}+#{date}+#{title}"
    def print(number, date, title), do: IO.puts "#{number}|#{date}|#{title}"
end