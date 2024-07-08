# Automated Daily Spotify Streaming Chart – An End-to-End Data Engineering Project with Azure Synapse Analytics and Power BI
-----------------------------------------------------

## Project Rationale
For a long time, I’ve been in fandoms of many big artists. And a common characteristic of these group is that they are obsessed with numbers and charts. So, I just thought that why I do not create an automatically daily updated streams report, which is a way to expose myself to the area of data engineering, but is still what I am interested in.

## Tools Used
- <b>Programming Language</b>: Python (scraping and API requesting), SQL (data integration and database inspection).
- <b>ETL tool</b>: Azure Synapse Analytics
- <b>Report tool</b>: Power BI

## Thought Process
During the implementation, I had so many ideas of how I should have done it. Here’s how I changed my direction from time to time:
- First, I planned to do the scraping on my local machine (with scheduling done with cronjob in terminal because I use MacOS), and then save it into MySQL Server database, then integrate it with cloud. Next, build the pipeline on Microsoft Azure, with some services like Data Factory for pipeline, Databricks for data transformation and Synapse Analytics for data loading. At this time, I was not sure if I could do the scraping directly on cloud service or not, because scraping from highly secured web sometimes causes trouble. But a big downside of running the scraping on local machine, even with cronjob, is that it requires my laptop to be opened at the scheduled time. So, I directed myself into another way.
- In the second idea, so instead of scraping in my local machine, I did it on an Azure Virtual Machine with an Azure SQL database, with scheduling done with Task Scheduler supported on Window. And I want to check the database from my local machine, because connecting to a virtual machine takes a lot of time, and it’s slow. But this time, I really struggled with connecting with SQL server, which is because I use MacOS, a system that only supports MySQL Server, not SQL Server. And again, my plan was changed.
- This time, I tried to run the code on Synapse, and luckily it worked. After extracted and transformed, all data files were saved in Azure Storage, which were later moved into serverless SQL database. I also included an intermediate step called ‘Moving files’ because during daily update, there were some errors in the ‘Daily Update’ notebook. So basically, I saved the files to another container, then if the notebook was successfully run, all the files were then moved back to the main one. This leaves the main datasets intact when errors happen. Lastly, I connected Power BI with the Synapse serverless SQL database to build the dashboard which can be scheduled for refresh when new data come into the database. And this is the final pipeline of my project.

-----------------------------------------------------
## Project Architecture
### Extract-Transform-Load Pipeline

#### Web Scraping on Python
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/8b0b6ac7-e0de-4d0b-8f1e-48f1f878e6bf)

The stream data is scraped from kworb.net, which is a public, but not authorized, source. Other information about artists, tracks and albums are extracted from Spotify Web API. Due to the limited number of API requests, I split my codes into two, one is for the initial extract, another is for daily update. Especially, I added a notebook which will send a notification if my daily updating fails. It can not be guaranteed that everything will run smoothly. I have faced so so so so many errors in my pipeline. Everyday waking up, reading my email written ‘Scraping failed’, I have to immediately open my laptop and debug. That’s why I invented a notebook and a small pipeline called ‘Intervention’.

#### Data Storing in Storage Account
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/69851c37-6c8e-4027-95c3-e2ae0ad46dbe)

The data after being scrapes is stored in a container in Azure Storage Account. As I explained, to avoid errors during running notbook affecting the database, the files are initially stored in another container then later moved to the main one. Data files are stored in parquet format instead of csv, because some data values contain commas, which leads to false reading of the database.

![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/8abc3714-9a40-446d-a3a7-a2c29c54f119)


#### Data Integrating to Serverless SQL Database
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/8dc9bd5c-71ef-4208-bcca-59fce11b692d)
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/f4d5a035-13b6-4b73-8be8-d9b7395e9d99)

The datasets are then integrated to serverless SQL database through a dynamic process. First, all file names are extracted through "Get Metadata", by getting all child items of the container. Then, all their names are brought into the for loop with a "Stored Procedure" which is a SQL script to Create or Alter tables in the SQL database.

![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/642784d7-8ead-4820-9abf-d5a459719c90)
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/659bd066-2a6a-4aec-b1d9-4b88d0062f87)

#### Trigger Setting
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/31357c69-654b-491f-a51c-51613cb569b3)

After be built, the pipeline was tested and scheduled daily. Any errors occurring would be debugged immediately to ensure that the database is not affected significantly.

### Serverless SQL Database to Power BI
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/8230616e-ba98-4ffc-8e5c-6cbf33e60fba)
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/18870228-c61d-4d10-b3ff-e4c209a6ddc4)
![image](https://github.com/dungda411/Automated-Daily-Spotify-Streaming-Chart-An-End-to-End-Data-Engineering-Project-with-Azure-Synapse-/assets/157843205/1ecb01dd-124e-4a5b-9ec0-b21df59a1edc)

Power Bi is then connected with Synapse serverless SQL database via an endpoint. If the database is affected, the Power BI can also be changed by refreshing. After the dashboard is completed and published, the semantic model is scheduled daily (after database updating 1 hour, allowing the update is fully run).

-----------------------------------------------------
## Key Challenges and Mitigation
1. <b>Errors in web scraping and API requesting</b>: During the extraction of data, I faced many errors in my codes. Because this is a time series dataset, some errors does not happens today, but tomorrow, or maybe next week. To mitigate this, I predicted every situations that might happen, and used "try - except" to notify the errors but do not interrupt the running.
2. <b>Main dataset badly affected by false coding</b>: The biggest, yet seeming small, challenge that I met was that, when saving 12 files into the container, it stucked at a file in between, which means that some files had been stored, and the remaining were not. This made me have to re-extract my data many times. And as stated, I solved this by including an intermediate step called "Moving files" after the scraping.
3. <b>Connection</b>: In my opinion, this is a challenge that everyone doing pipeline is facing. I had it when trying to connect Synapse to serverless SQL databse (to Create or Alter tables), and connect Power BI to the database, which I already overcome by minding carefully the configuration of each service, including authentications, networking and firewall settings.
4. <b>Other challnges related to previous ideas</b>: In the path of reaching my final process, I faced many technical issues, from tiny to huge. Although not able to address those problem, it was great opportunity for me to reach the unknown.
