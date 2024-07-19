import argparse
import os
import traceback
from argparse import Namespace
from datetime import datetime, timedelta, timezone
from concurrent.futures import ProcessPoolExecutor
from dateutil.parser import parse
from itertools import islice
from typing import List
#from multiprocessing import Pool
import multiprocessing
import sys


def find_min_date(file_path: str) -> datetime:
    min_time: datetime = datetime.max
    min_time = min_time.replace(tzinfo=timezone.utc)
    with open(file_path, 'r') as f:
        line_idx = 0
        for line in f:
            if line_idx % 4 == 0:
                record_id: str = line.rstrip('\n')

                start_strtime: int = record_id.find('start_time=')
                end_strtime: int = record_id.find(" ", start_strtime)
                if end_strtime == -1:
                    end_strtime = len(record_id) # record_id.find(" ", start_strtime) # start_strtime + 11 + 32

                timestamp_str = record_id[start_strtime + 11:end_strtime]
                # timestamp = datetime.fromisoformat(timestamp_str)

                timestamp: datetime = parse(timestamp_str) #, '%Y-%m-%dT%H:%M:%SZ')  # '%Y%m%dT%H%M%S.%f'
                min_time = min(min_time, timestamp)
            line_idx += 1
    return min_time
    

    
# min_timestamp = find_min_date('D:\Veronica\Documents\IJ_IDEA\Python\Tachyon_1.0\Input\FAS70744_pass_18e751a1_0.fastq')

def write_filtered_by_time(file_path: str, output_dir: str, time: int) -> None:
    min_timestamp = find_min_date(file_path)
          
        
    print(min_timestamp)
    cutoff_time: datetime = min_timestamp + timedelta(minutes=time)
    output_file_path: str = os.path.join(output_dir, f'output_Cutted_{time}min_{os.path.basename(file_path)}')
       
    with open(file_path, 'r') as f_in, open(output_file_path, 'w') as f_out:
        # line_count = 0
        while True:
            chunk = list(islice(f_in, 8))
            if not chunk:
                break
            for line in range(0, len(chunk), 4):
                record_id = chunk[line]
                if len(record_id) == 0:
                    break
                # index = line
                sequence = chunk[line+1]
                plus_line = chunk[line+2] # f_in.readline()
                quality_scores = chunk[line+3] #f_in.readline()

                # Process the last record in the file
                start_strtime = record_id.find('start_time=')
                end_strtime = record_id.find(" ", start_strtime)
                if end_strtime == -1:
                    end_strtime = len(record_id)
                timestamp_str = record_id[start_strtime + 11:end_strtime]
                timestamp = parse(timestamp_str)

                if timestamp <= cutoff_time:
                    f_out.write(record_id)
                    f_out.write(sequence)
                    f_out.write(plus_line)
                    f_out.write(quality_scores)
                    




def main(input_dir: str, output_dir: str, time: int,  num_cores: int) -> None:
    # file_paths = [os.path.join(input_dir, f) for f in os.listdir(input_dir) if f.endswith('.fastq')]
    #file_path = input_dir
    # with ProcessPoolExecutor() as executor:
        # for file_path in file_paths:
        #executor.submit(write_filtered_by_time, file_path, output_dir, time)
    #write_filtered_by_time(file_path, output_dir, time)
    
 
   with multiprocessing.Pool(processes=num_cores) as pool:
        
        # Map the find_min_date function to the input file
        pool.apply(find_min_date, args=(input_dir,))    
        # Map the write_filtered_by_time function to the input file
        pool.apply(write_filtered_by_time, args=(input_dir, output_dir, time))
        
     

if __name__ == '__main__':
    # input_dir = 'D:\Veronica\Documents\IJ_IDEA\Python\Tachyon_1.0\Input'
    # output_dir = 'Output'
    # time = 1
    # main('/FAU11695_pass_dd850d66_0.fastq', 'Output', 3)
    # args = sys.argv
    # print.args

    # Create an argument parser
    parser = argparse.ArgumentParser(description='The fastq file Cutoff by timepoimt stemp')
    # Define the arguments that your script accepts
    parser.add_argument('--input', type=str, required=True, help='Path to the input file')
    parser.add_argument('--output', type=str, required=True, help='Path to the output file')
    parser.add_argument('-t', '--time', type=int, default=1, help='Number of cut minutes from the file')
    parser.add_argument("--cores", type=int, default=4, help="Number of cores (default: 4)")
 
    # Parse the command line arguments
    args: Namespace = parser.parse_args()  #
    # Access the arguments in your code
    input_dir: str = args.input
    output_dir: str = args.output
    time: int = args.time
    cores: int = args.cores


    try:
        main(input_dir, output_dir, time, cores)
    except BaseException as ex:
        # print("Exception:", ex)
        traceback.print_exc()


