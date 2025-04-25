import Text "mo:base/Text";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Prim "mo:⛔";

module {

  public func substring(text : Text, start : Nat, end : Nat) : Text {
    let chars = Text.toArray(text);
    assert (start <= end);
    assert (end <= chars.size());
    if (start == end) return "";
    Text.fromIter(Array.slice<Char>(chars, start, end));
  };
  public func hexToNat(hexString : Text) : Nat {
    let hex = if (Text.startsWith(hexString, #text "0x")) {
      substring(hexString, 2, Text.size(hexString));
    } else {
      hexString;
    };

    var result : Nat = 0;
    for (c in Text.toIter(Text.map(hex, Prim.charToLower))) {
      let digit = switch c {
        case '0' { 0 };
        case '1' { 1 };
        case '2' { 2 };
        case '3' { 3 };
        case '4' { 4 };
        case '5' { 5 };
        case '6' { 6 };
        case '7' { 7 };
        case '8' { 8 };
        case '9' { 9 };
        case 'a' { 10 };
        case 'b' { 11 };
        case 'c' { 12 };
        case 'd' { 13 };
        case 'e' { 14 };
        case 'f' { 15 };
        case _ { 0 };
      };
      result := result * 16 + digit;
    };
    result;
  };
  public func weiToEth(weiAmount : Nat) : Text {
    let ethAmount = Float.fromInt(weiAmount) / 1_000_000_000_000_000_000.0;
    return Float.toText(ethAmount);
  };
};
