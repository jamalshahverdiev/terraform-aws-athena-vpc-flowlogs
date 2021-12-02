#!/usr/bin/env bash

s3_bucket_name='vpc-flow-logs-bucket-to-store-queries'
work_group_name='WorkGroupForQueries'
collect_wg_names=$(aws athena list-work-groups | jq -r '.WorkGroups[].Name')
glue_db_name='flowloggluedb'
sleep_count='10'
ip_addresses_to_iterate='''
10.11.12.13
10.11.12.59
10.11.12.126
10.11.12.57
'''
export AWS_PROFILE='AWS_PROFILE_NAME'

echo ${collect_wg_names} | grep --quiet "${work_group_name}"
if [ $? = 1 ]; then
    aws athena create-work-group \
      --name ${work_group_name} \
      --configuration ResultConfiguration={OutputLocation="s3://${s3_bucket_name}/awscli.queries/${work_group_name}"},EnforceWorkGroupConfiguration="true",PublishCloudWatchMetricsEnabled="true" \
      --description "Workgroup for AWS CLI network analysts" \
      --tags Key=Env,Value=Dev Key=Location,Value=USA Key=Project,Value="AWSCLI"    
fi

for ip in ${ip_addresses_to_iterate}; do
    result_in_json=$(aws athena start-query-execution \
      --query-string "SELECT sourceaddress AS SOURCE_ADDRESS, SUM(numbytes)/1024/1024/1024  AS TOTAL_IN_GB \
      FROM default.vpc_flow_logs WHERE action = 'ACCEPT' AND sourceaddress in ('${ip}') GROUP BY sourceaddress;" \
      --work-group "IguazioWorkGroup" --query-execution-context Database=default,Catalog=AwsDataCatalog)
    query_result_file_name=$(echo ${result_in_json} | jq -r .QueryExecutionId).csv && sleep ${sleep_count}
    output=$(aws s3 cp s3://${s3_bucket_name}/awscli.queries/${work_group_name}/${query_result_file_name} .)
    echo '======================  Query Result  ======================'
    cat ${query_result_file_name} && rm ${query_result_file_name}
done

# Delete workgroup
# aws athena delete-work-group --work-group ${work_group_name} --recursive-delete-option