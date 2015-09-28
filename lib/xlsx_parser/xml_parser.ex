defmodule XlsxParser.XmlParser do
  import SweetXml

  @type ss :: {integer, String.t}
  @type col_row_val :: {String.t, integer, String.t}

  @spec parse_xml_content(String.t, [ss]) :: [col_row_val]
  def parse_xml_content(xml, shared_strings) do
    xml
    |> stream_tags(:c)
    |> Stream.map(&parse_from_element(&1,shared_strings))
    |> Enum.into([])
  end

  @spec parse_from_element(tuple, [ss]) :: {String.t, integer, String.t}
  defp parse_from_element({:c, {:xmlElement,:c,:c,_,_,_,_,attributes,elements,_,_,_}}, shared_strings) do
    {:xmlAttribute, :r, _,_,_,_,_,_,col_row,_} = attributes |> Enum.find(&elem(&1, 1) == :r)
    text = case elements |> Enum.find(&elem(&1, 1) == :v) do
      nil -> ""
      {:xmlElement,:v,:v,_,_,_,_,_,[{_,_,_,_,text,_}],_,_,_} -> text
    end
    text = case attributes |> Enum.find(&elem(&1, 1) == :t) do
      nil -> text
      _ -> get_shared_string(shared_strings, text)
    end
    {col, row} = parse_col_row(col_row)
    {col, row, "#{text}"}
  end

  @spec get_shared_string([ss], String.t) :: String.t
  defp get_shared_string(shared_strings, text) do
    shared_strings
    |> Enum.find(fn {key, _value} -> "#{key}" == "#{text}" end)
    |> elem(1)
  end

  @spec parse_col_row([char]) :: {String.t, integer}
  defp parse_col_row(col_row) do
    _parse_col_row([],[], col_row)
  end

  @spec _parse_col_row([char], [char], [char]) :: {String.t, integer}
  defp _parse_col_row(col, row, []), do: {"#{col}", "#{row}" |> Integer.parse |> elem(0)}
  defp _parse_col_row(col, row, [h|t]) when h in ?A..?Z, do: _parse_col_row(col ++ [h], row, t)
  defp _parse_col_row(col, row, [h|t]) when h in ?0..?9, do: _parse_col_row(col, row ++ [h], t)

  @spec parse_shared_strings(String.t) :: [ss]
  def parse_shared_strings(xml) do
    xml
    |> xpath(~x"//si/t"l)
    |> Enum.map(fn {:xmlElement,:t,:t,_,_,si,_,_,[{_,_,_,_,text,_}],_,_,_} -> {si[:si]-1, text} end)
  end

end