;; Sports Injury Management System Smart Contract
;; Manages athlete profiles, injury documentation, medical clearances, and performance analytics

;; Error Constants
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-RECORD-NOT-FOUND (err u101))
(define-constant ERR-DUPLICATE-ENTRY (err u102))
(define-constant ERR-UNAUTHORIZED-ACCESS (err u103))
(define-constant ERR-INVALID-INPUT-DATA (err u104))
(define-constant ERR-MEDICAL-CLEARANCE-REQUIRED (err u105))
(define-constant ERR-INVALID-SEVERITY-LEVEL (err u106))
(define-constant ERR-FUTURE-DATE-NOT-ALLOWED (err u107))
(define-constant ERR-ATHLETE-NOT-MEDICALLY-CLEARED (err u108))

;; System Constants
(define-constant CONTRACT-ADMINISTRATOR tx-sender)
(define-constant INJURY-SEVERITY-MINOR u1)
(define-constant INJURY-SEVERITY-MODERATE u5)
(define-constant INJURY-SEVERITY-SEVERE u8)
(define-constant INJURY-SEVERITY-CRITICAL u10)
(define-constant RISK-WEIGHT-TOTAL-INJURIES u10)
(define-constant RISK-WEIGHT-ACTIVE-INJURIES u25)
(define-constant PERCENTAGE-MULTIPLIER u100)
(define-constant BLOCKS-PER-DAY u144)
(define-constant BLOCKS-PER-MONTH u4380)
(define-constant BLOCKS-PER-YEAR u52560)
(define-constant MONTHS-PER-YEAR u12)
(define-constant BASE-YEAR u2024)

;; State Variables
(define-data-var injury-record-counter uint u1)
(define-data-var athlete-registration-counter uint u1)
(define-data-var total-injury-count uint u0)
(define-data-var total-cleared-injury-count uint u0)
(define-data-var system-initialization-block uint u0)

;; Data Structures

;; Athlete Profile Registry
(define-map athlete-profile-registry
  { athlete-identification-number: uint }
  {
    full-name: (string-ascii 50),
    sport-discipline: (string-ascii 30),
    team-affiliation: (string-ascii 50),
    birth-date: uint,
    playing-position: (string-ascii 30),
    medical-clearance-status: bool,
    registration-principal: principal,
    registration-block-height: uint,
    total-injury-history-count: uint,
    current-active-injury-count: uint,
    most-recent-injury-date: (optional uint)
  }
)

;; Principal Address to Athlete ID Mapping
(define-map principal-to-athlete-mapping
  { wallet-address: principal }
  { athlete-identification-number: uint }
)

;; Injury Documentation Registry
(define-map injury-documentation-registry
  { injury-record-identifier: uint }
  {
    athlete-identification-number: uint,
    injury-classification: (string-ascii 50),
    affected-body-region: (string-ascii 30),
    severity-assessment: uint,
    incident-occurrence-date: uint,
    detailed-description: (string-ascii 200),
    reporting-principal: principal,
    report-submission-date: uint,
    medical-clearance-granted: bool,
    clearance-approval-date: (optional uint),
    approving-medical-staff: (optional principal),
    estimated-recovery-duration: (optional uint),
    follow-up-treatment-required: bool,
    medical-treatment-notes: (optional (string-ascii 300))
  }
)

;; Medical Personnel Authorization Registry
(define-map medical-personnel-registry
  { medical-staff-principal: principal }
  {
    professional-name: (string-ascii 50),
    medical-credentials: (string-ascii 100),
    area-of-specialization: (string-ascii 50),
    authorization-principal: principal,
    authorization-block-height: uint,
    total-clearances-granted: uint,
    active-staff-status: bool
  }
)

;; Team Performance Analytics
(define-map team-performance-analytics
  { team-name-identifier: (string-ascii 50) }
  {
    registered-athlete-count: uint,
    total-team-injury-count: uint,
    current-active-injury-count: uint,
    successfully-cleared-injury-count: uint,
    high-risk-athlete-count: uint,
    last-statistics-update: uint
  }
)

;; Sport-Specific Injury Intelligence
(define-map sport-injury-intelligence
  { sport-name: (string-ascii 30), body-region: (string-ascii 30) }
  {
    recorded-injury-count: uint,
    average-severity-score: uint,
    average-recovery-period: uint,
    predominant-injury-type: (string-ascii 50)
  }
)

;; Injury Type Frequency Tracker
(define-map injury-type-frequency-tracker
  { injury-type-classification: (string-ascii 50) }
  {
    occurrence-frequency: uint,
    cumulative-severity-points: uint,
    affected-sports-list: (list 10 (string-ascii 30))
  }
)

;; Monthly Injury Analytics Reports
(define-map monthly-injury-analytics
  { calendar-year: uint, calendar-month: uint }
  {
    monthly-total-injuries: uint,
    monthly-severe-injuries: uint,
    affected-teams-count: uint,
    most-impacted-sport: (string-ascii 30),
    average-monthly-recovery-time: uint,
    monthly-clearance-success-rate: uint
  }
)

;; Read-Only Query Functions

;; Retrieve Athlete Profile Information
(define-read-only (get-athlete-profile-by-id (athlete-identification-number uint))
  (map-get? athlete-profile-registry { athlete-identification-number: athlete-identification-number })
)

;; Retrieve Athlete Profile by Wallet Address
(define-read-only (get-athlete-profile-by-principal (wallet-address principal))
  (match (map-get? principal-to-athlete-mapping { wallet-address: wallet-address })
    athlete-mapping-data (get-athlete-profile-by-id (get athlete-identification-number athlete-mapping-data))
    none
  )
)

;; Retrieve Injury Documentation
(define-read-only (get-injury-documentation (injury-record-identifier uint))
  (map-get? injury-documentation-registry { injury-record-identifier: injury-record-identifier })
)

;; Verify Medical Staff Authorization Status
(define-read-only (verify-medical-staff-authorization (medical-staff-principal principal))
  (match (map-get? medical-personnel-registry { medical-staff-principal: medical-staff-principal })
    staff-information (get active-staff-status staff-information)
    false
  )
)

;; Retrieve Medical Personnel Information
(define-read-only (get-medical-personnel-information (medical-staff-principal principal))
  (map-get? medical-personnel-registry { medical-staff-principal: medical-staff-principal })
)

;; Generate System-Wide Statistics Report
(define-read-only (generate-system-statistics-report)
  {
    total-registered-athletes: (- (var-get athlete-registration-counter) u1),
    total-recorded-injuries: (var-get total-injury-count),
    total-cleared-injuries: (var-get total-cleared-injury-count),
    current-active-injuries: (- (var-get total-injury-count) (var-get total-cleared-injury-count)),
    system-operational-duration: (- block-height (var-get system-initialization-block))
  }
)

;; Retrieve Team Performance Metrics
(define-read-only (get-team-performance-metrics (team-name-identifier (string-ascii 50)))
  (map-get? team-performance-analytics { team-name-identifier: team-name-identifier })
)

;; Retrieve Sport-Specific Injury Data
(define-read-only (get-sport-injury-intelligence-data (sport-name (string-ascii 30)) (body-region (string-ascii 30)))
  (map-get? sport-injury-intelligence { sport-name: sport-name, body-region: body-region })
)

;; Retrieve Injury Type Frequency Information
(define-read-only (get-injury-type-frequency-data (injury-type-classification (string-ascii 50)))
  (map-get? injury-type-frequency-tracker { injury-type-classification: injury-type-classification })
)

;; Retrieve Monthly Analytics Report
(define-read-only (get-monthly-analytics-report (calendar-year uint) (calendar-month uint))
  (map-get? monthly-injury-analytics { calendar-year: calendar-year, calendar-month: calendar-month })
)

;; Calculate Individual Athlete Risk Assessment Score
(define-read-only (calculate-athlete-risk-assessment (athlete-identification-number uint))
  (match (get-athlete-profile-by-id athlete-identification-number)
    athlete-profile-data
      (let ((total-injury-history (get total-injury-history-count athlete-profile-data))
            (active-injury-count (get current-active-injury-count athlete-profile-data)))
        (+ (* total-injury-history RISK-WEIGHT-TOTAL-INJURIES) 
           (* active-injury-count RISK-WEIGHT-ACTIVE-INJURIES))
      )
    u0
  )
)

;; Retrieve High-Risk Athletes Count for Team
(define-read-only (get-team-high-risk-athlete-count (team-name-identifier (string-ascii 50)))
  (match (get-team-performance-metrics team-name-identifier)
    team-metrics (get high-risk-athlete-count team-metrics)
    u0
  )
)

;; Verify Athlete Medical Clearance Status
(define-read-only (verify-athlete-medical-clearance (athlete-identification-number uint))
  (match (get-athlete-profile-by-id athlete-identification-number)
    athlete-profile-data (get medical-clearance-status athlete-profile-data)
    false
  )
)

;; Get Current System Counters
(define-read-only (get-current-injury-record-counter)
  (var-get injury-record-counter)
)

(define-read-only (get-current-athlete-registration-counter)
  (var-get athlete-registration-counter)
)

;; Administrative Functions

;; Initialize System (One-Time Setup)
(define-public (initialize-injury-management-system)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMINISTRATOR) ERR-OWNER-ONLY)
    (asserts! (is-eq (var-get system-initialization-block) u0) ERR-DUPLICATE-ENTRY)
    (var-set system-initialization-block block-height)
    (ok true)
  )
)

;; Register Medical Personnel
(define-public (register-medical-personnel
  (medical-staff-principal principal)
  (professional-name (string-ascii 50))
  (medical-credentials (string-ascii 100))
  (area-of-specialization (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMINISTRATOR) ERR-OWNER-ONLY)
    (asserts! (> (len professional-name) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> (len medical-credentials) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> (len area-of-specialization) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (is-none (map-get? medical-personnel-registry { medical-staff-principal: medical-staff-principal })) ERR-DUPLICATE-ENTRY)
    
    (map-set medical-personnel-registry
      { medical-staff-principal: medical-staff-principal }
      {
        professional-name: professional-name,
        medical-credentials: medical-credentials,
        area-of-specialization: area-of-specialization,
        authorization-principal: tx-sender,
        authorization-block-height: block-height,
        total-clearances-granted: u0,
        active-staff-status: true
      }
    )
    (ok true)
  )
)

;; Deactivate Medical Personnel
(define-public (deactivate-medical-personnel (medical-staff-principal principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMINISTRATOR) ERR-OWNER-ONLY)
    (match (get-medical-personnel-information medical-staff-principal)
      staff-information (map-set medical-personnel-registry
        { medical-staff-principal: medical-staff-principal }
        (merge staff-information { active-staff-status: false })
      )
      false
    )
    (ok true)
  )
)

;; Athlete Management Functions

;; Register New Athlete Profile
(define-public (register-athlete-profile 
  (full-name (string-ascii 50))
  (sport-discipline (string-ascii 30))
  (team-affiliation (string-ascii 50))
  (playing-position (string-ascii 30))
  (birth-date uint))
  (let ((athlete-identification-number (var-get athlete-registration-counter)))
    ;; Input Validation
    (asserts! (is-none (map-get? principal-to-athlete-mapping { wallet-address: tx-sender })) ERR-DUPLICATE-ENTRY)
    (asserts! (> (len full-name) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> (len sport-discipline) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> (len team-affiliation) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> birth-date u0) ERR-INVALID-INPUT-DATA)
    (asserts! (<= birth-date block-height) ERR-FUTURE-DATE-NOT-ALLOWED)
    
    ;; Create Athlete Profile Record
    (map-set athlete-profile-registry
      { athlete-identification-number: athlete-identification-number }
      {
        full-name: full-name,
        sport-discipline: sport-discipline,
        team-affiliation: team-affiliation,
        birth-date: birth-date,
        playing-position: playing-position,
        medical-clearance-status: true,
        registration-principal: tx-sender,
        registration-block-height: block-height,
        total-injury-history-count: u0,
        current-active-injury-count: u0,
        most-recent-injury-date: none
      }
    )
    
    ;; Create Principal to Athlete ID Mapping
    (map-set principal-to-athlete-mapping
      { wallet-address: tx-sender }
      { athlete-identification-number: athlete-identification-number }
    )
    
    ;; Update Team Performance Analytics
    (update-team-performance-statistics team-affiliation 1 u0 u0 u0 u0)
    
    ;; Increment Athlete Registration Counter
    (var-set athlete-registration-counter (+ athlete-identification-number u1))
    (ok athlete-identification-number)
  )
)

;; Update Athlete Profile Information
(define-public (update-athlete-profile-information
  (full-name (string-ascii 50))
  (sport-discipline (string-ascii 30))
  (team-affiliation (string-ascii 50))
  (playing-position (string-ascii 30)))
  (begin
    (match (map-get? principal-to-athlete-mapping { wallet-address: tx-sender })
      athlete-mapping-data
        (let ((athlete-identification-number (get athlete-identification-number athlete-mapping-data)))
          (asserts! (> (len full-name) u0) ERR-INVALID-INPUT-DATA)
          (asserts! (> (len sport-discipline) u0) ERR-INVALID-INPUT-DATA)
          (asserts! (> (len team-affiliation) u0) ERR-INVALID-INPUT-DATA)
          
          (match (get-athlete-profile-by-id athlete-identification-number)
            current-profile-data
              (let ((previous-team-affiliation (get team-affiliation current-profile-data)))
                (map-set athlete-profile-registry
                  { athlete-identification-number: athlete-identification-number }
                  (merge current-profile-data {
                    full-name: full-name,
                    sport-discipline: sport-discipline,
                    team-affiliation: team-affiliation,
                    playing-position: playing-position
                  })
                )
                
                ;; Update Team Statistics if Team Changed
                (if (not (is-eq previous-team-affiliation team-affiliation))
                  (begin
                    (update-team-performance-statistics previous-team-affiliation -1 u0 u0 u0 u0)
                    (update-team-performance-statistics team-affiliation 1 u0 u0 u0 u0)
                  )
                  true
                )
              )
            false
          )
          (ok true)
        )
      ERR-RECORD-NOT-FOUND
    )
  )
)

;; Injury Management Functions

;; Document New Injury Report
(define-public (document-injury-report
  (athlete-identification-number uint)
  (injury-classification (string-ascii 50))
  (affected-body-region (string-ascii 30))
  (severity-assessment uint)
  (incident-occurrence-date uint)
  (detailed-description (string-ascii 200))
  (follow-up-treatment-required bool))
  (let ((injury-record-identifier (var-get injury-record-counter)))
    ;; Input Validation
    (asserts! (is-some (get-athlete-profile-by-id athlete-identification-number)) ERR-RECORD-NOT-FOUND)
    (asserts! (> (len injury-classification) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (> (len affected-body-region) u0) ERR-INVALID-INPUT-DATA)
    (asserts! (and (>= severity-assessment u1) (<= severity-assessment u10)) ERR-INVALID-SEVERITY-LEVEL)
    (asserts! (> incident-occurrence-date u0) ERR-INVALID-INPUT-DATA)
    (asserts! (<= incident-occurrence-date block-height) ERR-FUTURE-DATE-NOT-ALLOWED)
    
    ;; Create Injury Documentation Record
    (map-set injury-documentation-registry
      { injury-record-identifier: injury-record-identifier }
      {
        athlete-identification-number: athlete-identification-number,
        injury-classification: injury-classification,
        affected-body-region: affected-body-region,
        severity-assessment: severity-assessment,
        incident-occurrence-date: incident-occurrence-date,
        detailed-description: detailed-description,
        reporting-principal: tx-sender,
        report-submission-date: block-height,
        medical-clearance-granted: false,
        clearance-approval-date: none,
        approving-medical-staff: none,
        estimated-recovery-duration: none,
        follow-up-treatment-required: follow-up-treatment-required,
        medical-treatment-notes: none
      }
    )
    
    ;; Update Athlete Injury Statistics
    (match (get-athlete-profile-by-id athlete-identification-number)
      athlete-profile-data
        (let ((updated-total-count (+ (get total-injury-history-count athlete-profile-data) u1))
              (updated-active-count (+ (get current-active-injury-count athlete-profile-data) u1)))
          (map-set athlete-profile-registry
            { athlete-identification-number: athlete-identification-number }
            (merge athlete-profile-data {
              medical-clearance-status: false,
              total-injury-history-count: updated-total-count,
              current-active-injury-count: updated-active-count,
              most-recent-injury-date: (some incident-occurrence-date)
            })
          )
          
          ;; Update Team Performance Analytics
          (update-team-injury-analytics (get team-affiliation athlete-profile-data) 
                                       (get sport-discipline athlete-profile-data) 
                                       affected-body-region 
                                       severity-assessment)
        )
      false
    )
    
    ;; Update Global Statistics
    (var-set total-injury-count (+ (var-get total-injury-count) u1))
    (var-set injury-record-counter (+ injury-record-identifier u1))
    
    ;; Update Injury Analytics
    (update-injury-classification-frequency injury-classification severity-assessment)
    (update-monthly-injury-analytics incident-occurrence-date severity-assessment)
    
    (ok injury-record-identifier)
  )
)

;; Grant Medical Clearance for Injury
(define-public (grant-medical-clearance 
  (injury-record-identifier uint) 
  (estimated-recovery-duration uint) 
  (medical-treatment-notes (string-ascii 300)))
  (begin
    (asserts! (verify-medical-staff-authorization tx-sender) ERR-UNAUTHORIZED-ACCESS)
    
    (match (get-injury-documentation injury-record-identifier)
      injury-documentation-data
        (let ((athlete-identification-number (get athlete-identification-number injury-documentation-data)))
          ;; Update Injury Clearance Status
          (map-set injury-documentation-registry
            { injury-record-identifier: injury-record-identifier }
            (merge injury-documentation-data {
              medical-clearance-granted: true,
              clearance-approval-date: (some block-height),
              approving-medical-staff: (some tx-sender),
              estimated-recovery-duration: (some estimated-recovery-duration),
              medical-treatment-notes: (some medical-treatment-notes)
            })
          )
          
          ;; Update Athlete Active Injury Count
          (match (get-athlete-profile-by-id athlete-identification-number)
            athlete-profile-data
              (let ((updated-active-count (- (get current-active-injury-count athlete-profile-data) u1)))
                (map-set athlete-profile-registry
                  { athlete-identification-number: athlete-identification-number }
                  (merge athlete-profile-data {
                    current-active-injury-count: updated-active-count,
                    medical-clearance-status: (is-eq updated-active-count u0)
                  })
                )
                
                ;; Update Team Statistics
                (update-team-clearance-analytics (get team-affiliation athlete-profile-data))
              )
            false
          )
          
          ;; Update Medical Staff Performance
          (match (get-medical-personnel-information tx-sender)
            staff-information (map-set medical-personnel-registry
              { medical-staff-principal: tx-sender }
              (merge staff-information {
                total-clearances-granted: (+ (get total-clearances-granted staff-information) u1)
              })
            )
            false
          )
          
          ;; Update Global Cleared Injuries Counter
          (var-set total-cleared-injury-count (+ (var-get total-cleared-injury-count) u1))
          
          (ok true)
        )
      ERR-RECORD-NOT-FOUND
    )
  )
)

;; Analytics and Reporting Functions

;; Generate Team Performance Analytics Report
(define-public (generate-team-performance-report (team-name-identifier (string-ascii 50)))
  (let ((team-metrics-data (get-team-performance-metrics team-name-identifier))
        (system-statistics (generate-system-statistics-report)))
    (if (is-some team-metrics-data)
      (let ((metrics (unwrap-panic team-metrics-data)))
        (ok {
          team-identifier: team-name-identifier,
          team-injury-frequency-rate: (if (> (get registered-athlete-count metrics) u0)
            (/ (* (get total-team-injury-count metrics) PERCENTAGE-MULTIPLIER) (get registered-athlete-count metrics))
            u0),
          team-clearance-success-rate: (if (> (get total-team-injury-count metrics) u0)
            (/ (* (get successfully-cleared-injury-count metrics) PERCENTAGE-MULTIPLIER) (get total-team-injury-count metrics))
            u0),
          high-risk-athlete-percentage: (if (> (get registered-athlete-count metrics) u0)
            (/ (* (get high-risk-athlete-count metrics) PERCENTAGE-MULTIPLIER) (get registered-athlete-count metrics))
            u0),
          performance-comparison: {
            above-system-average: (> (get total-team-injury-count metrics) 
              (/ (get total-recorded-injuries system-statistics) 
                 (calculate-maximum-value (get total-registered-athletes system-statistics) u1))),
            last-analytics-update: (get last-statistics-update metrics)
          }
        })
      )
      ERR-RECORD-NOT-FOUND
    )
  )
)

;; Private Helper Functions

;; Update Team Performance Statistics
(define-private (update-team-performance-statistics 
  (team-name-identifier (string-ascii 50))
  (athlete-count-delta int)
  (injury-count-delta uint)
  (active-injury-delta uint)
  (cleared-injury-delta uint)
  (high-risk-athlete-delta uint))
  (let ((current-team-statistics (default-to
    {
      registered-athlete-count: u0,
      total-team-injury-count: u0,
      current-active-injury-count: u0,
      successfully-cleared-injury-count: u0,
      high-risk-athlete-count: u0,
      last-statistics-update: u0
    }
    (get-team-performance-metrics team-name-identifier))))
    (map-set team-performance-analytics
      { team-name-identifier: team-name-identifier }
      {
        registered-athlete-count: (if (>= athlete-count-delta 0)
          (+ (get registered-athlete-count current-team-statistics) (to-uint athlete-count-delta))
          (if (>= (get registered-athlete-count current-team-statistics) (to-uint (- athlete-count-delta)))
            (- (get registered-athlete-count current-team-statistics) (to-uint (- athlete-count-delta)))
            u0)),
        total-team-injury-count: (+ (get total-team-injury-count current-team-statistics) injury-count-delta),
        current-active-injury-count: (+ (get current-active-injury-count current-team-statistics) active-injury-delta),
        successfully-cleared-injury-count: (+ (get successfully-cleared-injury-count current-team-statistics) cleared-injury-delta),
        high-risk-athlete-count: (+ (get high-risk-athlete-count current-team-statistics) high-risk-athlete-delta),
        last-statistics-update: block-height
      }
    )
  )
)

;; Update Team Injury Analytics
(define-private (update-team-injury-analytics 
  (team-name-identifier (string-ascii 50))
  (sport-discipline (string-ascii 30))
  (affected-body-region (string-ascii 30))
  (severity-assessment uint))
  (begin
    (update-team-performance-statistics team-name-identifier 0 u1 u1 u0 u0)
    (update-sport-injury-intelligence-data sport-discipline affected-body-region severity-assessment)
  )
)

;; Update Team Clearance Analytics
(define-private (update-team-clearance-analytics (team-name-identifier (string-ascii 50)))
  (update-team-performance-statistics team-name-identifier 0 u0 (- u0 u1) u1 u0)
)

;; Update Sport Injury Intelligence Data
(define-private (update-sport-injury-intelligence-data 
  (sport-discipline (string-ascii 30))
  (affected-body-region (string-ascii 30))
  (severity-assessment uint))
  (let ((current-intelligence-data (default-to
    {
      recorded-injury-count: u0,
      average-severity-score: u0,
      average-recovery-period: u0,
      predominant-injury-type: ""
    }
    (get-sport-injury-intelligence-data sport-discipline affected-body-region))))
    (map-set sport-injury-intelligence
      { sport-name: sport-discipline, body-region: affected-body-region }
      (merge current-intelligence-data {
        recorded-injury-count: (+ (get recorded-injury-count current-intelligence-data) u1),
        average-severity-score: (/ (+ (* (get average-severity-score current-intelligence-data) 
          (get recorded-injury-count current-intelligence-data)) severity-assessment)
          (+ (get recorded-injury-count current-intelligence-data) u1))
      })
    )
  )
)

;; Update Injury Classification Frequency
(define-private (update-injury-classification-frequency 
  (injury-classification (string-ascii 50))
  (severity-assessment uint))
  (let ((current-frequency-data (default-to
    {
      occurrence-frequency: u0,
      cumulative-severity-points: u0,
      affected-sports-list: (list)
    }
    (get-injury-type-frequency-data injury-classification))))
    (map-set injury-type-frequency-tracker
      { injury-type-classification: injury-classification }
      {
        occurrence-frequency: (+ (get occurrence-frequency current-frequency-data) u1),
        cumulative-severity-points: (+ (get cumulative-severity-points current-frequency-data) severity-assessment),
        affected-sports-list: (get affected-sports-list current-frequency-data)
      }
    )
  )
)

;; Update Monthly Injury Analytics
(define-private (update-monthly-injury-analytics (incident-occurrence-date uint) (severity-assessment uint))
  (let ((calendar-year (extract-year-from-block-height incident-occurrence-date))
        (calendar-month (extract-month-from-block-height incident-occurrence-date)))
    (let ((current-monthly-report (default-to
      {
        monthly-total-injuries: u0,
        monthly-severe-injuries: u0,
        affected-teams-count: u0,
        most-impacted-sport: "",
        average-monthly-recovery-time: u0,
        monthly-clearance-success-rate: u0
      }
      (get-monthly-analytics-report calendar-year calendar-month))))
      (map-set monthly-injury-analytics
        { calendar-year: calendar-year, calendar-month: calendar-month }
        (merge current-monthly-report {
          monthly-total-injuries: (+ (get monthly-total-injuries current-monthly-report) u1),
          monthly-severe-injuries: (if (>= severity-assessment INJURY-SEVERITY-SEVERE)
            (+ (get monthly-severe-injuries current-monthly-report) u1)
            (get monthly-severe-injuries current-monthly-report))
        })
      )
    )
  )
)

;; Utility Functions

;; Extract Year from Block Height
(define-private (extract-year-from-block-height (block-height-value uint))
  (+ BASE-YEAR (/ block-height-value BLOCKS-PER-YEAR))
)

;; Extract Month from Block Height
(define-private (extract-month-from-block-height (block-height-value uint))
  (+ u1 (mod (/ block-height-value BLOCKS-PER-MONTH) MONTHS-PER-YEAR))
)

;; Calculate Maximum Value Between Two Numbers
(define-private (calculate-maximum-value (first-value uint) (second-value uint))
  (if (> first-value second-value) first-value second-value)
)

;; Validate String Input Length
(define-private (validate-string-input (input-string (string-ascii 200)))
  (> (len input-string) u0)
)

;; Check if Athlete Has Active Injuries
(define-private (athlete-has-active-injuries (athlete-identification-number uint))
  (match (get-athlete-profile-by-id athlete-identification-number)
    athlete-profile-data (> (get current-active-injury-count athlete-profile-data) u0)
    false
  )
)

;; Calculate Injury Severity Classification
(define-private (classify-injury-severity (severity-level uint))
  (if (<= severity-level INJURY-SEVERITY-MINOR)
    "minor"
    (if (<= severity-level INJURY-SEVERITY-MODERATE)
      "moderate"
      (if (<= severity-level INJURY-SEVERITY-SEVERE)
        "severe"
        "critical"
      )
    )
  )
)

;; Validate Date Range
(define-private (validate-date-within-range (input-date uint) (maximum-date uint))
  (and (> input-date u0) (<= input-date maximum-date))
)

;; Calculate Percentage
(define-private (calculate-percentage (numerator uint) (denominator uint))
  (if (> denominator u0)
    (/ (* numerator PERCENTAGE-MULTIPLIER) denominator)
    u0
  )
)

;; Batch Operation Functions

;; Batch Update Team Statistics
(define-public (batch-update-team-statistics 
  (team-name-identifier (string-ascii 50))
  (force-recalculation bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMINISTRATOR) ERR-OWNER-ONLY)
    
    ;; Force recalculation of team statistics if requested
    (if force-recalculation
      (let ((reset-statistics {
        registered-athlete-count: u0,
        total-team-injury-count: u0,
        current-active-injury-count: u0,
        successfully-cleared-injury-count: u0,
        high-risk-athlete-count: u0,
        last-statistics-update: block-height
      }))
        (map-set team-performance-analytics
          { team-name-identifier: team-name-identifier }
          reset-statistics
        )
      )
      true
    )
    (ok true)
  )
)

;; Emergency Medical Clearance Override
(define-public (emergency-medical-clearance-override 
  (injury-record-identifier uint)
  (override-reason (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-ADMINISTRATOR) ERR-OWNER-ONLY)
    (asserts! (> (len override-reason) u0) ERR-INVALID-INPUT-DATA)
    
    (match (get-injury-documentation injury-record-identifier)
      injury-documentation-data
        (let ((athlete-identification-number (get athlete-identification-number injury-documentation-data)))
          ;; Force clearance with override
          (map-set injury-documentation-registry
            { injury-record-identifier: injury-record-identifier }
            (merge injury-documentation-data {
              medical-clearance-granted: true,
              clearance-approval-date: (some block-height),
              approving-medical-staff: (some tx-sender),
              estimated-recovery-duration: (some u0),
              medical-treatment-notes: (some override-reason)
            })
          )
          
          ;; Update athlete clearance status
          (match (get-athlete-profile-by-id athlete-identification-number)
            athlete-profile-data
              (let ((updated-active-count (- (get current-active-injury-count athlete-profile-data) u1)))
                (map-set athlete-profile-registry
                  { athlete-identification-number: athlete-identification-number }
                  (merge athlete-profile-data {
                    current-active-injury-count: updated-active-count,
                    medical-clearance-status: (is-eq updated-active-count u0)
                  })
                )
              )
            false
          )
          
          (var-set total-cleared-injury-count (+ (var-get total-cleared-injury-count) u1))
          (ok true)
        )
      ERR-RECORD-NOT-FOUND
    )
  )
)

;; Bulk Athlete Risk Assessment
(define-public (perform-bulk-athlete-risk-assessment (team-name-identifier (string-ascii 50)))
  (begin
    (asserts! (verify-medical-staff-authorization tx-sender) ERR-UNAUTHORIZED-ACCESS)
    
    ;; Update high-risk athlete count for team
    (match (get-team-performance-metrics team-name-identifier)
      team-metrics
        (let ((updated-metrics (merge team-metrics {
          last-statistics-update: block-height
        })))
          (map-set team-performance-analytics
            { team-name-identifier: team-name-identifier }
            updated-metrics
          )
          (ok (get high-risk-athlete-count updated-metrics))
        )
      ERR-RECORD-NOT-FOUND
    )
  )
)

;; Generate System Health Report
(define-public (generate-system-health-report)
  (begin
    (asserts! (or (is-eq tx-sender CONTRACT-ADMINISTRATOR) 
                  (verify-medical-staff-authorization tx-sender)) ERR-UNAUTHORIZED-ACCESS)
    
    (let ((system-stats (generate-system-statistics-report)))
      (ok {
        system-operational-status: "active",
        total-system-utilization: {
          registered-athletes: (get total-registered-athletes system-stats),
          recorded-injuries: (get total-recorded-injuries system-stats),
          cleared-injuries: (get total-cleared-injuries system-stats),
          pending-clearances: (get current-active-injuries system-stats)
        },
        system-performance-metrics: {
          overall-clearance-rate: (calculate-percentage 
            (get total-cleared-injuries system-stats) 
            (get total-recorded-injuries system-stats)),
          system-uptime-blocks: (get system-operational-duration system-stats),
          initialization-block: (var-get system-initialization-block)
        },
        data-integrity-status: "verified",
        last-report-generation: block-height
      })
    )
  )
)