CREATE TABLE supplier (s_suppkey INT, s_name CHARACTER VARYING, s_address CHARACTER VARYING, s_nationkey INT, s_phone CHARACTER VARYING, s_acctbal NUMERIC, s_comment CHARACTER VARYING, PRIMARY KEY (s_suppkey));
CREATE TABLE part (p_partkey INT, p_name CHARACTER VARYING, p_mfgr CHARACTER VARYING, p_brand CHARACTER VARYING, p_type CHARACTER VARYING, p_size INT, p_container CHARACTER VARYING, p_retailprice NUMERIC, p_comment CHARACTER VARYING, PRIMARY KEY (p_partkey));
CREATE TABLE partsupp (ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost NUMERIC, ps_comment CHARACTER VARYING, PRIMARY KEY (ps_partkey, ps_suppkey));
CREATE TABLE customer (c_custkey INT, c_name CHARACTER VARYING, c_address CHARACTER VARYING, c_nationkey INT, c_phone CHARACTER VARYING, c_acctbal NUMERIC, c_mktsegment CHARACTER VARYING, c_comment CHARACTER VARYING, PRIMARY KEY (c_custkey));
CREATE TABLE orders (o_orderkey BIGINT, o_custkey INT, o_orderstatus CHARACTER VARYING, o_totalprice NUMERIC, o_orderdate DATE, o_orderpriority CHARACTER VARYING, o_clerk CHARACTER VARYING, o_shippriority INT, o_comment CHARACTER VARYING, PRIMARY KEY (o_orderkey));
CREATE TABLE lineitem (l_orderkey BIGINT, l_partkey INT, l_suppkey INT, l_linenumber INT, l_quantity NUMERIC, l_extendedprice NUMERIC, l_discount NUMERIC, l_tax NUMERIC, l_returnflag CHARACTER VARYING, l_linestatus CHARACTER VARYING, l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct CHARACTER VARYING, l_shipmode CHARACTER VARYING, l_comment CHARACTER VARYING, PRIMARY KEY (l_orderkey, l_linenumber));
CREATE TABLE nation (n_nationkey INT, n_name CHARACTER VARYING, n_regionkey INT, n_comment CHARACTER VARYING, PRIMARY KEY (n_nationkey));
CREATE TABLE region (r_regionkey INT, r_name CHARACTER VARYING, r_comment CHARACTER VARYING, PRIMARY KEY (r_regionkey));
CREATE TABLE person (id BIGINT, name CHARACTER VARYING, email_address CHARACTER VARYING, credit_card CHARACTER VARYING, city CHARACTER VARYING, state CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE auction (id BIGINT, item_name CHARACTER VARYING, description CHARACTER VARYING, initial_bid BIGINT, reserve BIGINT, date_time TIMESTAMP, expires TIMESTAMP, seller BIGINT, category BIGINT, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE bid (auction BIGINT, bidder BIGINT, price BIGINT, channel CHARACTER VARYING, url CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING);
CREATE TABLE alltypes1 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE TABLE alltypes2 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE MATERIALIZED VIEW m0 AS SELECT (INT '453') AS col_0, ARRAY[TIMESTAMP '2022-10-03 12:49:13', TIMESTAMP '2022-10-03 12:49:13', TIMESTAMP '2022-10-03 13:48:13'] AS col_1, (CASE WHEN true THEN t_0.r_name WHEN (t_0.r_regionkey < (BIGINT '345')) THEN ('74KSBbXr4p') WHEN false THEN (substr(('VnYym1Hija'), t_0.r_regionkey)) ELSE t_0.r_name END) AS col_2 FROM region AS t_0 WHERE false GROUP BY t_0.r_regionkey, t_0.r_name;
CREATE MATERIALIZED VIEW m2 AS SELECT tumble_0.c4 AS col_0, (CAST(NULL AS STRUCT<a INT>)) AS col_1, tumble_0.c14 AS col_2 FROM tumble(alltypes1, alltypes1.c11, INTERVAL '4') AS tumble_0 GROUP BY tumble_0.c4, tumble_0.c10, tumble_0.c14 HAVING false;
CREATE MATERIALIZED VIEW m3 AS SELECT (747) AS col_0, TIMESTAMP '2022-10-03 13:49:14' AS col_1 FROM hop(auction, auction.expires, INTERVAL '1', INTERVAL '83') AS hop_0 WHERE true GROUP BY hop_0.date_time, hop_0.item_name, hop_0.expires, hop_0.seller, hop_0.reserve;
CREATE MATERIALIZED VIEW m4 AS SELECT tumble_0.auction AS col_0, (REAL '1') AS col_1 FROM tumble(bid, bid.date_time, INTERVAL '59') AS tumble_0 GROUP BY tumble_0.auction HAVING true;
CREATE MATERIALIZED VIEW m5 AS SELECT 'p4uyqeTif8' AS col_0, (md5(sq_1.col_0)) AS col_1 FROM (SELECT (TRIM('Hr6x8hM3Sb')) AS col_0 FROM hop(bid, bid.date_time, INTERVAL '60', INTERVAL '1980') AS hop_0 WHERE ((FLOAT '147') > (INT '432')) GROUP BY hop_0.channel, hop_0.date_time, hop_0.extra, hop_0.bidder) AS sq_1 WHERE true GROUP BY sq_1.col_0;
CREATE MATERIALIZED VIEW m7 AS SELECT sq_3.col_1 AS col_0 FROM (WITH with_0 AS (SELECT sq_2.col_3 AS col_0, sq_2.col_3 AS col_1, 'RARrclId7C' AS col_2, ((INT '793') + min(sq_2.col_1) FILTER(WHERE true)) AS col_3 FROM (SELECT 'lSmBRrHO7M' AS col_0, DATE '2022-10-03' AS col_1, t_1.col_0 AS col_2, 'G0mQYSPAQs' AS col_3 FROM m5 AS t_1 WHERE true GROUP BY t_1.col_0) AS sq_2 GROUP BY sq_2.col_3) SELECT (INT '765') AS col_0, (INT '44') AS col_1, (REAL '944') AS col_2, (DATE '2022-10-02' + (INT '0')) AS col_3 FROM with_0 WHERE false) AS sq_3 GROUP BY sq_3.col_3, sq_3.col_1 HAVING ((~ (SMALLINT '208')) < (~ (BIGINT '125')));
CREATE MATERIALIZED VIEW m8 AS SELECT hop_0.c16 AS col_0, (TIME '13:49:15' + ((INTERVAL '60') / (REAL '988'))) AS col_1, hop_0.c10 AS col_2, (hop_0.c10 + (TIMESTAMP '2022-10-03 13:49:15' - TIMESTAMP '2022-10-03 12:49:15')) AS col_3 FROM hop(alltypes2, alltypes2.c11, INTERVAL '3600', INTERVAL '331200') AS hop_0 WHERE hop_0.c1 GROUP BY hop_0.c16, hop_0.c10;
CREATE MATERIALIZED VIEW m9 AS SELECT tumble_0.name AS col_0, (TRIM(tumble_0.extra)) AS col_1, tumble_0.email_address AS col_2 FROM tumble(person, person.date_time, INTERVAL '9') AS tumble_0 GROUP BY tumble_0.state, tumble_0.email_address, tumble_0.name, tumble_0.extra HAVING true;