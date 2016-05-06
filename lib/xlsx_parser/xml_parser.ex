require Logger

defmodule XlsxParser.XmlParser do
  import SweetXml

  @type col_row_val :: {String.t, integer, String.t}

  @spec parse_xml_content(String.t, map) :: [col_row_val]
  def parse_xml_content(xml, shared_strings) do
    ret = xml
    #|> stream_tags(:c) #poor performance after ~5k elements
    |> xpath(~x"//worksheet/sheetData/row/c"l)
    |> Stream.map(&parse_from_element(&1,shared_strings))
    |> Enum.into([])
    ret
  end

  @spec parse_from_element(tuple, map) :: {String.t, integer, String.t}
  defp parse_from_element({:xmlElement,:c,:c,_,_,_,_,attributes,elements,_,_,_}, shared_strings) do
    {:xmlAttribute, :r, _,_,_,_,_,_,col_row,_} = attributes |> Enum.find(&elem(&1, 1) == :r)
    text = case elements |> Enum.find(&elem(&1, 1) == :v) do
      nil -> ""
      {:xmlElement,:v,:v,_,_,_,_,_,text_chunks,_,_,_} ->
        case text_chunks do
          [{_,_,_,_,txt,_}] -> txt
          x when is_list(x) -> Enum.reduce(text_chunks, '', fn {_,_,_,_,txt,_}, acc -> acc ++ txt end)
        end
    end
    text = case attributes |> Enum.find(fn attr -> elem(attr, 1) == :t and elem(attr, 8) == 's' end) do
      nil -> text
      _ -> shared_strings[text]
    end
    text = cond do
      String.contains?("#{text}", "\n") -> '"' ++ text ++ '"'
      true -> text
    end
    {col, row} = parse_col_row(col_row)
    {col, row, "#{text}"}
  end

  @spec parse_col_row([char]) :: {String.t, integer}
  defp parse_col_row(col_row) do
    _parse_col_row([],[], col_row)
  end

  @spec _parse_col_row([char], [char], [char]) :: {String.t, integer}
  defp _parse_col_row(col, row, []), do: {"#{col}", "#{row}" |> Integer.parse |> elem(0)}
  defp _parse_col_row(col, row, [h|t]) when h in ?A..?Z, do: _parse_col_row(col ++ [h], row, t)
  defp _parse_col_row(col, row, [h|t]) when h in ?0..?9, do: _parse_col_row(col, row ++ [h], t)

  @spec parse_shared_strings(String.t) :: map
  def parse_shared_strings(xml) do
    xml
    |> xpath(~x"//si/t"l)
    |> Enum.reduce(HashDict.new, fn {:xmlElement,:t,:t,_,_,si,_,_,text_chunks,_,_,_}, acc ->
                                    text = case text_chunks do
                                      [{_,_,_,_,txt,_}] -> txt
                                      x when is_list(x) -> Enum.reduce(text_chunks, '', fn {_,_,_,_,txt,_}, acc -> acc ++ txt end)
                                    end
                                    Dict.put_new(acc, String.to_char_list("#{si[:si]-1}"), text)
                                 end)
  end

end