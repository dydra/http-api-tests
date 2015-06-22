#! /bin/bash

# exercise the temporal cast operators and accessors
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

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | keys' | fgrep '"' | wc -l | fgrep -q '47'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>

select (NOW() as ?NOW)
       (now() as ?now)
       (xsd:string(?date) as ?dateString)
       (xsd:date(?date) as ?dateDate)
       (xsd:date(?dateTime) as ?dateTimeDate)
       (YEAR(?date) as ?dateYear)
       (MONTH(?date) as ?dateMonth)
       (DAY(?date) as ?dateDay)
       (TIMEZONE(?date) as ?dateTimezone)  # supported as for dateTime
       (TZ(?date) as ?dateTZ)
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
       (xsd:string(?time) as ?timeString)
       (xsd:time(?time) as ?timeTime)  # time casts are limited
       (HOURS(?time) as ?timeHours)
       (MINUTES(?time) as ?timeMinutes)
       (SECONDS(?time) as ?timeSeconds)
       (TIMEZONE(?time) as ?timeTimezone)
       (TZ(?time) as ?timeTZ)
       (xsd:string(?dayTimeDuration) as ?dtdString)
       (xsd:dayTimeDuration(?dayTimeDuration) as ?dtdDayTimeDuration)
       (xsd:string(?gDay) as ?gdString)
       (xsd:gDay(?gDay) as ?gdGDay)
       (xsd:gDay(?dateTime) as ?dtGDay)
       (xsd:string(?gMonth) as ?gmString)
       (xsd:gMonth(?gMonth) as ?gmGMonth)
       (xsd:gMonth(?dateTime) as ?dtGMonth)
       (xsd:string(?gMonthDay) as ?gmdString)
       (xsd:gMonthDay(?gMonthDay) as ?gmdGMonthDay)
       (xsd:gMonthDay(?dateTime) as ?dtGMonthDay)
       (xsd:string(?gYear) as ?gyString)
       (xsd:gYear(?gYear) as ?gyGYear)
       (xsd:gYear(?dateTime) as ?dtGYear)
       (xsd:string(?gYearMonth) as ?gymString)
       (xsd:gYearMonth(?gYearMonth) as ?gymGYearMonth)
       (xsd:gYearMonth(?dateTime) as ?dtGYearMonth)
       (xsd:string(?yearMonthDuration) as ?ymdString)
       (xsd:yearMonthDuration(?yearMonthDuration) as ?ymdYearMonthDuration)

where {
 bind(xsd:dateTime('2014-01-01T23:59:58Z') as ?dateTime) .
 bind(xsd:date('2014-01-01') as ?date) .
 bind(xsd:time('23:59:58') as ?time) .

 bind(xsd:dayTimeDuration('P1DT2H3M4S') as ?dayTimeDuration) .
 bind(xsd:gDay("---12") as ?gDay) .
 bind(xsd:gMonth("--11") as ?gMonth) .
 bind(xsd:gMonthDay("--11-12") as ?gMonthDay) .
 bind(xsd:gYear("1955") as ?gYear) .
 bind(xsd:gYearMonth("1955-11") as ?gYearMonth) .
 bind(xsd:yearMonthDuration('P10Y1M') as ?yearMonthDuration) .
 }
EOF






