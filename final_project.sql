-- *** tìm hiểu về customer_id
-- chỉ có 96096 unique customers.
select
    count(distinct customer_unique_id)
-- 96096 
from customers

select
    count(*)
-- 2997 mua nhiều hơn 1 đơn hàng
from (
    select
        count(*) as a
    from customers
    group by customer_unique_id
    having count(*) > 1 
    -- order by a desc
) as temp_1;

select
    count(*)
-- 2770 -> có sự trùng lặp về địa điểm
from (
    select
        count(*) as a
    from customers
    group by customer_unique_id, customer_zip_code_prefix
    having count(*) > 1 
    -- order by a desc
) as temp_1;

--_________________________GEOLOCATION________________________________
select count(*)
from geolocation;
-- *** xoá các bản ghi lặp hoàn toàn trong geolocation 1,000,163 -> 738,332 
WITH
    CTE
    AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state ORDER BY (SELECT NULL)) AS rn
        FROM
            geolocation
    )
DELETE FROM CTE WHERE rn > 1;
select count(*)
from geolocation;
select top 3
    *
from geolocation;

-- loại bỏ những location không có trong customers và sellers -- 712506
with
    CTE
    as
    (
                    select
                distinct customer_zip_code_prefix
            from customers
        UNION
            select
                distinct seller_zip_code_prefix
            from sellers
    ),
    CTE2
    as
    (
        select distinct geolocation_zip_code_prefix
        from geolocation
    )
-- select count(*) from CTE
-- select * from CTE
delete from geolocation where geolocation_zip_code_prefix not in (select *
from CTE);
-- xoá các địa điểm ngoài brazil -- 712485 -- distinct zip_code 14915
delete from geolocation where geolocation_lat > 10 or geolocation_lng > -30
delete from geolocation where geolocation_lat < -34
select count(*)
from geolocation;
select count(distinct geolocation_zip_code_prefix)
from geolocation;

--
select *
from geolocation
WHERE geolocation_lat < 10 and geolocation_lat < -34
select *
from geolocation
where geolocation_lng between -33 and -30
select *
from geolocation
where geolocation_city = 'santa rosa'
select *
from geolocation
where geolocation_lat  < -34

-- gom nhóm zip_code, tính average lat-long, cập nhật giá trị cho các bản ghi
WITH
    AvgGeo
    AS
    (
        SELECT
            geolocation_zip_code_prefix,
            AVG(geolocation_lat) AS avg_lat,
            AVG(geolocation_lng) AS avg_lng
        FROM geolocation
        GROUP BY geolocation_zip_code_prefix
    )

UPDATE geolocation
SET
    geolocation_lat = AvgGeo.avg_lat,
    geolocation_lng = AvgGeo.avg_lng
FROM geolocation
    JOIN AvgGeo
    ON geolocation.geolocation_zip_code_prefix = AvgGeo.geolocation_zip_code_prefix;

select *
from geolocation
order by geolocation_zip_code_prefix
-- xoá các bản ghi trùng lặp * cột -- 22653
WITH
    CTE
    AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state ORDER BY (SELECT NULL)) AS rn
        FROM
            geolocation
    )
DELETE FROM CTE WHERE rn > 1;
select count(*)
from geolocation;
select top 3
    *
from geolocation;
-- xoá các bản ghi trùng lặp only zip_code -- 14915
WITH
    CTE
    AS
    (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY (SELECT NULL)) AS rn
        FROM
            geolocation
    )
DELETE FROM CTE WHERE rn > 1;
select count(*)
from geolocation;
select top 3
    *
from geolocation;

--____________________________ UPDATE CUSTOMER - SELLER _____________________________

-- Cập nhật bảng sellers  
SELECT *
from sellers
    LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS temp1
    ON sellers.seller_zip_code_prefix = temp1.geolocation_zip_code_prefix
WHERE temp1.geolocation_zip_code_prefix IS NULL;
-- curitiba -- porto alegre -- brasilia --  sao paulo --  aruja -- brasilia -- pocos de caldas
update sellers set seller_zip_code_prefix = '80035' where seller_id = '5962468f885ea01a1b6a97a218797b0a';
update sellers set seller_zip_code_prefix = '91710' where seller_id = '2aafae69bf4c41fbd94053d9413e87ee';
update sellers set seller_zip_code_prefix = '70200' where seller_id = '2a50b7ee5aebecc6fd0ff9784a4747d6';
update sellers set seller_zip_code_prefix = '01012' where seller_id = '2e90cb1677d35cfe24eef47d441b7c87';
update sellers set seller_zip_code_prefix = '07402' where seller_id = '0b3f27369a4d8df98f7eb91077e438ac';
update sellers set seller_zip_code_prefix = '70210' where seller_id = '42bde9fef835393bb8a8849cb6b7f245';
update sellers set seller_zip_code_prefix = '37713' where seller_id = '870d0118f7a9d85960f29ad89d5d989a';
select *
from geolocation
where geolocation_city = 'pocos de caldas'

-- customer --226
SELECT *
from customers
    LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS temp1
    ON customers.customer_zip_code_prefix = temp1.geolocation_zip_code_prefix
WHERE temp1.geolocation_zip_code_prefix IS NULL;

WITH
    CorrectZipCodes
    AS
    (
        SELECT
            geolocation_city,
            MIN(geolocation_zip_code_prefix) AS correct_zip_code
        FROM
            geolocation
        GROUP BY 
        geolocation_city
    )
-- bảng tạm
SELECT
    geolocation_city,
    correct_zip_code
INTO 
    #CorrectZipCodes
FROM
    CorrectZipCodes;
-- done
with
    CTE
    as
    (
        select
            customer_id
        FROM
            (
    SELECT *
            from customers
                LEFT JOIN
                (
            SELECT DISTINCT geolocation_zip_code_prefix
                FROM geolocation
        ) AS temp1
                ON customers.customer_zip_code_prefix = temp1.geolocation_zip_code_prefix
            WHERE temp1.geolocation_zip_code_prefix IS NULL
    ) s
            JOIN
            #CorrectZipCodes sz
            ON 
    s.customer_city = sz.geolocation_city
    )
-- select * from CTE
update customers
set customer_zip_code_prefix = #CorrectZipCodes.correct_zip_code
from #CorrectZipCodes
where customers.customer_id in (select *
    from CTE)
    and customers.customer_city = #CorrectZipCodes.geolocation_city
-- xoá bảng tạm
DROP TABLE #CorrectZipCodes;

--_________________________ query ________________________________
-- tìm kiếm theo cú pháp: bemposta RJ brazil (city - state - brazil)
-- Rua Rio Mampituba located in the neighborhood of Vargas in Sapucaia do Sul/RS
SELECT *
from customers
    LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS temp1
    ON customers.customer_zip_code_prefix = temp1.geolocation_zip_code_prefix
WHERE temp1.geolocation_zip_code_prefix IS NULL and customer_city = 'jacuipe';
select *
from customers
where customer_id ='7557541c9c578082c892cf185c3b0b47';

-- update customers set customer_zip_code_prefix = '35400' where customer_id ='c55a17a7c31353c35d48550b3aebc06f'
-- update customers set customer_city = 'ouro preto' where customer_id ='c55a17a7c31353c35d48550b3aebc06f'

-- update customers set customer_zip_code_prefix = '08970' where customer_id ='7557541c9c578082c892cf185c3b0b47' or customer_id ='b1a5afc135d86a079003163cf95cecaf'
-- update customers set customer_city = 'salesopolis' where customer_id ='7557541c9c578082c892cf185c3b0b47' or customer_id ='b1a5afc135d86a079003163cf95cecaf'

-- update customers set customer_zip_code_prefix = '65130', customer_city = 'paço do lumiar' where 
-- customer_id ='78bebfa74709728a62d4a98efbde8ac0' 
-- or customer_id ='8d1906125bb1f738d1f8a1d146ac3334'
-- or customer_id ='3bd12f7c1ad3a3908905785e43de8603'

-- update customers set customer_zip_code_prefix = '28650', customer_city = 'duas barras' where 
-- customer_id ='814dfd64a142fe2564faef3932b676b9' 
-- or customer_id ='4d12da03af6b4513c13c61dcc5171626'

-- update customers set customer_zip_code_prefix = '28375', customer_city = 'varre-sai' where customer_id ='9898e8eddc4e40527c7cda1dc8ef3a9f'

-- update customers set customer_zip_code_prefix = '06900', customer_city = 'embu-guaçu' where customer_id ='f341549b5b28a46a5b4db2f4372e36a2'

-- update customers set customer_zip_code_prefix = '36955', customer_city = 'mutum' where customer_id ='53c26135cf44344a6c00bf51771980c4'

-- update customers set customer_zip_code_prefix = '35240', customer_city = 'conselheiro pena' where customer_id ='b88b7689eba14a29896c654986bec727'

-- update customers set customer_zip_code_prefix = '29709', customer_city = 'colatina' where customer_id ='e988b94fc82408ecac8299c744959c58'

-- update customers set customer_zip_code_prefix = '73850', customer_city = 'cristalina' where 
-- customer_id ='4a5642b29f7d0885758928dc7ec35909' 
-- or customer_id ='ce102f790bb667f9851019a3cb0ed958'

-- update customers set customer_zip_code_prefix = '25821', customer_city = 'três rios' where customer_id ='cdc2bba36d83fe46dea8a0dce9453146'

-- update customers set customer_zip_code_prefix = '85070', customer_city = 'guarapuava' where 
-- customer_id ='f58c14ad1417ae5e8f9c6d0f9f6aec24' 
-- or customer_id ='15d1ff96168e59165bb5ccf454b44b85'

-- update customers set customer_zip_code_prefix = '95840', customer_city = 'triunfo' where customer_id ='9d5ff5d7ce2e4bc386bf11b9adb46a19'

-- update customers set customer_zip_code_prefix = '93218', customer_city = 'sapucaia do sul' where customer_id ='aa743174847b78266e47461b8bcd1bb5'

-- update customers set customer_zip_code_prefix = '58685', customer_city = 'assuncao' where customer_id ='dcef2fe349300ac52c962eb0f0fbc453'

-- update customers set customer_zip_code_prefix = '35057', customer_city = 'governador valadares' where customer_id ='80ca2676141288b0fb864389fa7e49c5'

-- update customers set customer_zip_code_prefix = '17380', customer_city = 'brotas' where customer_id ='e76656ce4486a41da00e471277b1d1e9'

-- update customers set customer_zip_code_prefix = '36594', customer_city = 'araponga' where customer_id ='c785e91c77b1e2fc9f642dbf170adbd4'

-- update customers set customer_zip_code_prefix = '37458', customer_city = 'alagoa' where customer_id ='0e1b17d09c043febb1b71ade300fc357'

-- update customers set customer_zip_code_prefix = '48500', customer_city = 'euclides da cunha' where customer_id ='f330cb20d9d9c5779de924d6a5fef754'

-- update customers set customer_zip_code_prefix = '83840', customer_city = 'quitandinha' where customer_id ='e37623a7c983c5174d5aea2aad30a080'

-- update customers set customer_zip_code_prefix = '62620', customer_city = 'irauçuba' where customer_id ='52e73a5d0a1d4c56b090cd70e0d678ee'

-- update customers set customer_zip_code_prefix = '49860', customer_city = 'graccho cardoso' where customer_id ='daf22b7353d8e5021df9894b32dd6b45'

-- update customers set customer_zip_code_prefix = '85955', customer_city = 'maripá' where customer_id ='25efef823626e7fa4e74f0bc9db133d1'

-- update customers set customer_zip_code_prefix = '19750', customer_city = 'lutecia' where customer_id ='78519cf01865cbd8e54ae1dab60ef77e'

-- update customers set customer_zip_code_prefix = '44096', customer_city = 'feira de santana' where customer_id ='d198b40ba4bff0ab7ca1a37d872e9c5b'

-- update customers set customer_zip_code_prefix = '28110', customer_city = 'campos dos goytacazes' where customer_id ='59365a596fafb5488c739ac1e657f6ab'

-- update customers set customer_zip_code_prefix = '87320', customer_city = 'roncador' where customer_id ='19bacb562bd43bd4eaf05b6c0a59dad0'

-- update customers set customer_zip_code_prefix = '65810', customer_city = 'alto parnaíba' where customer_id ='e6add8f4805cb6a382c26548daaed9d7'

-- update customers set customer_zip_code_prefix = '28570', customer_city = 'itaocara' where customer_id ='8a629de914739aa508711c4311abf537'

-- update customers set customer_zip_code_prefix = '85070', customer_city = 'guarapuava' where 
-- customer_id ='6f392cfb40b84e0857b16c23c773aa31' 
-- or customer_id ='de6df770eafe17bbee77c0d639fd8878'

-- insert into geolocation values ('28160', -21.2153199, -41.4678679, 'santo eduardo', 'RJ')

-- insert into geolocation values ('43870', -12.3305, -38.7671, 'jacuipe', 'BA')

-- insert into geolocation values ('38710', -18.70278, -46.04194, 'major porto', 'MG')

-- update customers set customer_zip_code_prefix = '36240', customer_city = 'santos dumont' where customer_id ='437dde455d8442c3e2b3dc1a7063ed2b'

-- update customers set customer_zip_code_prefix = '31910', customer_city = 'belo horizonte' where customer_id ='786cc4eab38165553b0fb0c53a35817a'

-- update customers set customer_zip_code_prefix = '59295', customer_city = 'sao goncalo do amarante' where customer_id ='aa4c5b95810a5d4b1bf2cc56e7d76cd6'

-- update customers set customer_zip_code_prefix = '85892', customer_city = 'santa helena' where customer_id ='7b0a3a430a7e8b6183eac952df55cb07'

-- update customers set customer_zip_code_prefix = '36850', customer_city = 'antônio prado de minas' where customer_id ='7d643c6504deebe6d2ab830865d71584'

-- update customers set customer_zip_code_prefix = '42808', customer_city = 'camaçari' where customer_id ='aacd2c89b47bcc2aa875ea9b1f64955d'

-- update customers set customer_zip_code_prefix = '83221', customer_city = 'paranaguá' where customer_id ='948b29e24216a05fea13a18d8db45ea5'

-- update customers set customer_zip_code_prefix = '86990', customer_city = 'marialva' where customer_id ='535a05f4c66c1ebb2b8c6a537a7f2149'

-- update customers set customer_zip_code_prefix = '27985', customer_city = 'glicerio' where customer_id ='1daae5de6467ac2cb6cb6707025b2b40'

-- update customers set customer_zip_code_prefix = '58280', customer_city = 'mamanguape' where customer_id ='b6d6fadbee4df0e3c0aab81a046124a6'

-- update customers set customer_zip_code_prefix = '38625', customer_city = 'cabeceira grande' where customer_id ='8b20eb37b30208feef373de67fc749e0'

-- update customers set customer_zip_code_prefix = '55860', customer_city = 'sao vicente ferrer' where customer_id ='78a11bb1fa72f556996b9a5b9bcd0629'

-- insert into geolocation values ('28530', -21.75528, -42.37889, 'sao sebastiao do paraiba','RJ') 
select *
from geolocation
where geolocation_city like '%corrego do ouro%'
select *
from geolocation
where geolocation_city like 'corrego do ouro'
select *
from geolocation
where geolocation_state = 'PE'
select *
from geolocation
where geolocation_zip_code_prefix = '55863'

SELECT *
from customers
    LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS temp1
    ON customers.customer_zip_code_prefix = temp1.geolocation_zip_code_prefix
WHERE temp1.geolocation_zip_code_prefix IS NULL and customer_city = 'corrego do ouro';
-- drop table geolocation
-- drop table sellers
-- drop table customers
select count(distinct geolocation_zip_code_prefix)
from geolocation

select *
from customers
select *
from sellers
select *
from geolocation;
