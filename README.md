# Best Practices with InterSystems IRIS REST Services and Container Examples

This repository holds the source code used on two of my presentations:
- [REST API design - REST at Ease](https://raw.githubusercontent.com/amirsamary/developing-with-containers/master/presentations/REST_API_design_with_IRIS.pdf)
- [The Value Of Developing With Containers](https://raw.githubusercontent.com/amirsamary/developing-with-containers/master/presentations/Value_Of_Containers_with_IRIS.pdf)
- [Machine Learning - An InterSystems Perspective and Demonstration](https://raw.githubusercontent.com/amirsamary/developing-with-containers/master/presentations/Machine_Learning_An_InterSystems_Perspective_and_Demonstration.pdf)

The first presentation was inspired on a presentation of a similar name, given by Michael Smart. Although this repository containes everything you need, Michael's original source code can be found [here](https://github.com/intersystems/rest-and-relaxation). Thank you Michael!

The second presentation was inspired on a presentation of the same name, given by Joe Carrol. Thank you Joe! I have updated just a little bit and added some new stuff.

The third presentation ends with two demos:
- [The Readmission Demo](https://github.com/intersystems-community/irisdemo-demo-readmission) - That uses Spark to build a model and PMML to operationalize it
- Integrated ML Demo - That is going to be released on IRIS 2020.2

# REST API design - REST at Ease

Follow the instructions bellow to start the IRIS container with the source code. 

## How to run this demo

To run this demo, you need Docker installed on your PC. Then you can just run:

```bash
docker run -it --name iris --init --rm -p 52773:52773 amirsamary/developing-with-containers:irisdb-version-1.8.0
```

## How to build this demo on my PC?

Ideally, you should run the ./build.sh script which will build the image locally on your PC using the current version number inside the file ./VERSION to tag it.

But you can also build it directly with the docker build command and tag it with a name of your preference:

```bash
docker build -t amirsamary/developing-with-containers:irisdb-version-1.8.0 ./image-iris
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
| GET       | http://localhost:52773/csp/myapp/rest/reservations/v3 |

### Creating a reservation

| Method    | URL |
| --------- | :--- |
| POST       | http://localhost:52773/csp/myapp/rest/reservations/v3 |


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

**Location:** /csp/myapp/rest/reservations/v3/7

### Partial Update of a Reservation

| Method    | URL |
| --------- | :--- |
| PATH       | http://localhost:52773/csp/myapp/rest/reservations/v3/id |

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
| PUT       | http://localhost:52773/csp/myapp/rest/reservations/v3/id |

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
| DELETE       | http://localhost:52773/csp/myapp/rest/reservations/v3/id |

# The Value Of Developing With Containers

This repository also contains some of the examples I used on this presentation:
* durablerun.sh - Starts IRIS Community with Durable %SYS
* durablerun2.sh - Starts IRIS Community with Durable %SYS and merge CPF file for configuring global buffers and routine buffers
* durablerun3.sh - Starts IRIS Community with Durable %SYS, merge CPF and a predefined system password
* durablerun4.sh - Starts IRIS with Durable %SYS, merge CPF, a predefined system password and a license key
* durablerun5.sh - Starts IRIS Community with our REST application on a Durable %SYS, configured with a merge CPF and a predefined system password!

