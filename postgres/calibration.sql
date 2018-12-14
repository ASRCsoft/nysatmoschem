/* Instrument calibration */

create or replace function estimate_zero_val(val text, times timerange, cal_date date, site int) returns numeric as $$
  declare
  exec_str text = $exec$
    with moving_averages as (
      select AVG(%I) OVER(ORDER BY instrument_time
			  ROWS BETWEEN 2 PRECEDING AND 2 following) as moving_average
	from envidas
       where instrument_time between $1 and $2
	 and envidas.station_id=$3
    )
    select min(moving_average) from moving_averages;
  $exec$;
  start_time timestamp = cal_date + lower(times);
  end_time timestamp = cal_date + upper(times);
  zero_estimate numeric;
begin
  execute format(exec_str, val)
    into zero_estimate
    using start_time, end_time, site;
  RETURN zero_estimate;
end;
$$ language plpgsql;
