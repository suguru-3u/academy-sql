

-- *** 検索結果の加工 ***
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

-- *** 式と関数 ***
select
 出金額 --列名での指定
 (出金額 + 100) as 100円増しの出金額, --計算式での指定
 'SQL' --固定値での指定
from 家計簿

-- DBMSは、テーブル内の各行を1つずつ順番に処理をしている
-- 式の評価も各行ごとに行われる

-- CASE（例１）
case 評価する列や式 
    when 値1 then 値1の時に返す値
    when 値2 then 値2の時に返す値
    else デフォルト値
end

-- CASE（例２）
case
    when 条件1 then 条件1の時に返す値
    when 条件2 then 条件2の時に返す値
    else デフォルト値
end

-- length
select 
    メモ
    length(メモ) as メモの長さ
from 家計簿

-- ユーザー定義関数、ストアドブロシーシャは格SQL製品によって異なる

-- trim（文字列） 左右から空白を除去
-- ltrim（文字列） 左から空白を除去
-- rtrim（文字列） 右から空白を除去

-- replace(置換対象の文字列、置換前の部分文字列、置換後の部分文字列)

-- substring(文字列の列、抽出を開始する位置、抽出する文字の数)

-- concat（文字列,文字列[文字列...]）

-- * 数値　*　

--round（数値の列、有効とする桁数）四捨五入
--trunc（数値の列、有効とする桁数）切り捨て
--power（数値の列、何乗するのか指定数値）べき乗

-- * 日付 *

-- current_date 現在の日付
-- current_time 現在の時刻

-- * 例外 *

cast（変換する値 as 変換する型）=> 変換後の値
coalesce(列) -- 引数の最初のnullではない値を返却するs
coalesce(列,nullの代替え) -- nullの代替えとしても利用できる

|| = concat関数

-- 関数はDBMSに負担をかけることを忘れない

-- *** 集計とグループ化 ***
-- sumなどの集計関数は全行をひとまとめに扱い、1回だけ集計処理を行う。
-- SUM,MAX,MIN,AVG(全て、NULLは無視される)
-- count(*) 検索結果の全行、NULLも含める
-- count(列) 指定列の行数、NULLの行は無視する

-- その列で重複している値を除いた状態で集計が行われる
select count(DISTINCT 費目) from 家計簿

select 費目,sum(出金額) as 合計金額
from 家計簿
group by 費目（費目列でグループ化する）

-- 集計関数はwhere句に利用できない

-- Having（グループ化されているものをさらに絞り込み）
select 費目,sum(出金額) as 合計金額
from 家計簿
group by 費目（費目列でグループ化する）
having sum(出金額) > 0 

--集計テーブル
-- 非常に大量のデータを取り扱う場合、集計テーブルと呼ばれるテーブルを使用する