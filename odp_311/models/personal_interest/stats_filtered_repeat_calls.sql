SELECT
    *
FROM
    {{ref('stat_repeats')}} stat_repeats
WHERE
    1=1
    AND stat_repeats.service_name in ('Homeless Encampment Request')
    AND date_diff('weeks',stat_repeats.first_call,current_date) <= 2
    