

# PrestoSQL Docker Quickstart (with no Hadoop)  
  
## What is it?  
  
This docker image allows you to quickly play with PrestoSQL. It comes pre-bundled with MinIO. There is absolutely no running Hadoop component in it. It is perfect for local development when you have a bunch of data in CSV/ORC format and you just want to query it.  
  
Some say that it is the next best thing to sourdough bread.  
  
## How do I launch the container?  
Simply run command `docker run -p 8080:8080 -p 9000:9000 -it --name presto-local gauravphoenix/presto-local-no-hadoop:latest`  
  
Make sure that your machine is not running any process on port 8080 and 9000. Presto is exposed on port 8080 and MinIO on port 9000  

To exit the container, press control/CMD-C
  
## Great, how do I interact with it?  
Download the Presto CLI from [here](https://prestosql.io/docs/current/installation/cli.html) and run command `java -jar presto-cli-<version>-executable.jar --catalog rabbithole`. You should get a `presto>` prompt. If you don't, this means that the container is not running. Note that the catalog name `rabbithole.` This catalog (backed by Hive connector) comes pre-bundled with the image. You can find its configuration under `/presto-server/etc/catalog/rabbithole.properties`file in the container.  
  
Now let's create a schema using the command `CREATE SCHEMA default;` and then use it via running command `use default;`  
  
## Show me the data.  
Sure. Let's create an external table via command `create table baz (c1 varchar, c2 varchar) WITH (external_location='s3a://csvdata/',format = 'csv');`  
and query it via `select * from baz;`  

Following screenshot shows the command sequence we have used since we got the Presto CLI shell- 

![example shell](https://github.com/gauravphoenix/presto-local-no-hadoop/raw/master/shell.png)


  
## Wait, is there really no Hadoop involved?  
Yes and no. No Because we are not running any Zookeeper, data node etc. Yes because we are using the hive connector. The Prestos' hive connector uses the Hive Metastore but does not use it for any query execution. Notice that in `rabbithole.properties`file we have specified following two configuration directives which make Presto use s3 backed hive metastore-  
```  
hive.metastore=file  
hive.metastore.catalog.dir=s3://catalog/  
```  
  
## How do I interact with data files being queried by Presto?  
There are two ways.  
  
1) Using web interface of MinIO. Simply go to http://localhost:9000 with username `minioadmin` and password `minioadmin` and you will find a bucket named `csvdata`. You can download `data.csv` file from there, modify it and upload it back and re-query using Presto CLI.  
  
2) You can also use AWS CLI. Simply create a profile named mio under `~/.aws/config`. Simply append `[profile mio]`. Now go to `~/.aws/credentials` file and put these credentials there-  
	```  
	[mio]  
	aws_access_key_id = minioadmin  
	aws_secret_access_key = minioadmin  
	```  
	And that's pretty much it. You can use run AWS CLI and query the bucket inside the docker container e.g. `aws --profile mio --endpoint-url http://localhost:9000 s3 ls s3://csvdata/`  
  
  
## How closely it resembles the actual production setup?  
  
The major difference is that we are not using a real Hive metastore here. In production, you would want to use something like [AWS Glue](https://aws.amazon.com/glue/) or a real Apache Hive Metastore.
