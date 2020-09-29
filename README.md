# AgileEngine Code Challenge
----------
This is the source code to solve the AgileEngine code challenge *Image gallery Search*.

## Resolution
----------
I tried to solve the challenge with two differents approaches, first I tried to solve it using a Docker container with Apache and mod_perl enabled, also I added a second approach using the framework **Mojolicious**. I completed this two ways because on the challenge said that you wanted to see my own code, so I thought that maybe the framework was solving things for me that you wanted to evaluate.

In the challenge description, there was a couple of items that I didn't have clear but I didn't ask.
First in item #6, it said:

*The app should fetch the entire load of images information upon initialization and perform cache reload once in a defined (configurable) period of time.*

But I couldn't find any service that returns the entire collection of images, the service **/images** by default It returns only the first page and allows 20 as a max limit value, so this was a problem because I couldn't paginate the entire collection of images, anyway I solved this by getting 20 images and taking a smaller amount of items per page for the pagination in my application.

Another item I didn't understood entirely was #7, it said:

*The app should provide a new endpoint: GET /search/${searchTerm}, that will return all the photos with any of the meta fields (author, camera, tags, etc) matching the search term. The info should be fetched from the local cache, not the external API.*

In this case, I couldn't find a service that returns a collection of images with their attributes so I can save them in the local cache. All the services that returns a collection of images they only had the attribute *cropped_picture* and *id*.
A workaround I found was to add in my app a configurable boolean attribute called **load_extend**, if this attribute is set to 1, then the app will fetch the first page of images and for each image it will fetch all the attributes with the **/images/{id} service**. It's a very slow and not optimal solution because it triggers a lot of requests, but that service was the only one that returned the images attributes.

Finally the item #10:

*Target completion time is about 2 hours. **We would rather see what you were able to do in 2 hours than a full-blown algorithm** you’ve spent days implementing. Note that in addition to quality, time used is also factored into scoring the task.*

Here I didn't understand if you wanted to see what I could finished about the application in two hours or if you didn't want me to spend more than two hours working on the search algorithm.

Just in case, I added in the repository a branch called **first_2_hours_work** that has what I could complete with the first approach in two hours. This two hours are from the moment I had the environment correctly set and I could start working on the challenge. The entire time I spent to solve the challenge with this approach was around 6 hours.
For the second approach with the framework I don't have a branch but in two hours I could solve the services **/images** and **/images/{id}** but both without cache. I spent around 5 hours to solve the challenge.

## How to build and run
### Requirements
- Docker engine
- Docker-compose
- Internet connection

### Build
#### First approach with Apache and mod perl:
1. Clone the repo
2. Run the command: `docker-compose -f compose.yml build`
3. Run the command: `docker-compose -f compose.yml up`

Once the last step is completed withot problems the app will be available in: **http://localhost:8080/images, http://localhost:8080/images/${id} and http://localhost:8080/search/${searchTerm}**.

The configurations are available on the **config.json** file inside the *html* folder and you can config:
- The *cache duration*. Posible values are: 1s, 5s, 30s, <n>s or 1m, 5m, <n>m or every valid duration value of the CHI perl library.
- The *api key*.
- The *load_extend* attribute I mentioned before.

#### Second approach with Mojolicious:
1. Clone the repo
2. Change the compose.yml file, uncomment the line: `command: perl /tmp/myapp.pl daemon` and comment the line: `tty: true`
3. Run the command: `docker-compose -f compose.yml build`
4. Run the command: `docker-compose -f compose.yml up`

Once the last step is completed withot problems the app will be available in: **http://localhost:3000/images, http://localhost:3000/images/${id} and http://localhost:3000/search/${searchTerm}**.

The configurations are available on the **myapp.conf** file inside the *mojolicious* folder and you can config same attributes as the first approach.
