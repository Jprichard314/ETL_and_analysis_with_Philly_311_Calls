SELECT
      fct_calls.*
    , date_diff('day',fct_calls.requested_datetime, current_date) as days_open
FROM
    {{ref("fct_calls")}} fct_calls
WHERE
    STATUS = 'Open'