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


-- windouw関数
select 口座番号,種別,残高,sum(残高) over(partition by 種別 order by 種別)
from 口座
-- partition byを使用してグルーピングし、order byでソートしている。
-- sumの部分はいろんな種類が存在する。
-- 参考サイト（https://resanaplaza.com/2021/10/17/%E3%80%90%E3%81%B2%E3%81%9F%E3%81%99%E3%82%89%E5%9B%B3%E3%81%A7%E8%AA%AC%E6%98%8E%E3%80%91%E4%B8%80%E7%95%AA%E3%82%84%E3%81%95%E3%81%97%E3%81%84-sql-window-%E9%96%A2%E6%95%B0%EF%BC%88%E5%88%86/）

-- 自己結合
-- 同一のテーブルを対象に行う結合を「自己結合」と呼ぶ
-- クロス結合には、結合条件が存在しない（二つのテーブルを総当たりで全てのレコードを列挙しているため）
select p1.*, p2.*
from 家計簿 p1 cross join
家計簿 p2

select p1.* ,p2.*
from 家計簿 p1 inner join 家計簿 p2
on p1.日付 > p2.日付

-- 1. 自己結合は非等値結合と組み合わせて使うのが基本。
-- 2．GROUPBYと組み合わせると、再帰的集合を作ることができる。
-- 3．本当に異なるテーブルを結合していると考えると理解しやすい。
-- 4．物理ではなく論理の世界で考える。


--QA
-- 自己相関サブクエリ,結合
