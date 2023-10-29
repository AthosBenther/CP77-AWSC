--- Gets the current date and time formatted as "yyyy-mm-dd-hh-mm-ss".
--- @return string result The formatted date and time string.
function get_date_time_safe_string()
    local current_time = os.date("*t")
    local formatted_date_time = string.format(
        "%04d-%02d-%02d-%02d-%02d-%02d",
        current_time.year,
        current_time.month,
        current_time.day,
        current_time.hour,
        current_time.min,
        current_time.sec
    )
    return formatted_date_time
end
