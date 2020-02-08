# Creating REST Services with InterSystems IRIS

## How to run this demo

To run this demo, you need Docker installed on your PC. Then you can just run:

```bash
docker run -it --name iris --init --rm -p 52773:52773 amirsamary/developing-with-containers:irisdb-version-1.7.0
```

## How to build this demo on my PC?

Ideally, you should run the ./build.sh script which will build the image locally on your PC using the current version number inside the file ./VERSION to tag it.

But you can also build it directly with the docker build command and tag it with a name of your preference:

```bash
docker build -t amirsamary/developing-with-containers:irisdb-version-1.7.0 ./image-iris
```

## How to look at the source code and change it?

The source code for the image is on folder ./image-iris. You can use Visual Studio Code to edit it. What I recommend is to:
* Install Visual Studio Code
* Install ObjectScript plugin
* Start the container using the ./run.sh script or the **docker run** command above.
* Open folder ./image-iris on VSCode. This folder has a subfolder called .vscode that has a settings.json file with configurations for the **ObjectScript plugin** to connect to the IRIS container.
* Now you can edit the files under the **src** folder and save them. They will be automatically compiled into the image.

## Examples of REST Calls

Once the container is up and running, you will be able to use a REST Client such as Postman to test the end points bellow.

Before trying to call them:
* Configure basic authentication with username **SuperUser** and password **sys**.
* Make sure your Content-Type header is set to **application/json**

### Getting a list of destinations

| Method    | URL |
| --------- | :--- |
| GET       | http://localhost:52773/csp/myapp/rest/destinations |

### Getting a list of reservations

| Method    | URL |
| --------- | :--- |
| GET       | http://localhost:52773/csp/myapp/rest/reservations |

### Creating a reservation

| Method    | URL |
| --------- | :--- |
| POST       | http://localhost:52773/csp/myapp/rest/reservations |


*Body:*

```JSON
{
    "customer": "John Smith",
    "startLocation": "South Africa",
    "destination": "Boston",
    "startDate": "2020-02-01",
    "endDate": "2020-02-10"
}
```

The new resource name is returned at the *Location* header:

**Location:** /csp/myapp/rest/reservations/7

### Partial Update of a Reservation

| Method    | URL |
| --------- | :--- |
| PATH       | http://localhost:52773/csp/myapp/rest/reservations/id |

*Body:*

```JSON
{
    "destination": "Brazil"
}
```
The body can mention one or all of the propeties. Only the mentioned properties will be updated. The others, will be left with the previous value.

### Full Update of a Reservation

| Method    | URL |
| :---------: | :--- |
| PUT       | http://localhost:52773/csp/myapp/rest/reservations/id |

*Body:*

```JSON
{
    "customer": "Angelo",
    "startLocation": "Rome",
    "destination": "France",
    "startDate": "2019-02-01",
    "endDate": "2019-02-10"
}
```
All properties of the document will be updated. Properties that are not present will be set to null. If the property is required, the transaction will return a 400 Bad Request error.

### Deleting a resource

| Method    | URL |
| :---------: | :--- |
| DELETE       | http://localhost:52773/csp/myapp/rest/reservations/id |
