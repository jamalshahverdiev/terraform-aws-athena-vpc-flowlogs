#### Enter some name for the flow logs(https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html ), select All in the Filter, as the destination choose the S3 and paste ARN: arn:aws:s3:::s3-bucket-for-flow-logs of our S3 bucket, set 10 minutes of the aggregation interval, do partition of the logs for each 24 hour and choose log record format to Custom as the following

```bash
${version} ${account-id} ${instance-id} ${interface-id} ${pkt-srcaddr} ${srcaddr} ${srcport} ${pkt-dstaddr} ${dstaddr} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status} ${az-id}
```

#### After some time go to the S3 bucket look at the folder structure which created there:

#### Then open Athena(https://docs.aws.amazon.com/athena/latest/ug/vpc-flow-logs.html) (Query Data in S3 using SQL) service in AWS and define place where will be saved all results of our queries.

In my case is: `s3://s3-bucket-name/jamal.shahverdiyev`

#### Create table for the log structure inside of database which we have defined in `flowlog_gb_glue_name` variable of `vars.tf` file. Structure of the fields must be as we defined in the flow logs when we created. In the location of the S3 please use your own Account ID(Red deleted space) of AWS:

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS flowloggluedb.vpc_flow_logs (
        version int,
        account string,
        instanceid string,
        interfaceid string,
        pktsrcaddr string,
        sourceaddress string,
        sourceport int,
        pktdstaddr string,
        destinationaddress string,
        destinationport int,
        protocol int,
        numpackets int,
        numbytes bigint,
        starttime int,
        endtime int,
        action string,
        logstatus string,
	    azid string
) PARTITIONED BY (
    dt string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ' ' LOCATION 's3://s3-bucket-name/AWSLogs/write-your-aws-account-id/vpcflowlogs/us-east-1/' TBLPROPERTIES ("skip.header.line.count"="1");
```

#### Create partition to quick search:

```sql
ALTER TABLE flowloggluedb.vpc_flow_logs
ADD PARTITION (dt='2021-12-01')
location 's3://s3-bucket-name/AWSLogs/write-your-aws-account-id/vpcflowlogs/us-east-1/2021/12/01';
```

#### Query to get traffic in Megabytes from EKS worker nodes

```sql
SELECT sourceaddress AS SOURCE_ADDRESS, SUM(numbytes)/1024/1024  AS TOTAL_IN_MB
FROM flowloggluedb.vpc_flow_logs
WHERE action = 'ACCEPT' AND sourceaddress in (
'10.10.10.151', '10.10.10.174', '10.10.10.229', '10.10.10.40') GROUP BY sourceaddress;
```

Links:
https://aws.amazon.com/blogs/networking-and-content-delivery/using-vpc-flow-logs-to-capture-and-query-eks-network-communications/
