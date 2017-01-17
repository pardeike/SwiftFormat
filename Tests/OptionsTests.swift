//
//  OptionsTests.swift
//  SwiftFormat
//
//  Created by Nick Lockwood on 21/10/2016.
//  Copyright © 2016 Nick Lockwood. All rights reserved.
//

import XCTest
import SwiftFormat

class OptionsTests: XCTestCase {

    // MARK: indent

    func testInferIndentLevel() {
        let input = "\t\nclass Foo {\n   func bar() {\n      //baz\n}\n}"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.indent, "   ")
    }

    // MARK: linebreak

    func testInferLinebreaks() {
        let input = "foo\nbar\r\nbaz\rquux\r\n"
        let output = "\r\n"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.linebreak, output)
    }

    // MARK: spaceAroundRangeOperators

    func testInferSpaceAroundRangeOperators() {
        let input = "let foo = 0 ..< bar\n;let baz = 1...quux"
        let output = true
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.spaceAroundRangeOperators, output)
    }

    func testInferNoSpaceAroundRangeOperators() {
        let input = "let foo = 0..<bar\n;let baz = 1...quux"
        let output = false
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.spaceAroundRangeOperators, output)
    }

    // MARK: useVoid

    func testInferUseVoid() {
        let input = "func foo(bar: () -> (Void), baz: ()->(), quux: () -> Void) {}"
        let output = true
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.useVoid, output)
    }

    func testInferDontUseVoid() {
        let input = "func foo(bar: () -> (), baz: ()->(), quux: () -> Void) {}"
        let output = false
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.useVoid, output)
    }

    // MARK: trailingCommas

    func testInferTrailingCommas() {
        let input = "let foo = [\nbar,\n]\n let baz = [\nquux\n]"
        let output = true
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.trailingCommas, output)
    }

    func testInferNoTrailingCommas() {
        let input = "let foo = [\nbar\n]\n let baz = [\nquux\n]"
        let output = false
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.trailingCommas, output)
    }

    // MARK: indentComments

    func testInferIndentComments() {
        let input = "  /**\n  hello\n    - world\n  */"
        let output = false
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.indentComments, output)
    }

    // MARK: truncateBlankLines

    func testInferNoTruncateBlanklines() {
        let input = "class Foo {\n    \nfunc bar() {\n        \n        //baz\n\n}\n    \n}"
        let output = false
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.truncateBlankLines, output)
    }

    // MARK: allmanBraces

    func testInferAllmanComments() {
        let input = "func foo()\n{\n}\n\nfunc bar() {\n}\n\nfunc baz()\n{\n}"
        let output = true
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.allmanBraces, output)
    }

    // MARK: ifdefIndent

    func testInferIfdefIndent() {
        let input = "#if foo\n    //foo\n#endif"
        let output = IndentMode.indent
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.ifdefIndent, output)
    }

    func testInferIdententIfdefIndent() {
        let input = "{\n    {\n#    if foo\n        //foo\n    #endif\n    }\n}"
        let output = IndentMode.indent
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.ifdefIndent, output)
    }

    func testInferIfdefNoIndent() {
        let input = "#if foo\n//foo\n#endif"
        let output = IndentMode.noIndent
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.ifdefIndent, output)
    }

    func testInferIdententIfdefNoIndent() {
        let input = "{\n    {\n    #if foo\n    //foo\n    #endif\n    }\n}"
        let output = IndentMode.noIndent
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.ifdefIndent, output)
    }

    func testInferIndentedIfdefOutdent() {
        let input = "{\n    {\n#if foo\n        //foo\n#endif\n    }\n}"
        let output = IndentMode.outdent
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.ifdefIndent, output)
    }

    // MARK: wrapArguments

    func testInferWrapBeforeFirstArgument() {
        let input = "func foo(bar: Int,\n    baz: String) {\n}\nfunc foo(\n    bar: Int,\n    baz: String) {\n}\nfunc foo(\n    bar: Int,\n    baz: String)"
        let output = WrapMode.beforeFirst
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.wrapArguments, output)
    }

    func testInferWrapAfterFirstArgument() {
        let input = "func foo(bar: Int,\n    baz: String,\n    quux: String) {\n}"
        let output = WrapMode.afterFirst
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.wrapArguments, output)
    }

    func testInferWrapDisabled() {
        let input = "func foo(bar: Int, baz: String,\n    quux: String) {\n}"
        let output = WrapMode.disabled
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.wrapArguments, output)
    }

    // MARK: wrapElements

    func testInferWrapElementsAfterFirstArgument() {
        let input = "[foo: 1,\n    bar: 2, baz: 3]"
        let output = WrapMode.afterFirst
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.wrapElements, output)
    }

    func testInferWrapElementsAfterSecondArgument() {
        let input = "[foo, bar,\n]"
        let output = WrapMode.afterFirst
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.wrapElements, output)
    }

    // MARK: uppercaseHex

    func testInferUppercaseHex() {
        let input = "[0xFF00DD, 0xFF00ee, 0xff00ee"
        let options = inferOptions(from: tokenize(input))
        XCTAssertTrue(options.uppercaseHex)
    }

    func testInferLowercaseHex() {
        let input = "[0xff00dd, 0xFF00ee, 0xff00ee"
        let options = inferOptions(from: tokenize(input))
        XCTAssertFalse(options.uppercaseHex)
    }

    // MARK: uppercaseExponent

    func testInferUppercaseExponent() {
        let input = "[1.34E-5, 1.34E-5]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertTrue(options.uppercaseExponent)
    }

    func testInferLowercaseExponent() {
        let input = "[1.34E-5, 1.34e-5]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertFalse(options.uppercaseExponent)
    }

    func testInferUppercaseHexExponent() {
        let input = "[0xF1.34P5, 0xF1.34P5]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertTrue(options.uppercaseExponent)
    }

    func testInferLowercaseHexExponent() {
        let input = "[0xF1.34P5, 0xF1.34p5]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertFalse(options.uppercaseExponent)
    }

    // MARK: decimalGrouping

    func testInferThousands() {
        let input = "[100_000, 1_000, 1, 23, 50]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.decimalGrouping, .threshold(3))
    }

    func testInferMillions() {
        let input = "[100_000, 1000, 1, 23, 50]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.decimalGrouping, .threshold(6))
    }

    func testInferNoDecimalGrouping() {
        let input = "[100000, 1000, 1, 23, 50]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.decimalGrouping, .none)
    }

    func testInferIgnoreDecimalGrouping() {
        let input = "[1000_00, 1000, 1, 23, 50]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.decimalGrouping, .ignore)
    }

    // MARK: binaryGrouping

    func testInferNibbleGrouping() {
        let input = "[0b100_0000, 0b1_0000, 0b1, 0b01, 0b11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.binaryGrouping, .threshold(4))
    }

    func testInferByteGrouping() {
        let input = "[0b10001101_10001101, 0b10010000, 0b1, 0b01, 0b11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.binaryGrouping, .threshold(8))
    }

    func testInferNoBinaryGrouping() {
        let input = "[0b1010100000, 0b100100, 0b1, 0b01, 0b11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.binaryGrouping, .none)
    }

    func testInferIgnoreBinaryGrouping() {
        let input = "[0b10_000_00, 0b1000_0, 0b1, 0b01, 0b11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.binaryGrouping, .ignore)
    }

    // MARK: octalGrouping

    func testInferQuadOctalGrouping() {
        let input = "[0o123_4523, 0b1_4523, 0o5, 0o23, 0o14]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.octalGrouping, .threshold(4))
    }

    func testInferOctetOctalGrouping() {
        let input = "[0o11234523_11234523, 0o12344563, 0o1, 0o01, 0o12]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.octalGrouping, .threshold(8))
    }

    func testInferNoOctalGrouping() {
        let input = "[0o11234523, 0o112345, 0o1, 0o01, 0o21]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.octalGrouping, .none)
    }

    func testInferIgnoreOctalGrouping() {
        let input = "[0o11_2345_23, 0o1000_0, 0o1, 0o01, 0o11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.octalGrouping, .ignore)
    }

    // MARK: hexGrouping

    func testInferQuadHexGrouping() {
        let input = "[0x123_FF23, 0b1_4523, 0x5, 0x23, 0x14]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.hexGrouping, .threshold(4))
    }

    func testInferOctetHexGrouping() {
        let input = "[0x112345FF_112AA523, 0x12344563, 0x1, 0x01, 0x12]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.hexGrouping, .threshold(8))
    }

    func testInferNoHexGrouping() {
        let input = "[0x11234523, 0x112345, 0x1, 0x01, 0x21]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.hexGrouping, .none)
    }

    func testInferIgnoreHexGrouping() {
        let input = "[0x11_2345_23, 0x10F0_0, 0x1, 0x01, 0x11]"
        let options = inferOptions(from: tokenize(input))
        XCTAssertEqual(options.hexGrouping, .ignore)
    }
}