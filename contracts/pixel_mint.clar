;; Define NFT token
(define-non-fungible-token pixel-art uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-token (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-dimensions (err u103))

;; Data structures
(define-map token-metadata uint 
  {
    name: (string-ascii 64),
    width: uint,
    height: uint,
    pixels: (string-ascii 2048),
    creator: principal,
    created-at: uint
  }
)

(define-data-var token-id-nonce uint u0)

;; Mint new pixel art NFT
(define-public (mint-pixel-art (name (string-ascii 64)) (art-data {width: uint, height: uint, pixels: (string-ascii 2048)}) (recipient principal))
  (let 
    (
      (token-id (+ (var-get token-id-nonce) u1))
      (width (get width art-data))
      (height (get height art-data))
    )
    
    ;; Check dimensions
    (asserts! (and (<= width u32) (<= height u32)) err-invalid-dimensions)
    
    ;; Mint token and store metadata
    (try! (nft-mint? pixel-art token-id recipient))
    (map-set token-metadata token-id
      {
        name: name,
        width: width,
        height: height,
        pixels: (get pixels art-data),
        creator: tx-sender,
        created-at: block-height
      }
    )
    (var-set token-id-nonce token-id)
    (ok token-id)
  )
)

;; Transfer NFT
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (nft-transfer? pixel-art token-id sender recipient)
  )
)

;; Read-only functions
(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id))
)

(define-read-only (get-token-owner (token-id uint))
  (ok (nft-get-owner? pixel-art token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get token-id-nonce))
)
