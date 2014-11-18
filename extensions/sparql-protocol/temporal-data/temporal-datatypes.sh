#! /bin/bash

# exercise the temporal constructors
# see also the xpath specifications' sections on casting:
#  http://www.w3.org/TR/xpath-functions/#casting
#  http://www.w3.org/TR/xpath-functions-30/#casting
#  http://www.w3.org/TR/xpath-functions-30/#dates-times

# xs:date
# xs:gDay
# xs:dateTime
# xs:dayTimeDuration
# xs:duration
# xs:gMonthDay
# xs:gMonth
# xs:time
# xs:gYearMonth
# xs:yearMonthDuration
# xs:gYear

curl -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | jq '.results.bindings[] | fgrep -v null | wc -l | fgrep -q '14'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (NOW() as ?NOW)
       (now() as ?now)
       # date
       (xsd:string(?date) as ?dateString)
       (xsd:date(?date) as ?dateDate)
       (xsd:date(?dateTime) as ?dateTimeDate)
       (YEAR(?date) as ?dateYear)
       (MONTH(?date) as ?dateMonth)
       (DAY(?date) as ?dateDay)
       (TIMEZONE(?date) as ?dateTimezone)  # supported as for dateTime
       (TZ(?date) as ?dateTZ)

       # dateTime
       (xsd:string(?dateTime) as ?dateTimeString)
       (xsd:dateTime(?dateTime) as ?dateTimeDateTime)
       (xsd:dateTime(?date) as ?dateDateTime)
       (YEAR(?dateTime) as ?dateTimeYear)
       (MONTH(?dateTime) as ?dateTimeMonth)
       (DAY(?dateTime) as ?dateTimeDay)
       (HOURS(?dateTime) as ?dateTimeHours)
       (MINUTES(?dateTime) as ?dateTimeMinutes)
       (SECONDS(?dateTime) as ?dateTimeSeconds)
       (TIMEZONE(?dateTime) as ?dateTimeTimezone)
       (TZ(?dateTime) as ?dateTimeTZ)
       
       # time
       (xsd:string(?time) as ?timeString)
       (xsd:time(?time) as ?timeTime)  # time casts are limited
       (HOURS(?time) as ?timeHours)
       (MINUTES(?time) as ?timeMinutes)
       (SECONDS(?time) as ?timeSeconds)
       (TIMEZONE(?time) as ?timeTimezone)
       (TZ(?time) as ?timeTZ)

       # extensions
       # day-time-duration
       (xsd:string(?dayTimeDuration) as ?dtdString)
       (xsd:dayTimeDuration(?dayTimeDuration) as ?dtdDayTimeDuration)
       # g-day
       (xsd:string(?gDay) as ?gdString)
       (xsd:gDay(?gDay) as ?gdGDay)
       (xsd:gDay(?dayTime) as ?dtGDay)
       # g-month
       (xsd:string(?gMonth) as ?gmString)
       (xsd:gMonth(?gMonth) as ?gmGMonth)
       (xsd:gMonth(?dayTime) as ?dtGMonth)
       # g-month-day
       (xsd:string(?gMonthDay) as ?gmdString)
       (xsd:gMonthDay(?gMonthDay) as ?gmdGMonthDay)
       (xsd:gMonthDay(?dayTime) as ?dtGMonthDay)
       # g-year
       (xsd:string(?gYear) as ?gyString)
       (xsd:gYear(?gYear) as ?gyGYear)
       (xsd:gYear(?dayTime) as ?dtGYear)
       # g-year-month
       (xsd:string(?gYearMonth) as ?gymString)
       (xsd:gYearMonth(?gYearMonth) as ?gymGYearMonth)
       (xsd:gYearMonth(?dayTime) as ?dtGYearMonth)
       # year-month-duration
       (xsd:string(?yearMonthDuration) as ?ymdString)
       (xsd:yearMonthDuration(?yearMonthDuration) as ?ymdYearMonthDuration)

where {
 bind(xsd:dateTime('2014-01-01T23:59:58Z') as ?dateTime) .
 bind(xsd:date('2014-01-01') as ?date) .
 bind(xsd:time('23:59:58') as ?time) .

 bind(xsd:dayTimeDuration('P1D2H3M4S') as ?dayTimeDuration) .
 bind(xsd:gDay("---12") as ?gDay) .
 bind(xsd:gMonth("-11") as ?gMonth) .
 bind(xsd:gMonthDay("-1112") as ?gMonthDay) .
 bind(xsd:gYear("1955") as ?gYear) .
 bind(xsd:gYearMonth("195511") as ?gYearMonth) .
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF






