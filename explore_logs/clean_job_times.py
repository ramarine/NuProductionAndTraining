import re
import sys
import os
from datetime import datetime

def parse_time(t):
    try:
        return datetime.strptime(t, "%Y-%m-%dT%H:%M:%S")
    except:
        return None

def parse_maxrss(s):
    s = s.strip()
    if not s or s == '0':
        return 0
    try:
        if s.endswith('K'):
            return int(float(s[:-1]) * 1024)
        elif s.endswith('M'):
            return int(float(s[:-1]) * 1024 * 1024)
        elif s.endswith('G'):
            return int(float(s[:-1]) * 1024 * 1024 * 1024)
        else:
            return int(s)
    except:
        return 0

def analyze_job_log(directory, filename):
    filepath = os.path.join(directory, filename)
    jobs = {}

    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('JobID') or line.startswith('----'):
                continue

            parts = re.split(r'\s+', line)

            if len(parts) < 6:
                continue

            jobid = parts[0]
            jobname = parts[1]
            start_str = parts[2]
            end_str = parts[3]
            maxrss_str = parts[5] if len(parts) > 5 else '0'

            m = re.match(r'(\d+)_', jobid)
            if not m:
                continue
            parent = m.group(1)

            start_time = parse_time(start_str)
            end_time = parse_time(end_str)
            maxrss = parse_maxrss(maxrss_str)

            if parent not in jobs:
                jobs[parent] = {
                    'jobname': None,
                    'start_times': [],
                    'end_times': [],
                    'maxrss': []
                }

            if jobname != 'extern':
                if start_time:
                    jobs[parent]['start_times'].append(start_time)
                if end_time:
                    jobs[parent]['end_times'].append(end_time)

            jobs[parent]['maxrss'].append(maxrss)

            if jobs[parent]['jobname'] is None and jobname not in ('batch', 'extern'):
                jobs[parent]['jobname'] = jobname

    output_file = os.path.join(directory, 'job_times_summary.log')
    with open(output_file, 'w') as out_file:
        for pj, data in sorted(jobs.items()):
            starts = data['start_times']
            ends = data['end_times']
            maxrss_vals = data['maxrss']
            jobname = data['jobname'] or "N/A"

            if not starts or not ends:
                out_file.write(f"No valid times found for job {pj}\n")
                continue

            earliest_start = min(starts)
            latest_end = max(ends)
            total_time = latest_end - earliest_start
            max_mem_bytes = max(maxrss_vals)

            out_file.write(f"Parent Job {pj} ({jobname}):\n")
            out_file.write(f"  Earliest start: {earliest_start}\n")
            out_file.write(f"  Latest end:     {latest_end}\n")
            out_file.write(f"  Total elapsed:  {total_time}\n")
            out_file.write(f"  Highest MaxRSS: {max_mem_bytes / (1024*1024):.2f} MB\n\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 clean.py <path_to_file> <file_name.log>")
        sys.exit(1)

    path_to_file = sys.argv[1]
    file_name = sys.argv[2]
    analyze_job_log(path_to_file, file_name)
