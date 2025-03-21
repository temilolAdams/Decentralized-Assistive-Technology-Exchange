;; Device Registration Contract
;; Records details of available assistive technologies

(define-data-var last-device-id uint u0)

(define-map devices
  { device-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    owner: principal,
    available: bool,
    condition: (string-ascii 50),
    category: (string-ascii 50)
  }
)

(define-public (register-device (name (string-ascii 100)) (description (string-ascii 500)) (condition (string-ascii 50)) (category (string-ascii 50)))
  (let
    (
      (new-id (+ (var-get last-device-id) u1))
    )
    (var-set last-device-id new-id)
    (map-set devices
      { device-id: new-id }
      {
        name: name,
        description: description,
        owner: tx-sender,
        available: true,
        condition: condition,
        category: category
      }
    )
    (ok new-id)
  )
)

(define-public (update-availability (device-id uint) (is-available bool))
  (let
    (
      (device (unwrap! (map-get? devices { device-id: device-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get owner device)) (err u403))
    (map-set devices
      { device-id: device-id }
      (merge device { available: is-available })
    )
    (ok true)
  )
)

(define-read-only (get-device (device-id uint))
  (map-get? devices { device-id: device-id })
)

(define-read-only (get-device-count)
  (var-get last-device-id)
)
