# Automated Daily Spotify Streaming Chart – An End-to-End Data Engineering Project with Azure Synapse Analytics and Power BI
-----------------------------------------------------
## Table of contents:
### 1. Project Rationale
### 2. Thought Process
### 3. Project Architecture
#### 3.1. Web Scraping on Python
#### 3.2. 
#### 3.3. Pipeline Construction on Azure Synapse Analytics
#### 3.4. Serverless SQL Database to Power BI
-----------------------------------------------------

## 1. Project Rationale
For a long time, I’ve been in fandoms of many big artists. And a common characteristic of these group is that they are obsessed with numbers and charts. So, I just thought that why I do not create an automatically daily updated streams report, which is a way to expose myself to the area of data engineering, but is still what I am interested in.

## 2. Thought Process
During the implementation, I had so many ideas of how I should have done it. Here’s how I changed my direction from time to time:
- First, I planned to do the scraping on my local machine (with scheduling done with cronjob in terminal because I use MacOS), and then save it into MySQL Server database, then integrate it with cloud. Next, build the pipeline on Microsoft Azure, with some services like Data Factory for pipeline, Databricks for data transformation and Synapse Analytics for data loading. At this time, I was not sure if I could do the scraping directly on cloud service or not, because scraping from highly secured web sometimes causes trouble. But a big downside of running the scraping on local machine, even with cronjob, is that it requires my laptop to be opened at the scheduled time. So, I directed myself into another way.
- In the second idea, so instead of scraping in my local machine, I did it on an Azure Virtual Machine with an Azure SQL database, with scheduling done with Task Scheduler supported on Window. And I want to check the database from my local machine, because connecting to a virtual machine takes a lot of time, and it’s slow. But this time, I really struggled with connecting with SQL server, which is because I use MacOS, a system that only supports MySQL Server, not SQL Server. And again, my plan was changed.
- This time, I tried to run the code on Synapse, and luckily it worked. After extracted and transformed, all data files were saved in Azure Storage, which were later moved into serverless SQL database. I also included an intermediate step called ‘Moving files’ because during daily update, there were some errors in the ‘Daily Update’ notebook. So basically, I saved the files to another container, then if the notebook was successfully run, all the files were then moved back to the main one. This leaves the main datasets intact when errors happen. Lastly, I connected Power BI with the Synapse serverless SQL database to build the dashboard which can be scheduled for refresh when new data come into the database. And this is the final pipeline of my project.

-----------------------------------------------------
## 3. Project Architecture
### 3.1. Web Scraping on Python
