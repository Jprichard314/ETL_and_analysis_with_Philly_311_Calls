SELECT
    calls.cluster_id,
    calls.address,
    calls.service_name,
    count(*) as calls_in_cluster,
    min(calls.requested_datetime) as first_call,
    max(calls.requested_datetime) as last_call,
    date_diff('hours', min(calls.requested_datetime), max(calls.requested_datetime)) as "cluster_duration"
FROM
    {{ref("fct_repeats")}} as calls
GROUP BY
    calls.cluster_id,
    calls.address,
    calls.service_name
HAVING
    count(*) > 1