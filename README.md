[![Build Status](https://travis-ci.com/BernardoMG/line-server-network.svg?branch=master)](https://travis-ci.com/BernardoMG/line-server-network)

# Line Server Network

This is my solution for the [Line Server Problem](https://salsify.github.io/line-server.html) implemented in Ruby (2.6.5), using Sinatra framework.

1. How to **build** and **run** the application 🚀:

```shell
sh build.sh
sh run.sh
```

2. How to run the tests ✅:

```shell
cd app/
rspec
```

##### Important: Please make sure you have [Docker](https://docs.docker.com/docker-for-mac/install/) running on your local machine.

## Answers to questions

### 1. How does your system work?
At startup the application process the entire text file and creates an in-memory array, where each index represents the byte offset of each line (i.e. [0, 65, ...]). Since, we go through each line, we also save the number of lines of the file, usefull when the client requests a line number that is beyond the end of the file. A Redis server is also launch during boot for cache purposes (check **docker-compose.yml**).

After process the entire text file, the clients can start sending requests and the code flow is the following:

1. Checks if the line is already in cache. 
2. If cached, returns it to the client with a 200 status code.
3. If not, an interactor ([Interactor? What?](https://goiabada.blog/interactors-in-ruby-easy-as-cake-simple-as-pie-33f66de2eb78)) called **LineRetriever** takes place and tries to collect the requested line considering it's byte offset.
4. In the end, if the **LineRetriever** returns the requested line, it's stored in our cache for future requests.

**LineRetriever** can return 3 diferrent responses:

1. 200 status code with the requested line.
2. 413 status code for a line number that is beyond the end of the file with a proper error message.
3. 422 status code for line number 0 ([Why 422 status code?](https://www.bennadel.com/blog/2434-http-status-codes-for-invalid-data-400-vs-422.htm)) with a proper error message.

The application can also return a 500 status code with a proper error message if something happens that is not expected.

### 2. How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file?
The larger the file gets, the slower it starts. This affects mainly the application boot process, i.e. collecting the byte offset of each line. I'd need to perform benchmarks and see if the application has the desired performance. **One of my focus was to gather the most efficient way to perform I/O operations in Ruby.**

A **quick improvement** would be to split the file into smaller chunks and then parallelize the process. I'd use [Sidekiq Pro](https://github.com/mperham/sidekiq) because I've lots of experience with it and it's super efficient.

In this idea, each worker would be responsable for process one chunk and collect the byte offset of each line. Then, each worker would send that information to an Orchestractor (i.e. using for example [RabbitMQ](https://www.rabbitmq.com/) in a pub/sub paradigm) responsable for organizing the data struture with all byte offsets.

In the end, I'd need to find a sweet spot between performance and number of workers (chunks).

### 3. How will your system perform with 100 users? 10000 users? 1000000 users?
- passenger
- deploy env (docker)

### 4. What documentation, websites, papers, etc did you consult in doing this assignment?

### 5. What third-party libraries or other tools does the system use? How did you choose each library or framework you used?

### 6. How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?
- improve cache
- paralelize boot
- another algorithm 

### 7. If you were to critique your code, what would you have to say about it?


https://www.researchgate.net/publication/275543701_An_Efficient_Log_File_Analysis_Algorithm_Using_Binary-based_Data_Structure
