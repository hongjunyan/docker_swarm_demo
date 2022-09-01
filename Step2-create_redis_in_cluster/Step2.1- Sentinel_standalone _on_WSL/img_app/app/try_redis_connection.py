import time
import redis
from redis.exceptions import TimeoutError
from redis import Sentinel
from redis.sentinel import SlaveNotFoundError, MasterNotFoundError
from datetime import datetime
from loguru import logger
time.sleep(10)

msg = "Connect to sentinel..."
logger.info(msg)

sentinel = Sentinel([('sentinel1', 26379), ('sentinel2', 26379), ('sentinel3', 26379)], socket_timeout=0.1)

msg = f"Success, master: {sentinel.discover_master('mymaster')} slave: {sentinel.discover_slaves('mymaster')}"
logger.info(msg)
hash_number = 0
while True:
    # Set data
    try:
        master = sentinel.master_for('mymaster', socket_timeout=0.1)
        master_host = master.client_info()["laddr"]
        dict_data = {
            f"employee_name{hash_number}": f"Adam Adams{hash_number}",
            "employee_age": 30,
            "position": f"Software Engineer {hash_number}",
        }

        status = master.mset(dict_data)
        msg = f"Save data {status} to: {master_host}, hash_number:{hash_number}"
        logger.info(msg)
        hash_number += 1
    except MasterNotFoundError as e:
        logger.error(e)
    except TimeoutError as e:
        logger.error(f"Timeout when connected to master")
    except Exception as e:
        logger.error(f"Unexcept error in master")
        logger.error(e)
    # Get data
    try:
        slave = sentinel.slave_for('mymaster', socket_timeout=0.1)
        data = slave.mget(f"employee_name{hash_number}", "employee_age", "position", "non_existing")
        slave_host = slave.client_info()["laddr"]
        msg = f"Get data {data} from: {slave_host}"
        logger.info(msg)
    except SlaveNotFoundError as e:
        logger.error(e)
    except TimeoutError as e:
        logger.error(f"Timeout when connected to slave")
    
    except Exception as e:
        logger.error(f"Unexcept error in slave")
        logger.error(e)