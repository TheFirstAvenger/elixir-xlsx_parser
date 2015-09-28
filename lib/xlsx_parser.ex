require Logger

defmodule XlsxParser do

  alias XlsxParser.XlsxUtil
  alias XlsxParser.XmlParser


  @doc """
  Given a path do an .xlsx and the sheet number (1 based index), this function returns a list of values in the
  sheet. The values are returned as a list of {column, row, value} tuples. An optional parameter of the zip
  processing module is allowed (for testing purposes).
  """
  @spec get_sheet_content(String.t, integer, module) :: {:ok, XmlParser.col_row_val} | {:error, String.t}
  def get_sheet_content(path, sheet_number, zip \\ :zip) do
    case XlsxUtil.validate_path(path) do
      {:error, reason} -> {:error, reason}
      {:ok, path}      ->
        path
        |> XlsxUtil.get_shared_strings(zip)
        |> case do
          {:error, reason} -> {:error, reason}
          {:ok, shared_strings} ->
            Logger.debug "Retrieved shared strings for #{Path.rootname(path)}"
            path
            |> XlsxUtil.get_raw_content("xl/worksheets/sheet#{sheet_number}.xml", zip)
            |> case do
              {:error, reason} -> {:error, reason}
              {:ok, content}   ->
                Logger.debug "Retrieved content for #{Path.rootname(path)}"
                ret = content
                |> XmlParser.parse_xml_content(shared_strings)
                Logger.debug "Parsed xml for #{Path.rootname(path)}"
                {:ok, ret}
            end
        end
    end
  end

  @doc """
  Given a path to an .xlsx, a sheet number, and a path to a csv, this function writes the content of the specified
  sheet to the specified csv path.
  """
  @spec write_sheet_content_to_csv(String.t, integer, String.t, module, module) :: {:ok, String.t} | {:error, String.t}
  def write_sheet_content_to_csv(xlsx_path, sheet_number, csv_path, zip \\ :zip, file \\ File) do
    case get_sheet_content(xlsx_path, sheet_number, zip) do
      {:error, reason} -> {:error, reason}
      {:ok, content}   ->
        csv = XlsxUtil.col_row_vals_to_csv(content)
        case file.write(csv_path, csv) do
          {:error, reason} -> {:error, "Error writing csv file: #{inspect reason}"}
          :ok              -> {:ok, csv}
        end
    end
  end
end