{:ok, input} = File.read("inputs/day5.txt")
tape = input |> String.trim |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple

tape |> Intcode.execute(0)
