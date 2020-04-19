SELECT
    path,
    max(val)            AS values,
    quantileArray(vals) AS q1,
    ts
FROM (SELECT path, val, vals, ts
      FROM (SELECT
                path,
                groupArray(CounterValue)                                              AS value_arr,
                groupArray(TimeSampled)                                               AS time_arr,
                arrayMap(x -> arraySlice(value_arr, x, 2), arrayEnumerate(value_arr)) AS values
            FROM (-- удаление дублирующих значений
                  SELECT
                      TimeSampled,
                      path,
                      max(CounterValue) AS CounterValue
                  FROM (-- заполнение недостающих значений
                        SELECT
                            m1.TimeSampled,
                            m1.path,
                            m2.CounterValue AS CounterValue
                        FROM (
                            -- генерируем таблицу с равномерной временной сеткой
                            SELECT DISTINCT
                                arrayJoin(timeSlots(toDateTime(toDate('2019-02-12')), toUInt32(86200),
                                                    300)) AS TimeSampled,
                                toFloat32(0)              AS CounterValue,
                                Path                      AS path
                            FROM capacity.SCOMPerformance_raw) AS m1
                        ASOF LEFT JOIN (SELECT TimeSampled, Path as path, CounterValue FROM capacity.SCOMPerformance_raw WHERE toDate(TimeSampled) = toDate('2019-02-12')) AS m2
USING(path, TimeSampled))
                  GROUP BY TimeSampled, path
                  ORDER BY TimeSampled, path)
            GROUP BY path
               )
          ARRAY JOIN
           values    AS vals,
           time_arr  AS ts,
           value_arr AS val
      ORDER BY ts, path)
GROUP BY ts, path
ORDER BY ts, path