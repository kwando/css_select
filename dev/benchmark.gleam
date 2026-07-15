import css_select/internal/parser as handrolled_parser
import css_select/internal/parser_splitter as ps
import css_select/selector
import gleam/io
import gleam/result
import gleamy/bench
import parser_nibble as nibble_parser

type ParseResult =
  Result(selector.Selector, String)

fn parse_nibble(input: String) -> ParseResult {
  nibble_parser.parse_simple_selector(input)
  |> result.map_error(fn(_e) { "nibble_error" })
}

fn parse_handrolled(input: String) -> ParseResult {
  handrolled_parser.parse_simple_selector(input)
  |> result.map_error(fn(_e) { "handrolled_error" })
}

pub fn main() {
  let splitter_parser = ps.new()

  let parse_splitter = fn(input: String) -> ParseResult {
    ps.parse_simple_selector(splitter_parser, input)
    |> result.map_error(fn(_e) { "splitter_error" })
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
    bench.Function("handrolled", parse_handrolled),
    bench.Function("splitter", parse_splitter),
  ]

  let options = [
    bench.Duration(2000),
    bench.Warmup(200),
  ]

  bench.run(inputs, functions, options)
  |> bench.table([bench.IPS, bench.Min, bench.Mean, bench.P(99)])
  |> io.println
}
