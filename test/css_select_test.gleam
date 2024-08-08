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

pub fn to_string_test() {
  let input = "div#foo.bar[baz=buz]:checked:disabled:selected:readonly"

  css_select.parse_simple_selector(input)
  |> should.be_ok
  |> selector.to_string
  |> should.equal(input)
}
