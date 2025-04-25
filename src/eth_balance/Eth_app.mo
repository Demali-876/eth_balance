import Text "mo:base/Text";
import EvmRpc "canister:evm_rpc";
import Json "mo:json";
import Nat "mo:base/Nat";
import U "Utils";

actor {
  public func getEthBalance(address : Text) : async Text {
    // Use PublicNode for Sepolia
    let service = #EthSepolia(#PublicNode);

    let payload = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"" # address # "\", \"latest\"],\"id\":1}";
    let maxResponseBytes : Nat64 = 1024;
    
    // ~542_028_000 is required for this call
    let result = await (with cycles = 600_000_000) EvmRpc.request(service, payload, maxResponseBytes);

    switch result {
      case (#Ok(response)) {
        switch (Json.parse(response)) {
          case (#err(e)) {
            let errorMsg = switch (e) {
              case (#invalidString(err)) { err };
              case (#invalidNumber(err)) { err };
              case (#invalidKeyword(err)) { err };
              case (#invalidChar(err)) { err };
              case (#invalidValue(err)) { err };
              case (#unexpectedEOF()) { "Unexpected EOF" };
              case (#unexpectedToken(err)) { err };
            };
            "JSON parsing error: " # errorMsg;
          };
          case (#ok(json)) {
            switch (Json.get(json, "result")) {
              case (null) {
                "Could not find 'result' field in response";
              };
              case (? #string(hexValue)) {
                let weiBalance = U.hexToNat(hexValue);

                let ethBalance = U.weiToEth(weiBalance);

                return "Balance: " # ethBalance # " ETH (" # Nat.toText(weiBalance) # " Wei)";
              };
              case (_) {
                return "Result field is not a string";
              };
            };
          };
        };
      };
      case (#Err(error)) {
        return "Error: " # debug_show error;
      };
    };
  };
};
