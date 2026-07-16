import css_select
import css_select/selector
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn to_string_roundtrip_test() {
  roundtrip("div")
  roundtrip("div#foo")
  roundtrip("div.bar")
  roundtrip("div#foo.bar")
  roundtrip("div#foo.bar[baz=\"buz\"]")
  roundtrip("div#foo.bar[baz=\"buz\"]:checked")
  roundtrip("div#foo.bar[baz=\"buz\"]:checked:disabled:selected:readonly")
  roundtrip(".foo")
  roundtrip("#foo")
  roundtrip(":checked")
  roundtrip("[href]")
  roundtrip("[href=\"https://example.com\"]")
  roundtrip("[href^=\"https://\"]")
  roundtrip("[href$=\".com\"]")
  roundtrip("[href*=\"example\"]")
  roundtrip("div#foo.bar[baz^=\"foo\"][qux$=\"bar\"][quux*=\"baz\"]:checked")
}

fn roundtrip(input: String) {
  css_select.parse_simple_selector(input)
  |> should.be_ok
  |> selector.to_string
  |> should.equal(input)
}

pub fn parse_empty_string_test() {
  css_select.parse_simple_selector("")
  |> should.be_ok
  |> selector.to_string
  |> should.equal("")
}

pub fn parse_whitespace_only_test() {
  css_select.parse_simple_selector(" ")
  |> should.be_ok
  |> selector.to_string
  |> should.equal(" ")
}

pub fn parse_multiple_classes_test() {
  css_select.parse_simple_selector(".foo.bar.baz")
  |> should.be_ok
  |> selector.to_string
  |> should.equal(".foo.bar.baz")
}

pub fn parse_multiple_ids_test() {
  css_select.parse_simple_selector("#foo#bar")
  |> should.be_ok
  |> selector.to_string
  |> should.equal("#foo#bar")
}

pub fn parse_multiple_pseudo_classes_test() {
  css_select.parse_simple_selector(":checked:disabled:selected")
  |> should.be_ok
  |> selector.to_string
  |> should.equal(":checked:disabled:selected")
}

pub fn parse_multiple_attributes_test() {
  css_select.parse_simple_selector("[foo][bar][baz]")
  |> should.be_ok
  |> selector.to_string
  |> should.equal("[foo][bar][baz]")
}

pub fn parse_complex_selector_test() {
  css_select.parse_simple_selector(
    "div#main.content.active[href^=\"https\"][data-test*=\"foo\"]:checked",
  )
  |> should.be_ok
  |> selector.to_string
  |> should.equal(
    "div#main.content.active[href^=\"https\"][data-test*=\"foo\"]:checked",
  )
}
