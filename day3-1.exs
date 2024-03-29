{:ok, input} = File.read("inputs/day3.txt")

defmodule AOC do
	def handle_intersect(old, new) do
		case {old, new} do
			{:first, :second} -> :intersect
			{:second, :first} -> raise "Invalid map crossing?"
			_ -> old
		end
	end

	def offset(dir, {x, y}, distance) do
		case dir do
			:up -> {x, y + distance}
			:down -> {x, y - distance}
			:right -> {x + distance, y}
			:left -> {x - distance, y}
		end
	end

	def draw_line(grid, {x, y}, {dir, distance}, ident) do
		if distance == 0 do
			grid
		else
			pos = offset(dir, {x, y}, distance)
			
			grid |> Map.update(pos, ident, &handle_intersect(&1, ident))
			|> draw_line({x, y}, {dir, distance - 1}, ident)
		end
	end

	def follow(grid, coords, [{dir, distance} | tail], ident) do
		grid |> draw_line(coords, {dir, distance}, ident)
		|> follow(offset(dir, coords, distance), tail, ident)
	end

	def follow(grid, _, [], _) do
		grid
	end

	def closest_intersection(grid) do
		{coords, _} = grid |> Enum.filter(fn {_, n} -> n == :intersect end)
		|> Enum.min_by(fn {{x, y}, _} -> abs(x) + abs(y) end)

		coords
	end

	def closest_dist(grid) do
		{x, y} = closest_intersection(grid)

		abs(x) + abs(y)
	end

	def parse(command) do
		{direction, distance} = command |> String.split_at(1)
		distance = distance |> String.to_integer

		case direction do
			"U" -> {:up, distance}
			"R" -> {:right, distance}
			"L" -> {:left, distance}
			"D" -> {:down, distance}
			_ -> raise "Invalid direction!"
		end
	end

	def parse_input(input) do
		input |> String.split(",") |> Enum.map(&parse/1)
	end

	def run(input) do
		[first, second] = input |> String.trim |> String.split |> Enum.map(&parse_input/1)

		grid = follow(%{}, {0, 0}, first, :first)
		grid = follow(grid, {0, 0}, second, :second)

		grid |> closest_dist
	end
end

IO.puts(input |> AOC.run)
