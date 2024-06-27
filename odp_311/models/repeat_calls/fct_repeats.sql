WITH repeat_calls_data AS (

  SELECT
        rc.cartodb_id
      , rc.address
      , rc.service_name
      , rc.requested_datetime
      , CASE
          WHEN address is not null then LAG(rc.requested_datetime) OVER( PARTITION BY rc.address, rc.service_name ORDER BY rc.requested_datetime) 
          ELSE NULL END as last_request
      , CASE
          WHEN address is not null then date_diff('hours',(LAG(rc.requested_datetime) OVER( PARTITION BY rc.address, rc.service_name ORDER BY rc.requested_datetime)),rc.requested_datetime)
          ELSE NULL END as time_since_last_request
  FROM
      {{ref("fct_calls")}} rc
  WHERE
    address not NULL AND
    (
        address NOT IN ('1400 JOHN F KENNEDY BLVD','.') AND
        service_name NOT IN ('Information Request','LI Escalation')
    )
  ORDER BY rc.requested_datetime DESC

)

SELECT
    repeat_calls_data.*
  , repeat_calls_data.address || '-' || repeat_calls_data.service_name || '-' ||
    SUM(
        CASE
          WHEN repeat_calls_data.time_since_last_request is NULL THEN NULL
          WHEN repeat_calls_data.time_since_last_request > 72 THEN 1
          ELSE 0 END
    ) OVER ( 
              PARTITION BY repeat_calls_data.address, 
                          repeat_calls_data.service_name 
              ORDER BY requested_datetime
            ) as "cluster_id"


FROM
  repeat_calls_data