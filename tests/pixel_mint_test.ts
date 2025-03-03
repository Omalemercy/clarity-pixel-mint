import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test minting pixel art NFT - success case",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pixel-mint', 'mint-pixel-art', [
        types.ascii("Test Art"),
        types.tuple({
          width: types.uint(32),
          height: types.uint(32),
          pixels: types.ascii("FF00FF")
        }),
        types.principal(wallet1.address)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Verify metadata
    let response = chain.callReadOnlyFn(
      'pixel-mint', 
      'get-token-metadata',
      [types.uint(1)],
      deployer.address
    );
    
    const metadata = response.result.expectOk().expectSome();
    assertEquals(metadata.name, "Test Art");
    assertEquals(metadata.width, 32);
    assertEquals(metadata.height, 32);
  }
});

Clarinet.test({
  name: "Test minting pixel art NFT - invalid dimensions",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('pixel-mint', 'mint-pixel-art', [
        types.ascii("Test Art"),
        types.tuple({
          width: types.uint(33),
          height: types.uint(32),
          pixels: types.ascii("FF00FF")
        }),
        types.principal(wallet1.address)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectErr(103);
  }
});

Clarinet.test({
  name: "Test NFT transfer",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // First mint an NFT
    let block = chain.mineBlock([
      Tx.contractCall('pixel-mint', 'mint-pixel-art', [
        types.ascii("Test Art"),
        types.tuple({
          width: types.uint(32),
          height: types.uint(32),
          pixels: types.ascii("FF00FF")
        }),
        types.principal(wallet1.address)
      ], deployer.address)
    ]);
    
    // Then transfer it
    block = chain.mineBlock([
      Tx.contractCall('pixel-mint', 'transfer', [
        types.uint(1),
        types.principal(wallet1.address),
        types.principal(wallet2.address)
      ], wallet1.address)
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify new owner
    let response = chain.callReadOnlyFn(
      'pixel-mint',
      'get-token-owner',
      [types.uint(1)],
      deployer.address
    );
    
    response.result.expectOk().expectSome().assertEquals(wallet2.address);
  }
});
