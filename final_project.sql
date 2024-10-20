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
