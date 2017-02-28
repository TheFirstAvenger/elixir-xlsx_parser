defmodule XlsxParser.XlsxUtil do
  alias XlsxParser.XmlParser

  @spec get_shared_strings(String.t, module) :: {:ok, [XmlParser.ss]} | {:error, String.t}
  def get_shared_strings(path, zip \\ :zip) do
    path
    |> get_raw_content("xl/sharedStrings.xml", zip)
    |> case do
      {:error, :file_not_found} -> {:ok, []}
      {:error, reason} -> {:error, reason}
      {:ok, content}   ->
        ret = content
        |> XmlParser.parse_shared_strings
        {:ok, ret}
    end
  end

  @spec get_raw_content(String.t, String.t, module) :: {:ok | :error, String.t}
  def get_raw_content(path, inner_path, zip \\ :zip) do
    path
    |> to_char_list
    |> zip.zip_open([:memory])
    |> case do
      {:error, reason} -> {:error, reason}
      {:ok, z}         ->
        inner_path
        |> to_char_list
        |> zip.zip_get(z)
        |> case do
          {:error, reason}    -> {:error, reason}
          {:ok, {_, content}} ->
            case zip.zip_close(z) do
              {:error, reason} -> {:error, reason}
              :ok              -> {:ok, content}
            end
        end
    end
  end

  @spec validate_path(String.t) :: {:ok | :error, String.t}
  def validate_path(path) do
    path
    |> String.downcase
    |> Path.extname
    |> case do
      ".xlsx" -> {:ok, path}
      _ -> {:error, "Path must be for an .xlsx"}
    end
  end

  @spec col_row_vals_to_csv([XmlParser.col_row_val]) :: String.t
  def col_row_vals_to_csv(col_row_vals) do
    col_row_vals
    |> Enum.reduce([], fn {col, row, text}, acc ->
                          acc = expand(acc, row, []) #ensure there are at least as many rows as the new row's index
                          new_row = acc
                          |> Enum.at(row - 1) #get the old row
                          |> expand(to_num(col), "") #Ensure there are as many columns as the new column's index
                          |> List.replace_at(to_num(col) - 1, text) #put the new value in the new row
                          List.replace_at(acc, row - 1, new_row) #replace the old row with the new row
                        end)
    |> Enum.reduce("", fn row, acc ->
                        acc <> Enum.join(row, ",") <> "\n"
                       end)
  end

  def expand(list, size, item) when length(list) < size, do: expand(list ++ [item], size, item)
  def expand(list, _size, _item), do: list

  def to_num(col), do: to_num(col |> String.to_char_list |> hd, 1)

  def to_num(?A, acc), do: acc
  def to_num(char, acc), do: to_num(char - 1, acc + 1)
end
