import css_select/selector.{
  Any, AttributeEqual, AttributeExists, AttributeIncludes, AttributePrefix,
  AttributeSuffix, Class, ElementSelector, Id, Psuedo, Tag, to_string,
}
import gleeunit/should

pub fn to_string_tag_only_test() {
  to_string(ElementSelector(Tag("div"), []))
  |> should.equal("div")

  to_string(ElementSelector(Any, []))
  |> should.equal("")
}

pub fn to_string_id_test() {
  to_string(ElementSelector(Any, [Id("foo")]))
  |> should.equal("#foo")
}

pub fn to_string_class_test() {
  to_string(ElementSelector(Any, [Class("foo")]))
  |> should.equal(".foo")
}

pub fn to_string_pseudo_test() {
  to_string(ElementSelector(Any, [Psuedo("checked")]))
  |> should.equal(":checked")
}

pub fn to_string_attribute_exists_test() {
  to_string(ElementSelector(Any, [AttributeExists("href")]))
  |> should.equal("[href]")
}

pub fn to_string_attribute_equal_test() {
  to_string(ElementSelector(Any, [AttributeEqual("foo", "bar")]))
  |> should.equal("[foo=\"bar\"]")
}

pub fn to_string_attribute_prefix_test() {
  to_string(ElementSelector(Any, [AttributePrefix("href", "https://")]))
  |> should.equal("[href^=\"https://\"]")
}

pub fn to_string_attribute_suffix_test() {
  to_string(ElementSelector(Any, [AttributeSuffix("href", ".com")]))
  |> should.equal("[href$=\".com\"]")
}

pub fn to_string_attribute_includes_test() {
  to_string(ElementSelector(Any, [AttributeIncludes("class", "foo")]))
  |> should.equal("[class*=\"foo\"]")
}

pub fn to_string_combined_test() {
  to_string(
    ElementSelector(Tag("div"), [
      Id("main"),
      Class("content"),
      AttributePrefix("href", "https://"),
      Psuedo("checked"),
    ]),
  )
  |> should.equal("div#main.content[href^=\"https://\"]:checked")
}

pub fn to_string_multiple_attrs_test() {
  to_string(
    ElementSelector(Tag("a"), [
      AttributeEqual("href", "/path"),
      AttributeSuffix("href", ".html"),
      AttributeIncludes("class", "active"),
    ]),
  )
  |> should.equal("a[href=\"/path\"][href$=\".html\"][class*=\"active\"]")
}
