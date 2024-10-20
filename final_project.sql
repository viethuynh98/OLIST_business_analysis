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
