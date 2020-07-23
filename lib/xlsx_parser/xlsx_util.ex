defmodule XlsxParser.XlsxUtil do
  @moduledoc false
  alias XlsxParser.XmlParser

  @spec get_shared_strings(String.t(), module) :: {:ok, [XmlParser.ss()]} | {:error, String.t()}
  def get_shared_strings(path, zip \\ :zip) do
    path
    |> get_raw_content("xl/sharedStrings.xml", zip)
    |> case do
      {:error, :enoent} ->
        {:ok, []}

      {:error, reason} ->
        {:error, reason}

      {:ok, content} ->
        ret =
          content
          |> XmlParser.parse_shared_strings()

        {:ok, ret}
    end
  end

  @spec get_raw_content(String.t(), String.t(), module) :: {:ok, String.t()} | {:error, any()}
  def get_raw_content(path, inner_path, zip \\ :zip) do
    with(
      {:ok, z} <- path |> to_charlist |> zip.zip_open([:memory]),
      {:ok, {_, content}} <- inner_path |> to_charlist |> zip.zip_get(z),
      :ok <- zip.zip_close(z)
    ) do
      {:ok, content}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp escape_field(data) when not is_binary(data) do
    data
  end

  defp escape_field(data) when is_binary(data) do
    data
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
    |> (fn str -> "\"" <> str <> "\"" end).()
  end

  defp escape_strings(row) do
    Enum.map(row, &escape_field(&1))
  end

  @spec col_row_vals_to_csv([XmlParser.col_row_val()]) :: String.t()
  def col_row_vals_to_csv(col_row_vals) do
    col_row_vals
    |> Enum.reduce([], fn {col, row, text}, acc ->
      # ensure there are at least as many rows as the new row's index
      acc = expand(acc, row, [])

      new_row =
        acc
        # get the old row
        |> Enum.at(row - 1)
        # Ensure there are as many columns as the new column's index
        |> expand(to_num(col), "")
        # put the new value in the new row
        |> List.replace_at(to_num(col) - 1, text)

      # replace the old row with the new row
      List.replace_at(acc, row - 1, new_row)
    end)
    |> Enum.map(&escape_strings(&1))
    |> Enum.reduce("", fn row, acc ->
      acc <> Enum.join(row, ",") <> "\n"
    end)
  end

  @spec expand(any(), any(), any()) :: any()
  def expand(list, size, item) when length(list) < size, do: expand(list ++ [item], size, item)
  def expand(list, _size, _item), do: list

  @spec to_num(binary()) :: any()
  def to_num(col), do: to_num(col |> String.to_charlist() |> hd, 1)

  @spec to_num(pos_integer(), any()) :: any()
  def to_num(?A, acc), do: acc
  def to_num(char, acc), do: to_num(char - 1, acc + 1)
end
