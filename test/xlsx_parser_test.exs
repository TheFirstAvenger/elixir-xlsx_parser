defmodule XlsxParserTest do
  use ExUnit.Case

  test "get_sheet_content invalid path" do
    {status, reason} = XlsxParser.get_sheet_content("invalid path.txt", 1)
    assert status == :error
    assert reason == "Path must be for an .xlsx"
  end

  defmodule ZipMock do
    def zip_open(_, _), do: {:ok, SimpleAgent.start!}
    def zip_get('xl/sharedStrings.xml', _), do: {:ok, {:abc, '<sst><si><t>one</t></si><si><t>two</t></si><si><t>three</t></si></sst>'}}
    def zip_get('xl/worksheets/sheet1.xml', _), do: {:ok, {:abc, '<worksheet><sheetData><row><c r="A1"><v>a</v></c><c r="A2" t="s"><v>1</v></c><c r="A3"><v>c</v></c></row><row><c r="B1"><v>d</v></c><c r="B2" t="s"><v>2</v></c><c r="B3"><v>f</v></c></row></sheetData></worksheet>'}}
    def zip_close(_), do: :ok
  end

  test "get_sheet_content success" do
    {status, ret} = XlsxParser.get_sheet_content("/path/to/my.xlsx", 1, ZipMock)
    assert status == :ok
    assert ret == [{"A", 1, "a"}, {"A", 2, "two"}, {"A", 3, "c"}, {"B", 1, "d"},{"B", 2, "three"}, {"B", 3, "f"}]
  end

  defmodule FileMock do
    def write(loc, content) do
      assert loc == "/path/to/my.csv"
      assert content == "a,d\ntwo,three\nc,f\n"
      :ok
    end
  end

  test "write_sheet_content_to_csv success" do
    {status, ret} = XlsxParser.write_sheet_content_to_csv("/path/to/my.xlsx", 1, "/path/to/my.csv", ZipMock, FileMock)
    assert status == :ok
    assert ret == "a,d\ntwo,three\nc,f\n"
  end

  defmodule FileMockFail do
    def write(_loc, _content), do: {:error, "file mock write fail"}
  end

  test "write_sheet_content_to_csv failure" do
    {status, reason} = XlsxParser.write_sheet_content_to_csv("/path/to/my.xlsx", 1, "/path/to/my.csv", ZipMock, FileMockFail)
    assert status == :error
    assert reason == "Error writing csv file: \"file mock write fail\""
  end

end
