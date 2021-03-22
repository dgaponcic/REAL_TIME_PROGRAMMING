# REAL_TIME_PROGRAMMING

## System Schema
![alt text](https://github.com/dgaponcic/REAL_TIME_PROGRAMMING/blob/main/system_schema.png)

## Task
The task is as follows:
* You will have to read 2 SSE streams of actual Twitter API tweets in JSON format. For Elixir use this project to read SSE: https://github.com/cwc/eventsource_ex
* The streams are available from a Docker container, alexburlacu/rtp-server:faf18x, on port 4000
* To make things interesting, the rate of messages varies by up to an order of magnitude, from 100s to 1000s.
* Then, you route the messages to a group of workers (Sentiment and Engagement) that need to be autoscaled, you will need to scale up the workers (have more) when the rate is high, and less actors when the rate is low
* Route/load balance messages among worker actors using least connected routing.
* Occasionally you will receive "kill messages", on which you have to crash the workers.
* To continue running the system you will have to have a supervisor/restart policy for the workers.
* The worker actors also must have a random sleep, in the range of 50ms to 500ms, normally distributed. This is necessary to make the system behave more like a real one + give the router/load balancer a bit of a hard time.

* Sentiment score per tweet, calculate score using sentiments route on the server
* Engagement Ratio per Tweet. Notice that some tweets are actually retweets and contain a special field retweet_status​ . You will have to extract it and treat it as a separate tweet. The Engagement Ratio will be computed as: (#favorites + #retweets) / #followers​.
* Send to a dedicated aggregator actor the sentiment score, the engagement ratio, and the original tweet to be merged together.
* Finally, you will have to load everything into a database, for example Mongo, and given that writing messages one by one is not efficient, you will have to implement a backpressure mechanism called reactive pull. For this, implement a Monitor, that will monitor the time spend writing the batch to the database and adapt the size batch. 
* Implement an actor to check the health state of sink and buffer the records if the sink is down. 
* To make things interesting, you will have to split the tweet JSON into users and tweets and keep them in separate collections/tables in the DB.
Of course, don't forget about using actors and supervisors for your system to keep it running.

## Implementation
Optional tasks:
* Implemented count min sketch and used it to find top 10 hashtags(updated every second)
* Least Connected routing
* Reactive Pull
* Resumable/Pauseable Sink

## Run
start docker image on port 4000
```
mix deps.get
mix run --no-halt
```
## Demo
TODO
