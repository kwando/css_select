import css_select/internal/parser
import css_select/selector.{
  Any, AttributeEqual, AttributeExists, AttributeIncludes, AttributePrefix,
  AttributeSuffix, Class, ElementSelector, Id, Psuedo, Tag,
}
import gleeunit/should

pub fn parse_simple_selector_test() {
  parser.parse_simple_selector("div.foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Tag("div"), [Class("foo"), Class("bar"), Id("myId")]),
  )

  parser.parse_simple_selector(".foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [Class("foo"), Class("bar"), Id("myId")]),
  )

  parser.parse_simple_selector(".foo-bar")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Class("foo-bar")]))
}

pub fn parse_attribute_exists_test() {
  parser.parse_simple_selector("[href]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeExists("href")]))
}

pub fn parse_attribute_equals_test() {
  parser.parse_simple_selector("[foo=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeEqual("foo", "bar")]))
  parser.parse_simple_selector("[href=\"https://www.example.com\"]")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [AttributeEqual("href", "https://www.example.com")]),
  )
}

pub fn parse_attribute_prefix_test() {
  parser.parse_simple_selector("[foo^=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributePrefix("foo", "bar")]))
}

pub fn parse_attribute_suffix_test() {
  parser.parse_simple_selector("[foo$=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeSuffix("foo", "bar")]))
}

pub fn parse_attribute_includes_test() {
  parser.parse_simple_selector("[foo*=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeIncludes("foo", "bar")]))
}

pub fn parse_attribute_psuedo_class_test() {
  parser.parse_simple_selector(":checked")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("checked")]))

  parser.parse_simple_selector(":disabled")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("disabled")]))

  parser.parse_simple_selector(":hello")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Psuedo("hello")]))
}
