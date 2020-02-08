# Creating REST Services with InterSystems IRIS

## Examples of REST Calls

### Getting a list of destinations

| Method:   | URL |
| --------- | --- |
| GET       | http://localhost:52773/csp/myapp/rest/destinations |

### Getting a list of reservations

| Method:   | URL |
| --------- | --- |
| GET       | http://localhost:52773/csp/myapp/rest/reservations |

### Creating a reservation

| Method:   | URL |
| --------- | --- |
| POST       | http://localhost:52773/csp/myapp/rest/reservations |
| --------- | --- |
| Body      | ```json
{
    "customer": "Amir",
    "startLocation": "Brazil",
    "destination": "Boston",
    "startDate": "2018-02-01",
    "endDate": "2018-02-10"
}
```|
