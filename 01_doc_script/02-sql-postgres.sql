select case when upper(state) = upper(:vstate) then 
			city
	   else
	       'no'
		end as aa
from adis.cities c;


select city as aa
from adis.cities c
where upper(state) = upper(:vstate);
