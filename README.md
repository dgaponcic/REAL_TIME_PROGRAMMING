# REAL_TIME_PROGRAMMING
## Task


* Developed a message broker with support for multiple topics. The message broker is a dedicated async TCP server written in elixir. 
The application from app folder(more information in that README), connects to the broker, and publishes messages on the message broker which can be subscribed 
to using a tool like telnet or netcat or some dedicated client.
Used docker-compose.
* For a good software design, messages are represented as structures/classes and not as just maps or strings. I serialize these messages at some point, 
to send them via network.
* Ensures reliable message delivery using Persistent Messages and Durable queues.
* Implemented CDC: Change Data Capture, thus making the publisher the database from app rather than a dedicated actor.
