require Logger

defmodule XlsxParser do
  @moduledoc false
  alias XlsxParser.XlsxUtil
  alias XlsxParser.XmlParser

  @doc """
  Given a path do an .xlsx and the sheet number (1 based index), this function returns a list of values in the
  sheet. The values are returned as a list of {column, row, value} tuples. An optional parameter of the zip
  processing module is allowed (for testing purposes).
  """
  @spec get_sheet_content(String.t(), integer, module) :: {:ok, XmlParser.col_row_val()} | {:error, String.t()}
  def get_sheet_content(path, sheet_number, zip \\ :zip) do
    with(
      {:ok, shared_strings} <- XlsxUtil.get_shared_strings(path, zip),
      {:ok, content} <- XlsxUtil.get_raw_content(path, "xl/worksheets/sheet#{sheet_number}.xml", zip),
      ret <- XmlParser.parse_xml_content(content, shared_strings)
    ) do
      Logger.debug(fn -> "Parsed xml for #{Path.rootname(path)}" end)
      {:ok, ret}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Given a path to an .xlsx, a sheet number, and a path to a csv, this function writes the content of the specified
  sheet to the specified csv path.
  """
  @spec write_sheet_content_to_csv(String.t(), integer, String.t(), module, module) :: {:ok, String.t()} | {:error, String.t()}
  def write_sheet_content_to_csv(xlsx_path, sheet_number, csv_path, zip \\ :zip, file \\ File) do
    case get_sheet_content(xlsx_path, sheet_number, zip) do
      {:error, reason} ->
        {:error, reason}

      {:ok, content} ->
        csv = XlsxUtil.col_row_vals_to_csv(content)

        case file.write(csv_path, csv) do
          {:error, reason} -> {:error, "Error writing csv file: #{inspect(reason)}"}
          :ok -> {:ok, csv}
        end
    end
  end

  @doc """
  Given a path to an .xlsx, this function returns an array of worksheet names
  """
  @spec get_worksheet_names(String.t(), module) :: {:ok, [String.t()]} | {:error, String.t()}
  def get_worksheet_names(path, zip \\ :zip) do
    case XlsxParser.XlsxUtil.get_raw_content(path, "xl/workbook.xml", zip) do
      {:error, reason} ->
        {:error, reason}

      {:ok, content} ->
        import SweetXml

        {:ok,
         content
         |> xpath(~x"//workbook/sheets/sheet/@name"l)
         |> Enum.map(&List.to_string(&1))}
    end
  end
end
