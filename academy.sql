

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

-- *** 副問合せ（サブクエリ） ***
-- expmalte
-- 副問合せが実行後に実行される
select 費目,出金額 from 家計簿
-- 最初に以下を実行
where 出金額　= (select Max(出金額) from 家計簿)

-- 副問合せのパターン
-- 1 単一の値 （1行1列）
-- select文の選択列リストやfrom、Updateのset、whereに使用できる
select 日付,メモ,出金額
    (select 合計 from 家計簿集計
    where 費目 = "食費") as 過去の合計
from 家計簿アーカイブ
where 費目 = '食費'

-- 2 列挙された複数値 （n行1列）
-- 複数の値の判定に使用するwhere,selectのfromに使用できる,INやANYやAll
select * from 家計簿集計
where 費目 IN (select DISTINCT 費目 from 家計簿)
-- NOT INと<>ALL・・・全ての値が一致しないこと、
-- INと = ANY ・・・・いずれかの値と一致すること
-- 問合せの結果にNULLがあると全体の結果もNULLになる

-- 3 表形式の複数値（n行n列）
-- selectのfrom、INSERTで使用可能
select SUN(SUB.出金額) AS 出金額合計
from
(select 日付,費目,出金額
from 家計簿
UNION
select 日付,費目,出金額
from 家計簿アーカイブ
where 日付 >= "2018-10-01"
and 日付 <= "2018-01-31") AS SUB

-- Insertの副問い合わせは（）が存在しない

-- *** 複数テーブルの結合　***
-- 内部結合
select 選択リスト
from テーブルA --（主役）
join テーブルB
on お互いのテーブルの結合条件
-- 結合とはテーブルを繋ぐことではなく、結合条件が満たされた行を1つひとつ繋ぐことである
-- 繋ぐべき右表の行が複数ある時、DBMSは左表の列を複製して結合する。結果表の行数は元の左表の行数よりも増える
-- 右表に結合お相手の行がない場合や、左表の結合条件の列がNULLの場合、結合結果から消滅する。

-- 左外部結合（検索結果がnullであろうと左表は全て表示される）
select 列
from テーブルA 
left join テーブルB
on 結合条件

-- 右外部結合（右表の行を必ず出力する）
select 列
from テーブルA 
right join テーブルB
on 結合条件

-- 完全外部結合（左右の表の全行を必ず出力する）
select 列
from テーブルA 
right join テーブルB
on 結合条件

-- *** トランザクション ***
-- 1つ以上のSQLを一塊として扱うことを指示することができる。
-- この塊のことをトランザクションという
-- トランザクションにより、処理の中断や他の人の処理が割り込めないようにする。

BEGIN; --処理の開始（複数の処理を同時に行いたい）
Insert into --~
Insert into --~ 
COMMIT; --終了の指示、変更の確定を行う

BEGIN --処理の開始
DELETE FROM 家計簿 WHERE 日付 = "2018-03-20"
ROLLBACK; --終了の指示、変更の取り消しを行う（ここではDelete）

BEGIN 
-- Lock table 家計簿 IN EXCLUSIVE MODE（処理中に他の人によって家計簿テーブルの内容が変化しないようにSQLを実行）
COMMIT


-- *** テーブルの作成 ***
-- DML・・・selectやupdateなど
-- DDL・・・CreateやALTERなど
-- TCL・・・COMMITやROLLBACKなど
-- DCL・・・GRANT（DMLやDDLに関する許可や禁止の設定）
CREATE TABLE 家計簿(
    日付 DATE　NOT NULL, --NULLを許可しない
    費目ID INTEGER REFERENCES 費目(ID) --外部キー（最後に足すパターンも存在する）
    メモ VARCHAR(100) CHECK(メモ.length >= 0), --値の妥当性の確認
    入金額 INTEGER DEFAULT 0, --値がなかった場合のデフォルト値
)

CREATE TABLE 費目(
    ID INTEGER PRIMARY KEY AUTO_INCREMENT, -- 主キー（単独の設定）
    名前 VARCHAR(40) UNIQUE --重複の制約
    PRIMARY KEY(ID,名前) --主キー(複数設定)
) 

-- 削除
DROP TABLE テーブル名

-- 変更
ALTER TABLE
-- 列の追加
ALTER TABLE テーブル名 ADD 列名 型 制約
-- 列の削除
ALTER TABLE テーブル名 DROP 列名 型 制約

-- *** より便利なDB知識 ***
-- * インデックスの使用

-- * ビュー
-- SQLの結果表をテーブルのように扱うことができるビューview
create view ビュー名 as select文
drop view ビュー名

create view 家計簿4月 as
select * from 家計簿
where 日付 >= "2018-04-01"
and 日付 <= "2018-04-30"

--家計簿4月ビューを使ったSQL文の実行
select * from 家計簿4月 --シンプルに書くことができる

-- *** バックアップ ***
--オフラインバックアップ：DBを停止して行うバックアップ
--オンラインバックアップ：DBを稼働させながら行うバックアップ
--データベースの内容、ログファイルの内容をバックアップする