

-- *** 検索結果の加工
/*
* 検索結果を加工するキーワード（select分だけ可能）
* DISTINCT　検索結果から重複行を排除する
* ORDER BY　検索結果の順序を並べ替える
* OFFSET-FETCH　検索結果から件数を限定して取得する
*　MySQL,MariaDB,SQLiteではサポートされていない
* UNION　検索結果に他の検索結果を足し合わせる
* EXCEPT　検索結果から他の検索結果を差し引く
* INTERSECT　検索結果と他の検索結果で重複する部分を取得する
*/

select DISTINCT 入金額 FROM 家計簿

select * from 家計簿 order by 出金額

-- 出金額の高い順に3件取得する
select 費目,出金額 from 家計簿
order by 出金額 desc
offset 0 rows
fetch next 3 rows only

-- MySQL対応（出金額の高い順に3件取得する）
select 費目,出金額 from 家計簿
order by 出金額 desc limit 3

-- 和集合を取得する
-- テーブルの列数とデータ型を一致させる必要がある
-- order byは最後のselectで使用する
-- 列が足りない場合は、列にNULLを追加するても存在する
select 費目,入金額,出金額 from 家計簿
UNION
select 費目,入金額,出金額 from 家計簿
order by 2,3,1

-- 差集合
-- 最初の検索結果から次の検索結果と重複する部分を取り除いたもの
select 費目,入金額,出金額 from 家計簿
EXCEPT
select 費目,入金額,出金額 from 家計簿

-- 積集合
-- 2つの検索結果で重複するもの
select 費目,入金額,出金額 from 家計簿
INTERSECT
select 費目,入金額,出金額 from 家計簿

-- memo
-- order byやunionはそれなりの負荷がかかる