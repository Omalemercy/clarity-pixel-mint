;; Define NFT token
(define-non-fungible-token pixel-art uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-token (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-dimensions (err u103))
(define-constant err-empty-pixels (err u104))

;; Events
(define-data-var last-token-event uint u0)

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
;; @param name: The name of the pixel art (max 64 chars)
;; @param art-data: Tuple containing width, height, and pixel data
;; @param recipient: Principal to receive the NFT
(define-public (mint-pixel-art (name (string-ascii 64)) (art-data {width: uint, height: uint, pixels: (string-ascii 2048)}) (recipient principal))
  (let 
    (
      (token-id (+ (var-get token-id-nonce) u1))
      (width (get width art-data))
      (height (get height art-data))
      (pixels (get pixels art-data))
    )
    
    ;; Validate inputs
    (asserts! (and (<= width u32) (<= height u32)) err-invalid-dimensions)
    (asserts! (> (len pixels) u0) err-empty-pixels)
    
    ;; Mint token and store metadata
    (try! (nft-mint? pixel-art token-id recipient))
    (map-set token-metadata token-id
      {
        name: name,
        width: width,
        height: height,
        pixels: pixels,
        creator: tx-sender,
        created-at: block-height
      }
    )
    (var-set token-id-nonce token-id)
    (var-set last-token-event token-id)
    (ok token-id)
  )
)

;; Transfer NFT
;; @param token-id: ID of token to transfer
;; @param sender: Current owner
;; @param recipient: New owner
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (asserts! (is-some (nft-get-owner? pixel-art token-id)) err-invalid-token)
    (try! (nft-transfer? pixel-art token-id sender recipient))
    (var-set last-token-event token-id)
    (ok true)
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

(define-read-only (get-last-token-event)
  (ok (var-get last-token-event))
)
