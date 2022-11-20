-- case文の応用の使い方
-- ①
SELECT
    CASE pref_name
        WHEN'徳島'THEN'四国'
        WHEN'香川'THEN'四国'
        WHEN'愛媛'THEN'四国'
        WHEN'高知'THEN'四国'
        WHEN'福岡'THEN'九州'
        WHEN'佐賀'THEN'九州'
        WHEN'長崎'THEN'九州'
        ELSE'その他'
    END AS district,
    SUM(population)
FROM PopTbl
GROUP BY district

-- ②
SELECT
    pref_name,
    --男性の人口 
    SUM(CASE WHEN sex='1'THEN population ELSE 0 END)AS cnt_m,
    -- 女性の人口
    SUM(CASE WHEN sex='2'THEN population ELSE 0 END)AS cnt_f
FROM PopTbl2
GROUP BY pref_name;

-- ③
UPDATE Personnel
SET salary = CASE 
    WHEN salary >= 300000 THEN salary * 0.9 
    WHEN salary >= 250000 AND salary < 280000 THEN salary * 1.2 
    ELSE salary END;

-- ④
-- CASE式で主キーを入れ替える
UPDATE SomeTable
SET p_key = CASE 
    WHEN p_key = 'a' THEN 'b' 
    WHEN p_key = 'b' THEN 'a' 
    ELSE p_key 
END
WHERE p_key IN('a','b');


-- ⑤
-- テーブルのマッチング：IN述語の利用
SELECT 
    course_name,
    CASE 
        WHEN course_id IN(SELECT course_id FROM OpenCourses WHERE month = 201806) THEN '○' ELSE'×'
    END AS "6月",
    CASE 
        WHEN course_id IN(SELECT course_id FROM OpenCourses WHERE month = 201807) THEN '○' ELSE'×'
    END AS "7月",
    CASE WHEN course_id IN(SELECT course_id FROM OpenCourses WHERE month = 201808) THEN '○' ELSE '×' 
    END AS "8月"
FROM CourseMaster;

--　⑥
SELECT 
    std_id,
    CASE 
        WHEN COUNT (*) = 1 --1つのクラブに専念する学生の場合
        THEN MAX(club_id)
        ELSE MAX(CASE WHEN main_club_flg = 'Y' THEN club_id ELSE NULL END)
    END AS main_club
FROM StudentClub
GROUP BY std_id;
