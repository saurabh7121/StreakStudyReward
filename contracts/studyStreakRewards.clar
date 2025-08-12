;; Study Streak Rewards
;; Reward users for logging consecutive days of study

;; Data: Track user streak and last study day
(define-map streak-data principal
  {
    last-day: uint,
    streak-count: uint
  }
)

;; Data: Track rewards
(define-map rewards principal uint)

;; Constants
(define-constant reward-per-day u10) ;; reward tokens per day
(define-constant err-already-logged (err u100))
(define-constant err-no-reward (err u101))

;; Function 1: Log study day
(define-public (log-study (today uint))
  (let (
        (existing (map-get? streak-data tx-sender))
       )
    (match existing
      data
      (let (
            (last (get last-day data))
            (count (get streak-count data))
           )
        ;; Ensure not logging twice in same day
        (asserts! (not (is-eq today last)) err-already-logged)
        ;; Increment or reset streak
        (if (is-eq today (+ last u1))
            (map-set streak-data tx-sender { last-day: today, streak-count: (+ count u1) })
            (map-set streak-data tx-sender { last-day: today, streak-count: u1 })
        )
        ;; Add rewards
        (map-set rewards tx-sender (+ (default-to u0 (map-get? rewards tx-sender)) reward-per-day))
        (ok true)
      )
      ;; First time logging
      (begin
        (map-set streak-data tx-sender { last-day: today, streak-count: u1 })
        (map-set rewards tx-sender reward-per-day)
        (ok true)
      )
    )
  )
)

;; Function 2: Claim rewards
(define-public (claim-reward)
  (let (
        (amount (default-to u0 (map-get? rewards tx-sender)))
       )
    (asserts! (> amount u0) err-no-reward)
    ;; Reset rewards
    (map-set rewards tx-sender u0)
    ;; In actual deployment, mint tokens or transfer here
    (print { claimed: amount })
    (ok amount)
  )
)
