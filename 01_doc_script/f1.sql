-- DROP FUNCTION adis.f_test();

CREATE OR REPLACE FUNCTION adis.f_test()
	RETURNS varchar
	LANGUAGE sql
AS $function$
	BEGIN
		return 'output function';
	END;
$function$
