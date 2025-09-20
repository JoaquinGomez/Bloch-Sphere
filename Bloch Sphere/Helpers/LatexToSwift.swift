import Foundation

// MARK: - Public API

/// Converts a Swift-like math expression into LaTeX.
/// Examples of accepted input:
///  - "1.0 / sqrt(2.0)"
///  - "pow(sin(x)+cos(x), 2) / (1 + x)"
///  - "sqrt(1 - cos(x))"
func swiftToLaTeX(_ input: String) throws -> String {
    var parser = Parser(tokens: Lexer(input).lex())
    let ast = try parser.parse()
    return LatexPrinter().print(ast)
}

// MARK: - Lexer

private enum Tok: Equatable {
    case number(String)
    case ident(String)
    case lparen, rparen, comma
    case plus, minus, star, slash
    case eof
}

private final class Lexer {
    private let scalars: [UnicodeScalar]
    private var i = 0
    init(_ s: String) { self.scalars = Array(s.unicodeScalars) }

    func lex() -> [Tok] {
        var out: [Tok] = []
        while let c = peek() {
            if CharacterSet.whitespacesAndNewlines.contains(c) { _ = advance(); continue }
            switch c {
            case "(": out.append(.lparen); _ = advance()
            case ")": out.append(.rparen); _ = advance()
            case ",": out.append(.comma);  _ = advance()
            case "+": out.append(.plus);   _ = advance()
            case "-": out.append(.minus);  _ = advance()
            case "*": out.append(.star);   _ = advance()
            case "/": out.append(.slash);  _ = advance()
            default:
                if CharacterSet.decimalDigits.contains(c) || c == "." {
                    out.append(.number(readWhile { CharacterSet.decimalDigits.contains($0) || $0 == "." }))
                } else if CharacterSet.letters.contains(c) || c == "_" {
                    out.append(.ident(readWhile { CharacterSet.letters.contains($0) || CharacterSet.decimalDigits.contains($0) || $0 == "_" || $0 == "." }))
                } else {
                    _ = advance() // skip unknown
                }
            }
        }
        out.append(.eof)
        return out
    }

    private func peek() -> UnicodeScalar? {
        return i < scalars.count ? scalars[i] : nil
    }

    @discardableResult
    private func advance() -> UnicodeScalar? {
        guard i < scalars.count else { return nil }
        let c = scalars[i]
        i += 1
        return c
    }
    private func readWhile(_ ok: (UnicodeScalar)->Bool) -> String {
        var s = ""
        while let c = peek(), ok(c) {
            s.unicodeScalars.append(c)
            _ = advance()
        }
        return s
    }
}

// MARK: - AST

private indirect enum Expr {
    case num(String)
    case ident(String)
    case unaryMinus(Expr)
    case add(Expr, Expr)
    case sub(Expr, Expr)
    case mul(Expr, Expr)
    case div(Expr, Expr)
    case pow(Expr, Expr)
    case func1(name: String, arg: Expr)
}

// MARK: - Parser (recursive descent)

private struct Parser {
    private var tokens: [Tok]
    private var pos = 0
    init(tokens: [Tok]) { self.tokens = tokens }

    mutating func parse() throws -> Expr {
        let e = try parseSum()
        try expect(.eof)
        return e
    }

    // sum := prod (('+'|'-') prod)*
    private mutating func parseSum() throws -> Expr {
        var lhs = try parseProd()
        while match(.plus) || match(.minus) {
            let op = prev()
            let rhs = try parseProd()
            lhs = (op == .plus) ? .add(lhs, rhs) : .sub(lhs, rhs)
        }
        return lhs
    }

    // prod := power (('*'|'/') power)*
    private mutating func parseProd() throws -> Expr {
        var lhs = try parsePower()
        while match(.star) || match(.slash) {
            let op = prev()
            let rhs = try parsePower()
            lhs = (op == .star) ? .mul(lhs, rhs) : .div(lhs, rhs)
        }
        return lhs
    }

    // power := unary (powCall | '^' unary)?
    // Accept both pow(a,b) and a ^ b (Swift uses pow(...))
    private mutating func parsePower() throws -> Expr {
        var base = try parseUnary()
        // Handle explicit caret syntax if present (optional)
        if match(.ident("pow")) && match(.lparen) {
            let a = try parseSum()
            try expect(.comma)
            let b = try parseSum()
            try expect(.rparen)
            return .pow(a, b)
        }
        // We also allow chained ^ via explicit '^' tokens if someone injected them
        while match(.ident("^")) { // tolerate ident("^") from previous tools
            let exp = try parseUnary()
            base = .pow(base, exp)
        }
        return base
    }

    // unary := '-' unary | primary
    private mutating func parseUnary() throws -> Expr {
        if match(.minus) { return .unaryMinus(try parseUnary()) }
        return try parsePrimary()
    }

    // primary := number | ident | func | '(' sum ')'
    private mutating func parsePrimary() throws -> Expr {
        if matchNumber() { if case .number(let s) = prev() { return .num(s) } }
        if matchIdent()  {
            if case .ident(let name) = prev() {
                // function call?
                if match(.lparen) {
                    let arg = try parseSum()
                    try expect(.rparen)
                    // map special cases (Double.pi, exp(1.0))
                    if name == "pow" {
                        // already handled in parsePower, but keep fallback
                        if case .add = arg { } // noop
                    }
                    return .func1(name: name, arg: arg)
                } else {
                    return .ident(name)
                }
            }
        }
        if match(.lparen) {
            let e = try parseSum()
            try expect(.rparen)
            return e
        }
        throw err("Unexpected token \(peek())")
    }

    // token utils
    private func peek() -> Tok { tokens[pos] }
    @discardableResult private mutating func advance() -> Tok { defer { pos += 1 }; return tokens[pos] }
    private func check(_ t: Tok) -> Bool { peek() == t }

    @discardableResult private mutating func match(_ t: Tok) -> Bool {
        if check(t) { _ = advance(); return true }
        return false
    }
    @discardableResult private mutating func matchNumber() -> Bool { if case .number = peek() { _ = advance(); return true } ; return false }
    @discardableResult private mutating func matchIdent() -> Bool { if case .ident = peek()  { _ = advance(); return true } ; return false }

    private mutating func expect(_ t: Tok) throws {
        if !match(t) { throw err("Expected \(t), got \(peek())") }
    }
    private func prev() -> Tok { tokens[pos-1] }
    private func err(_ m: String) -> NSError { NSError(domain: "SwiftToLaTeX", code: 1, userInfo: [NSLocalizedDescriptionKey: m]) }
}

private func ==(lhs: Tok, rhs: Tok) -> Bool {
    switch (lhs, rhs) {
    case (.lparen, .lparen), (.rparen, .rparen), (.comma, .comma),
         (.plus, .plus), (.minus, .minus), (.star, .star), (.slash, .slash),
         (.eof, .eof): return true
    case (.number, .number): return false
    case (.ident(let a), .ident(let b)): return a == b
    default: return false
    }
}

// MARK: - LaTeX Printer

private final class LatexPrinter {
    func print(_ e: Expr) -> String { render(e, parent: nil) }

    private enum Ctx { case sum, prod, pow, unary, atom }

    private func render(_ e: Expr, parent: Ctx?) -> String {
        switch e {
        case .num(let s):
            // Strip trailing ".0" for prettier output
            return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
        case .ident(let s):
            return mapIdent(s)
        case .unaryMinus(let x):
            let inner = render(x, parent: .unary)
            return "-" + wrapIfNeeded(inner, needParens: needsParensForUnary(x))
        case .add(let a, let b):
            let L = render(a, parent: .sum)
            let R = render(b, parent: .sum)
            return wrapIfNeeded("\(L) + \(R)", needParens: parent == .prod || parent == .pow || parent == .unary)
        case .sub(let a, let b):
            let L = render(a, parent: .sum)
            let R = render(b, parent: .sum)
            return wrapIfNeeded("\(L) - \(R)", needParens: parent == .prod || parent == .pow || parent == .unary)
        case .mul(let a, let b):
            // Omit explicit \cdot if left or right is fraction/root/power needing grouping
            let L = render(a, parent: .prod)
            let R = render(b, parent: .prod)
            return wrapIfNeeded("\(L) \\cdot \(R)", needParens: parent == .pow)
        case .div(let a, let b):
            let num = render(a, parent: .atom)
            let den = render(b, parent: .atom)
            return "\\frac{\(brace(num))}{\(brace(den))}"
        case .pow(let a, let b):
            let base = render(a, parent: .powBase)
            let exp  = render(b, parent: .pow)
            return "\(base)^{\(brace(exp))}"
        case .func1(let name, let arg):
            return renderFunc(name: name, arg: arg)
        }
    }

    // helper to distinguish base context
    private enum CtxBase { case powBase }

    private func render(_ e: Expr, parent: CtxBase) -> String {
        switch e {
        case .num, .ident, .func1:
            return render(e, parent: .atom)
        default:
            // base of power usually needs parentheses
            return "{\(render(e, parent: .atom))}"
        }
    }

    private func mapIdent(_ s: String) -> String {
        if s == "Double.pi" || s == "Float.pi" || s == "CGFloat.pi" || s == "pi" { return "\\pi" }
        if s == "e" || s == "exp1" { return "e" }
        return s.replacingOccurrences(of: "_", with: "\\_")
    }

    private func renderFunc(name: String, arg: Expr) -> String {
        // exp(1) → e, exp(x) → e^{x}; sqrt(x) → \sqrt{...}; log/ln(x) → \ln{x}
        let a = render(arg, parent: .atom)
        switch name {
        case "sqrt":
            return "\\sqrt{\(brace(a))}"
        case "sin", "cos", "tan":
            return "\\\(name){\(brace(a))}"
        case "log", "ln":
            return "\\ln{\(brace(a))}"
        case "exp":
            // Try to detect exp(1) for 'e'
            if case .num(let n) = arg, n == "1" || n == "1.0" { return "e" }
            return "e^{\(brace(a))}"
        default:
            // Unknown ident treated as function name
            let safe = name.replacingOccurrences(of: "_", with: "\\_")
            return "\\mathrm{\(safe)}\\left(\(a)\\right)"
        }
    }

    private func wrapIfNeeded(_ s: String, needParens: Bool) -> String {
        needParens ? "\\left(\(s)\\right)" : s
    }

    private func needsParensForUnary(_ e: Expr) -> Bool {
        switch e {
        case .num, .ident, .func1: return false
        default: return true
        }
    }

    private func brace(_ s: String) -> String { s } // adjust if you want always { ... }
}
