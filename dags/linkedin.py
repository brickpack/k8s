from datetime import timedelta
from airflow import DAG
from airflow.providers.http.sensors.http import HttpSensor
from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from airflow.utils.dates import days_ago
import json


def get_rapidapi_key():
    connection = BaseHook.get_connection('rapidapi_linkedin')
    return connection.extra_dejson.get('headers').get('x-rapidapi-key')

# def process_data(ti):
#     data = ti.xcom_pull(task_ids='call_linkedin_api')
#     # Process the data here
#     processed_data = some_processing_function(data)
#     # Continue with processed_data
#     ti.xcom_push(key='processed_data', value=processed_data)

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'linkedin_api',
    default_args=default_args,
    description='A DAG to call LinkedIn API via RapidAPI and process the data',
    schedule_interval='@daily',
    start_date=days_ago(1),
    catchup=False,
)

# # Check if the API is available
# check_api = HttpSensor(
#     task_id='check_api',
#     http_conn_id='rapidapi_linkedin',
#     endpoint='/v2/me',
#     response_check=lambda response: response.status_code == 200,
#     poke_interval=5,
#     timeout=20,
#     dag=dag,
# )

# Call the LinkedIn API via RapidAPI
call_linkedin_api = SimpleHttpOperator(
    task_id='call_linkedin_api',
    http_conn_id='rapidapi_linkedin',
    endpoint='/v2/me',
    method='GET',
    headers={
        "x-rapidapi-key": get_rapidapi_key(),
        "x-rapidapi-host": "linkedin-data-api.p.rapidapi.com"
    },
    params={"username":"dave-birkbeck"},
    response_filter=lambda response: json.loads(response.text),
    log_response=True,
    dag=dag,
)

# # Process the data
# process_data_task = PythonOperator(
#     task_id='process_data',
#     python_callable=process_data,
#     dag=dag,
# )

# Define the task dependencies
# check_api >> call_linkedin_api >> process_data_task

call_linkedin_api