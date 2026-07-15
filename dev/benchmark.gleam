import css_select/internal/parser as splitter_parser
import css_select/selector
import gleam/io
import gleam/result
import gleamy/bench
import parser_graphemes as graphemes_parser
import parser_nibble as nibble_parser
import report

type ParseResult =
  Result(selector.Selector, String)

fn parse_nibble(input: String) -> ParseResult {
  nibble_parser.parse_simple_selector(input)
  |> result.map_error(fn(_e) { "nibble_error" })
}

fn parse_graphemes(input: String) -> ParseResult {
  graphemes_parser.parse_simple_selector(input)
  |> result.map_error(fn(_e) { "graphemes_error" })
}

pub fn main() {
  let splitter_parser_instance = splitter_parser.new()

  let parse_splitter = fn(input: String) -> ParseResult {
    splitter_parser.parse_simple_selector_with_parser(
      splitter_parser_instance,
      input,
    )
    |> result.map_error(fn(_e) { "splitter_error" })
  }

  let parse_splitter_new = fn(input: String) -> ParseResult {
    splitter_parser.parse_simple_selector(input)
    |> result.map_error(fn(_e) { "splitter_new_error" })
  }

  let inputs = [
    bench.Input("simple tag", "div"),
    bench.Input("multiple classes", ".foo.bar.baz"),
    bench.Input("id selector", "#myId"),
    bench.Input("complex selector", "div#foo.bar.baz[href]:checked"),
    bench.Input("quoted attribute", "[href=\"https://example.com\"]"),
  ]

  let functions = [
    bench.Function("nibble", parse_nibble),
    bench.Function("graphemes", parse_graphemes),
    bench.Function("splitter", parse_splitter),
    bench.Function("splitter_new", parse_splitter_new),
  ]

  // Quick dev mode: uncomment for fast iteration
  //let options = [bench.Duration(100), bench.Warmup(10)]
  let options = [bench.Duration(2000), bench.Warmup(200)]

  bench.run(inputs, functions, options)
  |> report.table
  |> io.println
}
