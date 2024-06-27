SELECT
      fct_calls.*
    , date_diff('day',fct_calls.requested_datetime, fct_calls.closed_datetime) as days_to_resolve
FROM
    {{ref("fct_calls")}} fct_calls
WHERE
    STATUS = 'Closed'