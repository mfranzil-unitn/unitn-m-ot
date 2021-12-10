import mysql.connector as mysql
from mysql.connector import Error
import os
import signal
import threading
from datetime import datetime
import logging
import time
import subprocess
import argparse

# PARAMS NEEDED FOR THE EXECUTION
parser = argparse.ArgumentParser(
    description='Database checker, if the db is in a consistent state a copy of the whole DB and of the request.log file is saved. A log of the ativity can be found in ./log_output')
parser.add_argument('-t', dest='check_time',
                    type=int, default=60, help='Number of seconds on which the script should check the status of the DB. By defualt is 60s')
parser.add_argument('-n', dest='backup_number',
                    type=int, default=3, help='Number of backup that you want to save, by default is 3 so only the last 3 backups are saved, any new beachup will overwrite the oldest backup')
args = parser.parse_args()

# USEFUL PARAMETERS
TIME = args.check_time # Number of second every which the db should be checked
BACKUP_NUMBER = args.backup_number # number of bakup to save before overwrite the oldest
BACKUP_DB_DIR = os.path.join(os.getcwd(), 'backup_db')
BACKUP_LOG_DIR = os.path.join(os.getcwd(), 'backup_log')
MYSQL_ERROR_LOG = '/var/log/mysql/error.log' 
LOG_DIR = '/tmp/request.log'
USER = 'monitor'
USER_PSW = 'dfvYp$6^L4rNv3RdCWF6hef*LSnfi&'
cnx = None

query = {
    'negative_amount': 'SELECT user, SUM(amount) AS total FROM transfers GROUP BY (user) HAVING total < 0;',
    'unexisting_user': 'SELECT * FROM transfers WHERE user NOT IN (SELECT user FROM users);', # is this needed?
    'number_of_users': 'SELECT COUNT(user) AS un FROM users;',
    'number_of_transfers': 'SELECT COUNT(tid) AS tn FROM transfers;',
    'matching_balance': 'SELECT * FROM (SELECT users.user, users.balance, tot_transfer.tot FROM (SELECT user, SUM(amount) as tot from transfers GROUP BY user) AS tot_transfer INNER JOIN users ON users.user=tot_transfer.user) as maching_balance GROUP BY user HAVING balance != tot;',
}

# LOGGING CONFIGURATION
logging.basicConfig(filename='./log_output/check_db.log',
                    filemode='a', format='%(message)s', level=logging.INFO)

# Method used to create the connection with the database
def connect():
    try:
        cnx = mysql.connect(host='localhost', database='ctf2', user=USER, password=USER_PSW)
        if cnx.is_connected() and cnx != None:
            print('Connected to database')
            logging.info('\n\nConnected to database')
        else:
            print('Something went wrong with the connection to the DB')
            logging.info('Something went wrong with the connection to the DB')
            os._exit(1)

    except Error as e:
        print('An error occurred while trying to connect to the DB')        
        print(e)
        logging.info(str(datetime.now()))
        logging.info('An error occurred while trying to connect to the DB')
        logging.info(e)
        os._exit(1)

    return cnx


# Check if some user has a negative balance -> True everything Ok, False somenthing wrong
def negative_amount_check():
    cursor = cnx.cursor(buffered=True)
    cursor.execute(query.get('negative_amount'))
    if cursor.rowcount > 0: # we expect to have zero line, more than 1 lines means that someone has a negative balance
        # printing a table with all the user with a negative balance
        print('\n -Negative balance found:')
        print('+{:-^63}+'.format(''))
        print('|{:^40} | {:^20}|'.format('USER', 'AMOUNT'))
        print('+{:-^63}+'.format(''))
        
        logging.info('\n -Negative balance found:')
        logging.info('+{:-^63}+'.format(''))
        logging.info('|{:^40} | {:^20}|'.format('USER', 'AMOUNT'))
        logging.info('+{:-^63}+'.format(''))
        
        for user, amount in cursor:
            print('|{:^40} | {:^20}|'.format(user, amount))
            logging.info('|{:^40} | {:^20}|'.format(user, amount))
        
        print('+{:-^63}+'.format(''))
        logging.info('+{:-^63}+'.format(''))
        cursor.close()
        return False

    print(' -No negative balace found')    
    cursor.close()
    return True    

# Checking if the number of transfers is constant, we expect it to grow or stay the same but it cannot decrease -> True everything normal, False something wrong
transfers_number = 0
def transfers_number_check():
    global transfers_number
    cursor = cnx.cursor(buffered=True)
    cursor.execute(query.get('number_of_transfers'))
    if cursor.rowcount == 1: # expecting just one line, the count of element in the table
        result = cursor.fetchone()
        
        if transfers_number > result[0]:
            print(f'\nUnexpected delete in transfers table expected at least {transfers_number} entry but found only {result[0]}')
            logging.info(f'\nUnexpected delete in transfers table expected at least {transfers_number} entry but found only {result[0]}')
            cursor.close()
            return False
        transfers_number = result[0] # everything okay, updating number of entry
        
    else:
        # weird error, we got an unexpected number of rows
        print('\nGetting the number of transfers produced a result with more than one line.')
        print(f'Query used:  {query["number_of_transfers"]}\n')
        logging.info('\nGetting the number of transfers produced a result with more than one line.')
        logging.info(f'Query used:  {query["number_of_transfers"]}\n')
        cursor.close()
        return False
    
    print(' -No unexpected variation in the number of transfers found') 
    cursor.close()  
    return True


# Checking if the number of users is constant, we expect it to grow or stay the same but it cannot decrease -> True everything normal, False something wrong
users_number = 0
def users_number_check():
    global users_number
    cursor = cnx.cursor(buffered=True)
    cursor.execute(query.get('number_of_users'))
    if cursor.rowcount == 1: # expecting just one line
        result = cursor.fetchone()
        
        if users_number > result[0]:
            print(f'\nUnexpected delete in users table expected at least {users_number} entry but found only {result[0]}')
            logging.info(f'\nUnexpected delete in users table expected at least {users_number} entry but found only {result[0]}')
            cursor.close()
            return False
        users_number = result[0] # everything okay, updating number of entry
        
    else:
        # weird error, we got an unexpected number of rows
        print('\nGetting the number of users produced a result with more than one line.')
        print(f'Query used:  {query["number_of_users"]}\n')
        logging.info('\nGetting the number of users produced a result with more than one line.')
        logging.info(f'Query used:  {query["number_of_users"]}\n')
        cursor.close()
        return False
    
    print(' -No unexpected variation in the number of users found') 
    cursor.close()  
    return True

def matching_balance_check():
    cursor = cnx.cursor(buffered=True)
    cursor.execute(query.get('matching_balance'))
    if cursor.rowcount > 0: # expecting at least one line
        result = cursor.fetchall()
         # printing a table with all the user with an unmatching balance
        print('\n -Unmatching balance found:')
        print('+{:-^85}+'.format(''))
        print('|{:^40} | {:^20}| {:^20}|'.format('USER', 'BALANCE', 'TOT TRANSFERS'))
        print('+{:-^85}+'.format(''))
        
        logging.info('\n -Unmatching balance found:')
        logging.info('+{:-^85}+'.format(''))
        logging.info('|{:^40} | {:^20}| {:^20}|'.format('USER', 'BALANCE', 'TOT TRANSFERS'))
        logging.info('+{:-^85}+'.format(''))
        
        for user, balance, tot_transfer in result:
            if(balance != tot_transfer):
                print('|{:^40} | {:^20}| {:^20}|'.format(user, balance, tot_transfer))
                logging.info('|{:^40} | {:^20}| {:^20}|'.format(user, balance, tot_transfer))
        
        print('+{:-^85}+'.format(''))
        logging.info('+{:-^85}+'.format(''))
        cursor.close()
        return False
    
    print(' -No unmatching balace found')    
    cursor.close()
    return True    



def backup_log():
    file = os.listdir(BACKUP_LOG_DIR)
    # Only the BACKUP_NUMBER most recent backup are kept in memory, by default just 3
    if len(file) > BACKUP_NUMBER-1:
        file.sort()
        os.remove(os.path.join(BACKUP_LOG_DIR, file[0]))
        
    # Performin the backup using cp
    time = datetime.now()    
    subprocess.run([f'sudo', 'cp', f'{LOG_DIR}' ,f'{BACKUP_LOG_DIR}/{str(time.hour)[:2].zfill(2)}-{str(time.minute)[:2].zfill(2)}-{str(time.second)[:2].zfill(2)}.log'])
    print('\n Backup of the log done')
    logging.info('\n Backup of the log done')
    
def backup_db():
    file = os.listdir(BACKUP_DB_DIR)
    # Only the BACKUP_NUMBER most recent backup are kept in memory, by default just 3
    if len(file) > BACKUP_NUMBER -1:
        file.sort()
        os.remove(os.path.join(BACKUP_DB_DIR, file[0]))
        
    # Performin the backup using mysqldump
    time = datetime.now()
    f = open(f'{BACKUP_DB_DIR}/{str(time.hour)[:2].zfill(2)}-{str(time.minute)[:2].zfill(2)}-{str(time.second)[:2].zfill(2)}.sql', 'w')
    with open(os.devnull, 'wb') as devnull:
        subprocess.run(['sudo', 'mysqldump', f'-u{USER}', f'-p{USER_PSW}', 'ctf2'], stdout=f, stderr=devnull)
    print('\n Backup of the database done')
    logging.info('\n Backup of the database done')
    

# This method is used to print the statistics in a table every 'TIME' seconds
def check_consistence():
    global cnx
    os.system('clear')
    cnx = connect()
    print(f'UPDATE TIME: {TIME}s')
    print('{:-^25} {} {:-^25}\n\n'.format('', datetime.now(), ''))
    logging.info(f'UPDATE TIME: {TIME}s')
    logging.info('{:-^25} {} {:-^25}\n\n'.format('', datetime.now(), ''))
    
    print('Checking for negative balance')
    logging.info('Checking for negative balance')
    if all([negative_amount_check(), users_number_check(), transfers_number_check(), matching_balance_check()]):
        # If the database is in a consistence file a dump of the db and of the log is done 
        print('\n The database is in a consistence state, saving a backup of the database and of the log')
        logging.info('\n The database is in a consistence state, saving a backup of the database and of the log')
        backup_log()
        backup_db()
            
    if cnx is not None and cnx.is_connected():
        cnx.close()
    
    threading.Timer(TIME, check_consistence).start()
    

# The only purpose of this methode is to nicely stop the application and its threads after the first CTRL + C
def signal_handler(sig, frame):
    print('\n\nExiting the application. Goodbye')
    os._exit(1)
    
# This function will look at the error log of mysql printing any failed attempt to connect to the database
def check_error_log():
    f = open(f'{MYSQL_ERROR_LOG}', 'r')
    f.seek(0,2)
    while True:
        line = f.readline()
        if not line:
            time.sleep(0.1)
            continue
        if 'Access denied' in line: # if an access denied is found the log is saved
            line = line.split(' ')
            print(f'\n{datetime.now()}: Access attempt to {line[-4]}')
            logging.info(f'\n{datetime.now()}: Access attempt to {line[-4]}')

def main():
    check_log = threading.Thread(target=check_error_log, name='Error_log_checker')
    check_log.start()
    check_consistence()
    

if __name__ == '__main__':
    try:
        os.system(f'sudo rm {BACKUP_DB_DIR }/*')
        os.system(f'sudo rm {BACKUP_LOG_DIR }/*')
    except:
        print('Backup folder empyt, starting the script')
        
    signal.signal(signal.SIGINT, signal_handler)
    main()
