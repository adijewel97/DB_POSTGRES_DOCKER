--1) chek database saat ini test
SELECT current_database(); 

--2) masuk ke schema adis
CREATE SCHEMA adis;

SET search_path TO adis;

SHOW search_path;

SELECT schema_name
FROM information_schema.schemata;


--3) buat table
create table adis.mst_alamat(
id varchar(10),
nama varchar(25)
);

select * from adis.alamat;


select adis.f_test();

--- record decalarasi
CREATE OR REPLACE FUNCTION adis.f_test2()
RETURNS SETOF RECORD
LANGUAGE sql
AS $function$
    SELECT id, nama FROM adis.mst_alamat;
$function$;


SELECT * FROM adis.f_test2() AS t(id VARCHAR, nama VARCHAR);


-- record REFCURSOR
CREATE OR REPLACE FUNCTION adis.f_test2_recursor(p_cursor_name TEXT DEFAULT 'my_cursor')
RETURNS REFCURSOR
LANGUAGE plpgsql
AS $function$
DECLARE
    my_cursor REFCURSOR;
BEGIN
    -- Gunakan nama cursor dari parameter
    my_cursor := p_cursor_name;

    -- Buka cursor
    OPEN my_cursor FOR SELECT * FROM adis.mst_alamat;

    -- Kembalikan nama cursor
    RETURN my_cursor;
END;
$function$;


BEGIN;
SELECT adis.f_test2_recursor(); -- Menggunakan nama default 'my_cursor'
FETCH ALL IN my_cursor;

SELECT adis.f_test2_recursor('custom_cursor'); -- Menggunakan nama 'custom_cursor'
FETCH ALL IN custom_cursor;
COMMIT;


SELECT * FROM pg_cursors;





DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT * FROM adis.mst_alamat LOOP
        RAISE NOTICE 'ID: %, Nama: %', rec.id, rec.nama;
    END LOOP;
END $$;


-- test json
CREATE OR REPLACE FUNCTION adis.f_test2_json()
RETURNS JSON
LANGUAGE sql
AS $function$
    SELECT json_agg(row_to_json(t))
    FROM (
        SELECT * FROM adis.mst_alamat
    ) t;
$function$;


SELECT adis.f_test2_json();



------------
CREATE OR REPLACE FUNCTION adis.f_test_output_cursor(
    vtahun     TEXT,        -- Parameter input tahun
    vidinput   TEXT,        -- Parameter input ID
    vinput_str TEXT         -- Parameter input tambahan
) 
RETURNS refcursor         -- Fungsi mengembalikan REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    my_cursor refcursor;  -- Deklarasi variabel cursor
BEGIN
    -- Membuka cursor untuk query
    OPEN my_cursor FOR
        SELECT *
        FROM adis.mst_alamat
        WHERE id LIKE vidinput || '%'  -- Filter berdasarkan input ID
          AND nama LIKE vinput_str || '%';  -- Filter berdasarkan nama

    -- Mengembalikan cursor
    RETURN my_cursor;
END;
$$;


SELECT adis.f_test_output_cursor('2024', '2024', 'AML202425142');


BEGIN;
SELECT adis.f_test_output_cursor('2024', '2024', 'AML202425142');
FETCH ALL IN "<unnamed portal 5>";
COMMIT;

 -- Start a transaction
   BEGIN;
    SELECT adis.f_test_output_cursor('2024', '2024', 'AML202425142');
   -- Returns: <unnamed portal 2> 
--   FETCH ALL IN "<unnamed portal 1>";
   COMMIT;

  
-- https://www.sqlines.com/postgresql/how-to/return_result_set_from_stored_procedure
 -- Procedure that returns a single result set (cursor)
   CREATE OR REPLACE FUNCTION show_cities() RETURNS refcursor AS $$
    DECLARE
      ref refcursor;                                                     -- Declare a cursor variable
    BEGIN
      OPEN ref FOR SELECT city, state FROM cities;   -- Open a cursor
      RETURN ref;                                                       -- Return the cursor to the caller
    END;
    $$ LANGUAGE plpgsql;


SELECT adis.show_cities();

    -- Start a transaction
BEGIN;
SELECT adis.show_cities();
-- Returns: <unnamed portal 2>
FETCH ALL IN "<unnamed portal 2>";
COMMIT;


 -- Procedure that accepts cursor names as parameters
CREATE OR REPLACE FUNCTION show_cities_multiple2(ref1 refcursor, ref2 refcursor) 
RETURNS SETOF refcursor AS $$
    BEGIN
      OPEN ref1 FOR SELECT city, state FROM cities WHERE state = 'Jawa Barat';   -- Open the first cursor
      RETURN NEXT ref1;                                                                              -- Return the cursor to the caller
 
      OPEN ref2 FOR SELECT city, state FROM cities WHERE city = 'Bandung';   -- Open the second cursor
      RETURN NEXT ref2;                                                                              -- Return the cursor to the caller
    END;
    $$ LANGUAGE plpgsql;
 
-- Start a transaction
   BEGIN;
 
   SELECT show_cities_multiple2('ca_cur', 'tx_cur');
 
   FETCH ALL IN "ca_cur";
   FETCH ALL IN "tx_cur";
   COMMIT;

