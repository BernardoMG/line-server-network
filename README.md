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
At startup the application process the entire text file and creates an in-memory array, where each index represents the byte offset of each line (i.e. [0, 65, ...]). Since, we go through each line, we also save the number of lines of the file to validate if the requested line is beyond the end of the file. A Redis server is also launch during boot for cache purposes (check **docker-compose.yml**).

After process the entire text file, the clients can start sending requests and the code flow is the following:

1. Checks if the line is already in cache. 
2. If cached, returns it to the client with a 200 status code.
3. If not, an interactor ([Interactor? What?](https://goiabada.blog/interactors-in-ruby-easy-as-cake-simple-as-pie-33f66de2eb78)) called **LineRetriever** takes place and tries to collect the requested line considering it's byte offset.
4. In the end, if the application is able to return the requested line, it'll store it in our cache for future requests.

**LineRetriever** can return 3 diferrent responses:

1. 200 status code with the requested line.
2. 413 status code for a line number that is beyond the end of the file with a proper error message.
3. 422 status code for line number 0 ([Why 422 status code?](https://www.bennadel.com/blog/2434-http-status-codes-for-invalid-data-400-vs-422.htm)) with a proper error message.

The application can also return a 500 status code with a proper error message if something happens that is not expected.

### 2. How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file?
The larger the file gets, the slower it starts 🚨. This affects mainly the application boot process, i.e. collecting the byte offset of each line. I'd need to perform benchmarks and see if the application has the desired performance. **One of my focus was to gather the most efficient way to perform I/O operations in Ruby.**

A **quick improvement** would be to split the file into smaller chunks and then parallelize the process. I'd use [Sidekiq Pro](https://github.com/mperham/sidekiq) because I've lots of experience with it and it's super efficient.

In this idea, each worker would be responsable for process one chunk and collect the byte offset of each line. Then, each worker would send that information to an Orchestractor (i.e. using for example [RabbitMQ](https://www.rabbitmq.com/) in a pub/sub paradigm) responsable for organizing the data struture with all byte offsets.

In the end, I'd need to find a sweet spot between performance and number of workers (chunks).

#### Note: I didn't implement this improvement due to time constraints.

### 3. How will your system perform with 100 users? 10000 users? 1000000 users?
For this challenge and considering that it runs on development environment, I chose [Puma](https://github.com/puma/puma) which is the default server of Sinatra framework. As requested, the server would need to support multiple simultaneous clients, so I set Puma with 2 workers and 5 threads. However, for a production environment I'd choose Passenger because it's more robust and it'd provide the desired performance when dealing with heavy load and multiple concorrent requests.

In addition, I provided a Dockerfile which means that we can easily deploy the application in any cloud solution with horizontaly scaling. So, we'd choose the number of containers that we want to launch and configure an auto-scaler especially useful for peek hours (lots of requests/users). 


### 4. What documentation, websites, papers, etc did you consult in doing this assignment?
- [Ruby Docs](https://ruby-doc.org/core-2.6.5/)
- [Puma Gem Docs](https://github.com/puma/puma)
- [Redis Gem Docs](https://github.com/redis/redis-rb)
- [Sinatra Docs](http://sinatrarb.com/)
- I/O operations in Ruby:
  - [Under the Hood: “Slurping” and Streaming Files in Ruby](https://blog.appsignal.com/2018/07/10/ruby-magic-slurping-and-streaming-files.html)
  - [Parsing large log files with ruby](http://smyck.net/2011/02/12/parsing-large-logfiles-with-ruby/)
  - [Optimal way of processing large files in Ruby](https://felipeelias.github.io/ruby/2017/01/02/fast-file-processing-ruby.html)
  - [HowTo: Working efficiently with large files in Ruby](https://tjay.dev/howto-working-efficiently-with-large-files-in-ruby/)
  - [Searching Algorithms](https://www.geeksforgeeks.org/searching-algorithms/)
- Searching Algorithms
  - [An Efficient Log File Analysis Algorithm Using Binary-based Data Structure](https://www.researchgate.net/publication/275543701_An_Efficient_Log_File_Analysis_Algorithm_Using_Binary-based_Data_Structure)
  - [Searching Algorithms](https://www.geeksforgeeks.org/searching-algorithms/)
- Several Stackoverflow threads about I/O operations in Ruby


### 5. What third-party libraries or other tools does the system use? How did you choose each library or framework you used?
So, I used **Sinatra** framework with **Puma** and **Redis** to handle cache. For debug purposes, I usually use **[byebug](https://github.com/deivid-rodriguez/byebug)** and for tests I used **[Rspec](https://rspec.info/)**.  

I chose Sinatra framework because it's a very lightweight framework and even though I don't have much experience with it and always wanted to try it and explore a little more. So, I thought it would be the perfect opportunity. The alternative would be to use Rails in API mode.


### 6. How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?
I spend about 6h on this challenge mainly doing lots of planning and research around I/O operations in Ruby and, out-of-the-box solutions and algorithms to read a big text/log file.

If I had unlimited time to spend on this challenge I would (by order):

1. Parallelize the byte offset read process as described in my answer to question nr 2.
2. Implement a different version of the challenge using 

3. Improve cache by creating a GC to delete keys that 
4. Increase test coverage to 100%.

### 7. If you were to critique your code, what would you have to say about it?
Since I don't have much experience with Sinatra framework probably the files/folders directory is not the best. Also, I couldn't add tests for the "controller" file using a library called [Rack Test](https://github.com/rack/rack-test) because 

- sinatra estructure
- controller tests (rack test)
- Code well encapsulated 
- Several unit tests
- Easy to read and understand
- Docker and travis