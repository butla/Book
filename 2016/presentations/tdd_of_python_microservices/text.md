# TDD of Python microservices - Michał Bultrowicz

## Abstract
To have a successful microservice-based project you might want to start testing early on,
shorten the engineering cycles, and provide a more sane workplace for the developers.
Test-driven development (TDD) allows you to have that.

Except for the stalwart unit tests, proper TDD also requires functional tests.
This article shows how to implement those tests (using the
[Mountepy] (https://github.com/butla/mountepy) library I made, Pytest and Docker),
how to enforce TDD (using multi-process code coverage) and good code style (with automated
Pylint checks) within a team.

Furthermore, contract tests based on Swagger interface definitions are introduced as a safeguard
of the microservices' interoperability.

The focus is on services communicating through HTTP, but some general principles will also apply to
all web or network services.


## Service tests
### Their place in TDD
To have TDD and thus a maintainable microservice project we need tests that can validate
the entirety of a single application - the "service tests".
This term is used in "Building Microservices", but Harry Percival calls them (although in the
context of traditional, monolithic web applications) "functional tests" in
"Test-Driven Development with Python".
Those functional tests are essential for implementing the "real TDD", that is the "double loop"
or "outside-in" TDD (shown on diagram below).

![](images/tdd_cycle.png "TDD cycle")

This image (taken from Percival's book) succintly explains the test-driven development process.

Adding each new application feature should start with a functional (service) test.
This kind of verification is necessary to check if units of code work together as planned.
It's important to remember that as service tests take longer to run and are more complex
than unit tests, they should only be used to cover a few critital code paths.
Full validation of the application's logic (code coverage) should be achieved with unit tests
(but as shown later on, unit tests don't have to duplicate the same cases that are 
covered by service tests).

### Their place in microservice tests
Service tests are the thing that says whether an application will not just crash on start
after you deploy it.
They can do that because they examine a "living" and "authentic" process of an application.
Authenticity in this case means running the process like it would run in a production
environment, with no special test flags, no fake data base clients, etc.
The application under test should "have no idea" that it's not in a "real" environment.

With these properties, a test suite can run locally, in isolation from the production (or staging)
environment.
It can be launched on a development or a CI (Continuous Integration) machine.
This allows for parallel development of multiple microservices by multiple teams

In his presentation about testing microservices, Martin Fowler places service tests
(which he calls out-of-process component tests) in the middle of the tests pyramid.

![](images/test_pyramid.png "Microservice test pyramid")

The general idea is that the higher you get in the pyramid, the tests:

* become more complex and hard to maintain,
* have greater response time (run longer),
* should be fewer.

All of those kinds of tests are important for a microservice-based system, but due to limited
space I can't get into detail about all of them.
Anyhow, if all services have a good suit of unit and service tests, then each should behave
like we wanted it to, so there's a good chance that the whole system will work fine...
But in reality we still need end-to-end tests to check for unexpected errors that sometimes
happen (so they surely will eventually happen) when integrating the entire platform in a
production-like (or the actual production) environment.

Nevertheless, even inroducing TDD with unit and service tests alone will greatly improve
your development process, so let's move on.

### Necessary tools
To have local service tests, the service's runtime dependencies must somehow be satisfied.
Assuming we're building HTTP microservices, the dependencies most probably are:

* data bases
* other microservices (or any other HTTP applications)

#### Handling data bases
*Naively* - just by installing on the machine running the tests.
This is tiresome and unwieldy.
Development of every microservice would either require long manual setup or
maintaining installation scripts (what can also require a lot of work).
Also if someone works on a few projects they'll get a lot of junk on their OS.

*Verified Fakes* are test doubles of some system (let's say a data base) that are created
by the maintainers (or other contributors) of said system.
They are also tested (verified) to ensure that they behave like the real version during tests.
They can make tests faster and easier to set up, but require effort to develop, and since time
is a precious resource, are rarely seen in the real world.

Using *Docker* is my preferred approach. With it almost every application can be downloaded as an
image and run as a container in a uniform way.
Without messy or convoluted installation processes.
Although a while ago it was only available for linux, now it starts to support Windows and Mac.

#### Handling other microservices
The problem here is that if we'd want to simply set up the other services that are required by the 
service under tests, we would also need to set up their dependencies as well.
This chain reaction could go on until we had a large chunk (if not all) of the platform on our
development machine.
Even if not absolutely cumbersome, this could prove impossible.

Fortunately, HTTP services can be mocked (or stubbed) out.
There are a few solutions (mock servers) I came across that can be configured to start imitating
HTTP services on selected ports.
The imitation is about responding to a defined HTTP call, e.g. POST on path /some/path with body
containing the string "potato", with a specific response, e.g status code 201
and body containing string "making potateos".
Those mock servers are:

* *WireMock* is a Java veteran that can run as a standalone application and can be configured with
HTTP calls.
* *Pretenders*, a Python library and a server (like WireMock) that can be used from test code.
It requires manually starting the server before running the tests.
* *Mountebank* is similar in principal to the previous two, but has more features, including 
faking TCP services (which can be used to simulate broken HTTP messages).
It's written in NodeJS, but it can be downloaded as a standalone package not requiring a Node
installation.
I chose it as my service mocking solution.

To use Mountebank in tests comfortably and not be required to start it manually before
tests, I created Mountepy.
It's a library that gracefully handles starting and stopping Mountebank's process.
It also handles configuration of HTTP service imitations, which Mountebank refers to as "imposters".
Since Mountepy required implementation of management logic for a HTTP service process
(which Mountebank is),
it also has the feature of controlling the process of the application under tests,
thus providing a complete solution for framework-agnostic service tests.

### Test anatomy
Because of its conciseness and due to its powerfull and composable fixture system,
I chose Pytest.
An example service test created with it can look like any other plain and simple unit test:

```python
# Fixtures are test resource objects that are injected into the test by the framework.
# This test is parameterized with two of them:
# "our_service", a Mountepy handler of the service under test
# and "db", a Redis (but it could be any other data base) client.
def test_something(our_service, db):
    db.put(TEST_DB_ENTRY)
    response = requests.get(
        our_service.url + '/something',
        headers={'Authorization': TEST_AUTH_HEADER})
    assert response.status_code == 200
```

It's quite clear what's happening in the test: some test data is put in the data base,
the service is called through HTTP, and finally, there's an assertion on the response.
Such straightforward testing is possible thanks to the power of Pytest fixtures.
Not only can they parameterize tests, but also other fixtures.
The two top-level ones presented above are themselves composed of others
(as shown on the diagram below) in order to fine-tune their behavior to our needs.

![](images/fixtures.svg "Fixture composition")

Let's now trace all the elements that make up our test fixtures.
First, `db`:

```python
import docker
import pytest
import redis 

# "db" is function scoped, so it will be recreated on each test function.
# It depends on another fixture - "db_session".
@pytest.yield_fixture(scope='function')
def db(db_session):
    # "yield" statement in "yield fixtures" returns the fixture object to the test.
    # "db" simply returns the object returned from "db_session".
    yield db_session
    # Code after "yield" is executed when the tests go outside of the fixture's scope,
    # in this case - at the end of a test function.
    # This is the place to write cleanup code for fixtures, no callbacks required.
    # Here the cleanup means deleting all the data in Redis.
    db_session.flushdb()

# "session" scope means that the object will be created only once for the entire
# test suit run.
@pytest.fixture(scope='session')
def db_session(redis_port):
    return redis.Redis(port=redis_port, db=0)

# This fixture simply returns a port number for Redis, but has the side effect
# of creating and later destroying a Docker container (with Redis).
# Thanks to being session-scoped it doesn't need to spawn a new container for each test,
# thus cutting down the test time.
# This practice may be looked down upon by people paranoid about test isolation,
# but if Redis creators did their job well, cleaning the data base in "db" should be enough
# to start each service test on a clean slate.
@pytest.yield_fixture(scope='session')
def redis_port():
    docker_client = docker.Client(version='auto')
    # Developers don't need to download required images themselves,
    # they only need to run the tests.
    download_image_if_missing(docker_client)
    # Creates the container and waits for Redis to start accepting connections.
    container_id, redis_port = start_redis_container(docker_client)
    yield redis_port
    docker_client.remove_container(container_id, force=True)
```

...and next, `our_service`:

(TODO)

```python
import mountepy

@pytest.fixture(scope='function')
def our_service(our_service_session, ext_service_impostor):
    return our_service

@pytest.yield_fixture(scope='session')
def our_service_session():
    service_command = [
        WAITRESS_BIN_PATH,
        '--port', '{port}',
        '--call', 'data_acquisition.app:get_app']

    service = mountepy.HttpService(
        service_command,
        env={
            'SOME_CONFIG_VALUE': 'blabla',
            'PORT': '{port}',
            'PYTHONPATH': PROJECT_ROOT_PATH})

    service.start()
    yield service
    service.stop()

@pytest.yield_fixture(scope='function')
def ext_service_impostor(mountebank):
    impostor = mountebank.add_imposter_simple(
        port=EXT_SERV_STUB_PORT,
        path=EXT_SERV_PATH,
        method='POST')
    yield impostor
    impostor.destroy()

@pytest.yield_fixture(scope='session')
def mountebank():
    mb = Mountebank()
    mb.start()
    yield mb
    mb.stop()
```

`our_service` właściwie tylko przekazuje jeden fixture dalej `our_service_session`
i wymusza stworzenie innego - `ext_service_impostor`
I has function scope because `ext_service_impostor` has function scope.
Fixtures can only be composed with those of the same or broader scope;
it's not possible for a session scoped test be dependent on a function scoped test.
BTW, there are more scopes, function and session are, respectively, the narrower and the broadest.

`our_service_session` creates (and later destroys) the process of the service under test with Mountepy.
This is straightforwad: you need to define the command line arguments for the service process
like you would do when using Popen, and pass service configuration as environment variables (`env=`).
The process being started here is Waitress (an WSGI container, alternative to gunicorn and uwsgi)
running the web application.

It also uses the same trick as `db` and `db_session` to save time.
It's true that here the risk of tests infuencing each other is greater, because it concerns the software
that we are writing and not something that the whole community depends on, like Redis.
But any strange behavior of the tests may indicate that we didn't write the application to be stateless,
which it should be when upholding the tenents of 12 factor app, so the tests will do their job of finding problems.

`ext_service_impostor` nie jest bezpośrednio wykorzystywany, ale wywołuje kontrolowany efekt uboczny - ustawienie
impostora (mocka usługi HTTP) w procesie mountebanka na czas trwania testu.
Robi to dzięki obiektowi zarządzającemu procesem mountebanka (który także jest stworzony raz na całe testy).
Impostor w tym przypadku jest bardzo prosty - sprawia, że POST na zadanym porcie i zadanej ścieżcę (np. "/some/resource")
będzie zwracał 200 i pustą odpowiedź (poprawnie jeśli chodzi o HTTP byłoby, żeby zwracał 204, ale tak krótszy kod)

Kod tego można znaleźć w [PyDAS](https://github.com/butla/pydas), który był moim eksperymentalnym projektem dla
wprowadzania TDD (można tam zobaczyć wykorzystanie wszystkich technik z tego papieru).

### Remarks
Widać, że ogólnie kod, który trzeba napisać nie jest duży - można te fixture'y przeklejać między projektami.
Ale może kiedyś zrobię jakiś plugin do pytesta.
Jeśli ktoś z czytelników chce to zrobić, niech da mi znać.
Co do dockera to może są już jakieś pluginy do pytesta, żeby obługiwać ściąganie i spawnowanie kontenerów.

Może by się wydawać, że testy które odpalają kilka procesów i robią prawdziwe calle HTTP
będą wolne, ale tak być nie musi.
W przypadku PyDAS, gdzie było 8 testów serwisowych, 3 zintegrowane (wspomniane wcześniej, też używające prawdziwego Redisa)
i 40 jednostkowych całość zabierała lekko poniżej 3 sekund (Python 3.4).
Jedna rzecz, której nie wyjaśniłem to to, że po boocie kompa testy zajmą dłużej, ok 11 sekund.
No i pierwsze odpalenie testów jeśli nie mamy image'u dockerowego zatrzyma się w momencie ściągania
i zajmie tyle ile ściąganie.

Pamiętajcie, że mimo wszystko dobrze mieć te testy w osobnych folderach, żeby móc robić bardzo szybkie zmiany
i puszczać jedynie jednostkowe (ok 0.3 sekundy).

No, czyli testy wychodzą szybkie, a jak są szybkie, to ludzie się cieszą, faktycznie je puszczają i jest
jakiś zysk z posiadania testów.
Jak by były za wolne to i tak ludzie nie chcieli by ich puszczać, więc cały wysiłek
w nie włożony szedł by na marne.

Before ending the topic of service tests, a few words of warning.
When a test fails in Pytest, all of it's output is printed in addition to the test stacktrace.
Service tests start a few processes, probably all of which print quite a few messages,
so when they fail you'll be hit with a big wall of text.
The upside is that it this text will most probably state somewhere what went wrong.

Breaking a fixture sometimes happens when experimenting with and refactor the tests (which I encourage).
This can yield even crazier logs that simply failed service tests.

And the last thing - tests won't save you from all instances of human incompetence.
When I created PyDAS using TDD I wanted to put it in our staging environment it kept crashing.
It turned out that I was ignoring Redis IP from configuration and had hardcoded localhost,
which was fine with the tests.
So be confident in your tests, but never a hudred percent.


## Enforcing TDD
Żeby ludzie robili TDD

### Measuring code coverage
A propos pokrycia w service testach:
Możliwość liczenia pokrycia testami poza procesem się bardzo przydaje, żeby oszczędzić roboty jednocześnie trzymając wysoką jakość.
Czasem bez sensu duplikować wolne testy w szybkich, skoro tylko wolne dają jakąś dozę pewności (testy redisa w pydasie). Ale jeśli wolne przechodzą, to umożliwia to posiadanie szybkich z jakimiś założeniami w mockach. 

.coveragerc z PyDASa

```
[report]
fail_under = 100
[run]
source = data_acquisition
parallel = true
```

http://coverage.readthedocs.io/en/coverage-4.0.3/subprocess.html

Musi być pokryty cały kod. Jak nie ma, to fail.

W Pythonie przydaje się mieć chociaż 100, żeby mieć przekonanie, że nie zrypało się gdzieś wywołań.

Pokrycie się przydaje, żeby sprawdzić, czy nie zapomnieliśmy o żadnej linii. Niby robiąc TDD powinniśmy i tak pisać najpierw test, potem kod. Czyli fragment kodu powinien powstawać tylko, jak mamy na niego test. Ale czasem chcemy pracować trochę szybciej i dodajemy jakiegoś "ifa" w kodzie zauważając, że jest sytuacja w której coś może się wywalić. Np. chcąc zrealizować funkcjonalność dla jednego testu piszę kod, który może rzucić wyjątek. Dodaję try/except. Pokrycie przypomni mi, że nie przetestowałem tego przypadku.

Parallel - testy serwisowe też będą mierzyły pokrycie.
Nawet jak Pydas odpalał jeszcze inne rzeczy przez multiprocessing.

### Mandatory static code analysis
Wyskoczy coś w pylincie to bum.

Można false-positivy oznaczać w liniach.

tox.ini (simplified) https://tox.readthedocs.io

```
[testenv]
commands =
    coverage run -m py.test tests/
    coverage report -m
    /bin/bash -c "pylint data_acquisition --rcfile=.pylintrc"
```


## Contract tests with Swagger and Bravado
Dodatkowe zabezpieczenie przy pracy z ludźmi i mikroserwisami.

Nawet mając takie testy, jak sprawić, żeby zmiana w jednym serwisie nad którą ktoś
niezależnie pracuje (i puszcza na nią testy) nie zepsuła jakiś interakcji z serwisami?
Even if you have a way to do TDD, maybe not everyone on the teamwill follow it, making life harder
for everyone.

Powinny trzymać w ryzach nasz kontrakt.

Zapewniać, że przez przypadek nie zmieniliśmy.

### Swagger
[Swagger](http://swagger.io/) is an interface definition language. Will serve as contract description.
Now also called OpenAPI a standard under the wings of Linux Foundation.
Has many tools (online editors, code generators), integrations with different languages.

An example Swagger document written in YAML format (JSON also happens) is below.

```
swagger: '2.0'
info:
  version: "0.0.1"
  title: Some interface
paths:
  /person/{id}:
    get:
      parameters:
        -
          name: id
          in: path
          required: true
          type: string
          format: uuid
      responses:
        '200':
          description: Successful response
          schema:
            title: Person
            type: object
            properties:
              name:
                type: string
              single:
                type: boolean
```

It defines a HTTP endpoint on path /person/{id} on the service's location (e.g. http://example.com/person/zablarg13).
This endpoint will respond to a GET request.
It has one parameter - id - that is passed in the path and is a string.
The endpoint can respond with a message with status code 200 contaning the representation of
a person's data - and object with their name as string and the information if they are single (boolean).

### Contract/service tests
Contract (Swagger API description) should be separate from code so that when patches break the
contract we can detect it.
Some solutions generate Swagger from code which would have the bonus of documenting the API
(also there with a separate, static contract), but it would be pointless from the perspective
of our contract tests.

[Bravado](https://github.com/Yelp/bravado) is a library that can dynamically create client
objects for a service based on its Swagger contract.

It can automatically validate the types (schemas) of both parameters and the values returned from
services.
Can verify HTTP status codes. Status code and response schema combinations that don't exist
in Swagger are treated as invalid, e.g. if we can return a Person object with code 200 and
an empty body with code 204, returning a Person with 204 will cause an error.

It's worth noting that Bravado can be configured to enable or disable different validation checks.
This is helpful in testing the unhappy path through your service.


Bravado used In service tests: instead of “requests”

(TODO comments in the code!)

```python
def test_contract_service(swagger_spec, our_service):
    client = SwaggerClient.from_spec(
        swagger_spec,
        origin_url=our_service.url))

    request_options = {
        'headers': {'authorization': A_VALID_TOKEN},
    }

    resp_object = client.v1.submitOperation(
        body={'name': 'make_sandwich', 'repeats': 3},
        worker='Mom',
        _request_options=requet_options).result()

    assert resp_object.status == 'whatever'
```

Service tests now double as contract tests with little effort.

### Contract/unit tests
In unit tests (they take less time then service ones): https://github.com/butla/bravado-falcon
Zrobiłem takiego toola.
Dzięki architekturze Bravado każdy może zrobić takiego toola do swojego frameworka,
bo raczej frameworki mają swoje sposoby na testowanie udawanego HTTP.

```python
from bravado.client import SwaggerClient
from bravado_falcon import FalconHttpClient
import yaml
import tests # our tests package

def test_contract_unit(swagger_spec):
    client = SwaggerClient.from_spec(
        swagger_spec,
        http_client=FalconHttpClient(tests.service.api))

    resp_object = client.v1.submitOperation(
        body={'name': 'make_sandwich', 'repeats': 3},
        worker='Mom').result()

    assert resp_object.status == 'whatever'

@pytest.fixture()
def swagger_spec():
    with open('api_spec.yaml') as spec_file:
        return yaml.load(spec_file)
```

Now, with a little effort (test client of your framework can be switched for bravado one)
also unit tests can double as contract tests.
With that you can achieve full coverage of your cotract without making the test suit obnoxiously long.

Nie trzeba duplikować tego samego testu w unit i service testach, wręcz jest to zbędne,
ale to tylko dla przykładu.

## Conclusion
Z tymi narzędziami powinniście sobie dobrze poradzić w rozwijaniu niezależnych serwisów,
projekt powinien iść dobrze i wszystkie teamy powinny móc działać niezależnie nie psując sobie nic nawzajem.
Ale to jeszcze nie zapewnia sukcesu całemu projektowi.

There are more important factors of a success with microservice project that I didn't have
the time to cover:
* end-to-end tests - 
  That's why they are in the Fowler's testing pyramid.
* performance tests - trzeba trzymać jakiś poziom przepustowości, żeby obsłużyć klientów (to jedno),
  a drugie, że niektóre zmiany mogą drastycznie zmniejszyć performance - trzeba tego pilnować.
  zmiany mogą nieoczeki
* operations automation (deployment, data recovery, service scaling, etc.)
* monitoring of services and infrastructure

## Sources
* Gary Bernhardt. [Fast Test, Slow Test](https://youtu.be/RAxiiRPHS9k)
* Sam Newman. Building Microservices. O'Reilly Media, Inc., February 10, 2015.
* Harry J.W. Percival. Test-Driven Development with Python. O'Reilly Media, Inc., June 19, 2014.
* martinfowler.com ["Microservice Testing"](http://martinfowler.com/articles/microservice-testing/)
* sdtimes.com ["Testing in production comes out of the shadows"](http://sdtimes.com/testing-production-comes-shadows/)
