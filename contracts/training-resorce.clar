;; Training Resource Contract
;; Provides guidance on device usage

(define-data-var last-resource-id uint u0)

(define-map resources
  { resource-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    device-category: (string-ascii 50),
    creator: principal,
    uri: (string-ascii 255),
    verified: bool
  }
)

(define-map resource-ratings
  { resource-id: uint, user: principal }
  {
    rating: uint,
    comment: (optional (string-ascii 200))
  }
)

(define-public (add-resource
    (title (string-ascii 100))
    (description (string-ascii 500))
    (device-category (string-ascii 50))
    (uri (string-ascii 255)))
  (let
    (
      (new-id (+ (var-get last-resource-id) u1))
    )
    (var-set last-resource-id new-id)
    (map-set resources
      { resource-id: new-id }
      {
        title: title,
        description: description,
        device-category: device-category,
        creator: tx-sender,
        uri: uri,
        verified: false
      }
    )
    (ok new-id)
  )
)

(define-public (verify-resource (resource-id uint))
  (let
    (
      (resource (unwrap! (map-get? resources { resource-id: resource-id }) (err u404)))
    )
    ;; Only contract owner can verify resources
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (map-set resources
      { resource-id: resource-id }
      (merge resource { verified: true })
    )
    (ok true)
  )
)

(define-public (rate-resource (resource-id uint) (rating uint) (comment (optional (string-ascii 200))))
  (begin
    ;; Check if resource exists
    (asserts! (is-some (map-get? resources { resource-id: resource-id })) (err u404))
    ;; Check if rating is between 1 and 5
    (asserts! (and (>= rating u1) (<= rating u5)) (err u400))
    (map-set resource-ratings
      { resource-id: resource-id, user: tx-sender }
      {
        rating: rating,
        comment: comment
      }
    )
    (ok true)
  )
)

(define-read-only (get-resource (resource-id uint))
  (map-get? resources { resource-id: resource-id })
)

(define-read-only (get-resource-rating (resource-id uint) (user principal))
  (map-get? resource-ratings { resource-id: resource-id, user: user })
)

(define-constant contract-owner tx-sender)
