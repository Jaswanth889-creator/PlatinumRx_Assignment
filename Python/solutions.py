1. Minutes → Human readable

def convert_minutes(minutes):
    hrs = minutes // 60
    mins = minutes % 60
    
    if hrs == 0:
        return f"{mins} minutes"
    elif mins == 0:
        return f"{hrs} hrs"
    else:
        return f"{hrs} hrs {mins} minutes"

print(convert_minutes(130))

2. Remove duplicates (loop only)

def unique_string(s):
    result = ""
    for char in s:
        if char not in result:
            result += char
    return result

print(unique_string("programming"))