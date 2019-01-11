defmodule XlsxParserTest do
  use ExUnit.Case

  test "get_sheet_content invalid path" do
    {status, reason} = XlsxParser.get_sheet_content("invalid path.txt", 1)
    assert status == :error
    assert reason == "Path must be for an .xlsx"
  end

  defmodule ZipMock do
    def zip_open(_, _), do: {:ok, SimpleAgent.start!()}

    def zip_get('xl/sharedStrings.xml', _),
      do: {:ok, {:abc, '<sst><si><t>one</t></si><si><t>two</t></si><si><t>three</t></si></sst>'}}

    def zip_get('xl/worksheets/sheet1.xml', _),
      do:
        {:ok,
         {:abc,
          '<worksheet><sheetData><row><c r="A1"><v>a</v></c><c r="A2" t="s"><v>1</v></c><c r="A3"><v>c</v></c></row>' ++
            '<row><c r="B1"><v>d</v></c><c r="B2" t="s"><v>2</v></c><c r="B3"><v>f</v></c></row></sheetData></worksheet>'}}

    def zip_close(_), do: :ok
  end

  defmodule ZipMockWithInlineStrings do
    def zip_open(_, _), do: {:ok, SimpleAgent.start!()}
    def zip_get('xl/sharedStrings.xml', _), do: {:error, :enoent}

    def zip_get('xl/worksheets/sheet1.xml', _),
      do:
        {:ok,
         {:abc,
          '<worksheet><sheetData><row r="1"><c s="1" t="inlineStr" r="A1"><is><t xml:space="preserve">a</t></is></c>' ++
            '<c s="2" t="inlineStr" r="A2"><is><t xml:space="preserve">two</t></is></c><c s="3" t="inlineStr" r="A3"><is>' ++
            '<t xml:space="preserve">c</t></is></c></row><row r="2"><c s="1" t="inlineStr" r="B1"><is><t xml:space="preserve">d</t>' ++
            '</is></c><c s="2" t="inlineStr" r="B2"><is><t xml:space="preserve">three</t></is></c><c s="3" t="inlineStr" r="B3"><is>' ++
            '<t xml:space="preserve">f</t></is></c></row></sheetData></worksheet>'}}

    def zip_close(_), do: :ok
  end

  test "get_sheet_content success" do
    {status, ret} = XlsxParser.get_sheet_content("/path/to/my.xlsx", 1, ZipMock)
    assert status == :ok

    assert ret == [
             {"A", 1, "a"},
             {"A", 2, "two"},
             {"A", 3, "c"},
             {"B", 1, "d"},
             {"B", 2, "three"},
             {"B", 3, "f"}
           ]
  end

  test "get_sheet_content success without sharedStrings" do
    {status, ret} = XlsxParser.get_sheet_content("/path/to/my.xlsx", 1, ZipMockWithInlineStrings)
    assert status == :ok

    assert ret == [
             {"A", 1, "a"},
             {"A", 2, "two"},
             {"A", 3, "c"},
             {"B", 1, "d"},
             {"B", 2, "three"},
             {"B", 3, "f"}
           ]
  end

  defmodule FileMock do
    def write(loc, content) do
      assert loc == "/path/to/my.csv"
      assert content == "\"a\",\"d\"\n\"two\",\"three\"\n\"c\",\"f\"\n"
      :ok
    end
  end

  test "write_sheet_content_to_csv success" do
    {status, ret} =
      XlsxParser.write_sheet_content_to_csv(
        "/path/to/my.xlsx",
        1,
        "/path/to/my.csv",
        ZipMock,
        FileMock
      )

    assert status == :ok
    assert ret == "\"a\",\"d\"\n\"two\",\"three\"\n\"c\",\"f\"\n"
  end

  defmodule FileMockFail do
    def write(_loc, _content), do: {:error, "file mock write fail"}
  end

  test "write_sheet_content_to_csv failure" do
    {status, reason} =
      XlsxParser.write_sheet_content_to_csv(
        "/path/to/my.xlsx",
        1,
        "/path/to/my.csv",
        ZipMock,
        FileMockFail
      )

    assert status == :error
    assert reason == "Error writing csv file: \"file mock write fail\""
  end

  describe "Real File" do
    test "reads sheet 1 correctly" do
      assert {:ok,
              [
                {"A", 1, "Name"},
                {"B", 1, "Email"},
                {"C", 1, "Date Of Birth"},
                {"D", 1, "Salary"},
                {"E", 1, "Department"},
                {"A", 2, "Rajeev Singh"},
                {"B", 2, "rajeev@example.com"},
                {"C", 2, "33806.0"},
                {"D", 2, "1500000.0"},
                {"E", 2, "Software Engineering"},
                {"A", 3, "John Doe"},
                {"B", 3, "john@example.com"},
                {"C", 3, "23755.0"},
                {"D", 3, "1300000.0"},
                {"E", 3, "Sales"},
                {"A", 4, "Jack Sparrow"},
                {"B", 4, "jack@example.com"},
                {"C", 4, "31765.0"},
                {"D", 4, "1000000.0"},
                {"E", 4, "HR"},
                {"A", 5, "Steven Cook"},
                {"B", 5, "steven@example.com"},
                {"C", 5, "34458.0"},
                {"D", 5, "1200000.0"},
                {"E", 5, "Marketing"}
              ]} = XlsxParser.get_sheet_content("sample-xlsx-file.xlsx", 1)
    end

    test "reads sheet 2 correctly" do
      assert {:ok,
              [
                {"A", 1, "Name"},
                {"B", 1, "Budget"},
                {"A", 2, "Software Engineering"},
                {"B", 2, "5000000.0"},
                {"A", 3, "HR"},
                {"B", 3, "2000000.0"},
                {"A", 4, "Sales"},
                {"B", 4, "4000000.0"},
                {"A", 5, "Marketing"},
                {"B", 5, "3000000.0"}
              ]} = XlsxParser.get_sheet_content("sample-xlsx-file.xlsx", 2)
    end
  end
end
